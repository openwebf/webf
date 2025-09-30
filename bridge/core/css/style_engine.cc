/*
 * Copyright (C) 1999 Lars Knoll (knoll@kde.org)
 *           (C) 1999 Antti Koivisto (koivisto@kde.org)
 *           (C) 2001 Dirk Mueller (mueller@kde.org)
 *           (C) 2006 Alexey Proskuryakov (ap@webkit.org)
 * Copyright (C) 2004, 2005, 2006, 2007, 2008, 2009, 2011, 2012 Apple Inc. All
 * rights reserved.
 * Copyright (C) 2008, 2009 Torch Mobile Inc. All rights reserved.
 * (http://www.torchmobile.com/)
 * Copyright (C) 2008, 2009, 2011, 2012 Google Inc. All rights reserved.
 * Copyright (C) 2010 Nokia Corporation and/or its subsidiary(-ies)
 * Copyright (C) Research In Motion Limited 2010-2011. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public License
 * along with this library; see the file COPYING.LIB.  If not, write to
 * the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301, USA.
 */

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#include "style_engine.h"

#include <functional>
#include <span>
#include <unordered_map>
#include "core/css/css_property_name.h"
#include "core/css/css_property_value_set.h"
#include "core/css/css_style_sheet.h"
#include "core/css/css_value.h"
#include "core/css/style_sheet_contents.h"
#include "core/css/properties/css_property.h"
#include "core/css/resolver/style_resolver.h"
#include "core/dom/document.h"
#include "core/dom/element.h"
#include "core/css/element_rule_collector.h"
#include "core/css/resolver/style_resolver_state.h"
#include "core/css/resolver/style_cascade.h"

namespace webf {

namespace {

struct CSSPropertyIDHash {
  size_t operator()(CSSPropertyID id) const noexcept { return static_cast<size_t>(id); }
};

using InheritedValueMap = std::unordered_map<CSSPropertyID, String, CSSPropertyIDHash>;

}  // namespace

StyleEngine::StyleEngine(Document& document) : document_(&document) {
  WEBF_LOG(VERBOSE) << &document;
  CreateResolver();
}

CSSStyleSheet* StyleEngine::CreateSheet(Element& element, const String& text) {
  assert(GetDocument().GetExecutingContext()->isBlinkEnabled());
  assert(&element.GetDocument() == &GetDocument());
  // Note: Blink allows creating sheets for disconnected elements, so we don't check isConnected()

  CSSStyleSheet* style_sheet = nullptr;

  // The style sheet text can be long; hundreds of kilobytes. In order not to
  // insert such a huge string into the AtomicString table, we take its hash
  // instead and use that. (This is not a cryptographic hash, so a page could
  // cause collisions if it wanted to, but only within its own renderer.)
  // Note that in many cases, we won't actually be able to free the
  // memory used by the string, since it may e.g. be already stuck in
  // the DOM (as text contents of the <style> tag), but it may eventually
  // be parked (compressed, or stored to disk) if there's memory pressure,
  // or otherwise dropped, so this keeps us from being the only thing
  // that keeps it alive.
  String key;
  if (text.length() >= 1024) {
    StringBuilder builder;
    builder.AppendNumber(text.Impl() ? text.Impl()->GetHash() : 0);
    key = builder.ReleaseString();
  } else {
    key = text;
  }

  if (text_to_sheet_cache_.count(key) == 0 || !text_to_sheet_cache_[key]->IsCacheableForStyleElement()) {
    style_sheet = ParseSheet(element, text);
    assert(style_sheet != nullptr);
    if (style_sheet->Contents()->IsCacheableForStyleElement()) {
      text_to_sheet_cache_[key] = style_sheet->Contents();
    }
  } else {
    auto contents = text_to_sheet_cache_[key];
    assert(contents != nullptr);
    assert(contents->IsCacheableForStyleElement());
    assert(contents->HasSingleOwnerDocument());

    contents->SetIsUsedFromTextCache();
    // Ensure cached contents for style elements never have load errors
    contents->SetDidLoadErrorOccur(false);

    style_sheet = CSSStyleSheet::CreateInline(element.GetExecutingContext(), contents, element);
  }

  assert(style_sheet);

  return style_sheet;
}

CSSStyleSheet* StyleEngine::ParseSheet(Element& element, const String& text) {
  assert(GetDocument().GetExecutingContext()->isBlinkEnabled());
  // Create parser context without Document to avoid circular references
  auto parser_context = std::make_shared<CSSParserContext>(kHTMLStandardMode);
  auto contents = std::make_shared<StyleSheetContents>(parser_context, NullURL().GetString());
  contents->ParseString(text);
  // For style elements (inline CSS), ensure no load error is flagged
  contents->SetDidLoadErrorOccur(false);
  
  CSSStyleSheet* style_sheet = CSSStyleSheet::CreateInline(element.GetExecutingContext(), contents, element);
  return style_sheet;
}

Document& StyleEngine::GetDocument() const {
  return *document_;
}


void StyleEngine::UpdateStyleInvalidationRoot(ContainerNode* ancestor, Node* dirty_node) {
  // Minimal placeholder: pending invalidations are already tracked on nodes.
  // This hook exists to allow future optimizations and invalidation root tracking.
  (void)ancestor;
  (void)dirty_node;
}

void StyleEngine::UpdateStyleRecalcRoot(ContainerNode* ancestor, Node* dirty_node) {
  // Minimal placeholder: ancestor chain has been marked via Node::MarkAncestorsWithChildNeedsStyleRecalc.
  // This hook can later maintain a compact set of recalc roots.
  (void)ancestor;
  (void)dirty_node;
}

void StyleEngine::ScheduleNthPseudoInvalidations(ContainerNode& nth_parent) {}

bool StyleEngine::MarkReattachAllowed() const {
  return !InRebuildLayoutTree() || allow_mark_for_reattach_from_rebuild_layout_tree_;
}

bool StyleEngine::MarkStyleDirtyAllowed() const {
  if (GetDocument().InStyleRecalc() || InContainerQueryStyleRecalc()) {
    return allow_mark_style_dirty_from_recalc_;
  }
  return !InRebuildLayoutTree();
}

void StyleEngine::CreateResolver() {
  resolver_ = std::make_shared<StyleResolver>(GetDocument());
}

void StyleEngine::RecalcStyle(Document& document) {
  if (!document.GetExecutingContext()->isBlinkEnabled()) {
    return;
  }

  std::function<InheritedValueMap(Element*, const InheritedValueMap&)> apply_for_element =
      [&](Element* element, const InheritedValueMap& parent_inherited) -> InheritedValueMap {
        if (!element || !element->IsStyledElement()) {
          return parent_inherited;
        }

        StyleResolver& resolver = EnsureStyleResolver();
        StyleResolverState state(document, *element);
        ElementRuleCollector collector(state, SelectorChecker::kQueryingRules);
        resolver.CollectAllRules(state, collector, /*include_smil_properties*/ false);
        collector.SortAndTransferMatchedRules();

        StyleCascade cascade(state);
        for (const auto& entry : collector.GetMatchResult().GetMatchedProperties()) {
          if (entry.is_inline_style) {
            cascade.MutableMatchResult().AddInlineStyleProperties(entry.properties);
          } else {
            cascade.MutableMatchResult().AddMatchedProperties(entry.properties, entry.origin, entry.layer_level);
          }
        }

        std::shared_ptr<MutableCSSPropertyValueSet> property_set = cascade.ExportWinningPropertySet();

        auto inline_style = const_cast<Element&>(*element).EnsureMutableInlineStyle();
        if (inline_style && inline_style->PropertyCount() > 0) {
          if (!property_set) {
            property_set = std::make_shared<MutableCSSPropertyValueSet>(kHTMLStandardMode);
          }
          unsigned icount = inline_style->PropertyCount();
          for (unsigned i = 0; i < icount; ++i) {
            auto in_prop = inline_style->PropertyAt(i);
            CSSPropertyID id = in_prop.Id();
            if (id == CSSPropertyID::kInvalid || id == CSSPropertyID::kVariable) {
              continue;
            }
            if (!property_set->HasProperty(id)) {
              const auto* vptr = in_prop.Value();
              if (vptr && *vptr) {
                property_set->SetProperty(id, *vptr, in_prop.IsImportant());
              }
            }
          }
        }

        if (!property_set || property_set->IsEmpty()) {
          return parent_inherited;
        }

        auto* ctx = document.GetExecutingContext();
        unsigned count = property_set->PropertyCount();
        bool cleared = false;
        InheritedValueMap inherited_values(parent_inherited);

        for (unsigned i = 0; i < count; ++i) {
          auto prop = property_set->PropertyAt(i);
          CSSPropertyID id = prop.Id();
          if (id == CSSPropertyID::kInvalid) {
            continue;
          }

          const auto* value_ptr = prop.Value();
          if (!value_ptr || !(*value_ptr)) {
            continue;
          }

          const CSSValue& value = *(*value_ptr);
          bool is_inherited_property = CSSProperty::Get(id).IsInherited();
          AtomicString prop_name = prop.Name().ToAtomicString();
          String value_string = value.CssText();

          if (is_inherited_property) {
            if (value.IsInheritedValue() || value.IsUnsetValue() || value.IsRevertValue() ||
                value.IsRevertLayerValue()) {
              auto inherited_it = parent_inherited.find(id);
              if (inherited_it != parent_inherited.end()) {
                value_string = inherited_it->second;
                if (!value_string.IsEmpty()) {
                  inherited_values[id] = value_string;
                } else {
                  inherited_values.erase(id);
                }
              } else {
                value_string = String();
                inherited_values.erase(id);
              }
            } else {
              inherited_values[id] = value_string;
            }
          } else {
            if (value.IsInheritedValue() || value.IsUnsetValue() || value.IsRevertValue() ||
                value.IsRevertLayerValue()) {
              continue;
            }
          }

          if (value_string.IsNull()) {
            value_string = String("");
          }

          if (!cleared) {
            ctx->uiCommandBuffer()->AddCommand(UICommand::kClearStyle, nullptr, element->bindingObject(), nullptr);
            cleared = true;
          }

          AtomicString value_atom(value_string);
          std::unique_ptr<SharedNativeString> args_01 = prop_name.ToStylePropertyNameNativeString();
          ctx->uiCommandBuffer()->AddCommand(UICommand::kSetStyle, std::move(args_01), element->bindingObject(),
                                             value_atom.ToNativeString().release());
        }

        return inherited_values;
      };

  std::function<void(Node*, const InheritedValueMap&)> walk =
      [&](Node* node, const InheritedValueMap& inherited_values) {
        if (!node) {
          return;
        }

        InheritedValueMap current_inherited = inherited_values;
        if (node->IsElementNode()) {
          current_inherited = apply_for_element(static_cast<Element*>(node), inherited_values);
        }

        for (Node* child = node->firstChild(); child; child = child->nextSibling()) {
          walk(child, current_inherited);
        }
      };

  walk(document.documentElement(), InheritedValueMap());
}

void StyleEngine::Trace(GCVisitor* visitor) {}

}  // namespace webf
