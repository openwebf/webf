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
#include <cctype>
#include <span>
#include <unordered_map>
#include "core/css/css_property_name.h"
#include "core/css/css_property_value_set.h"
#include "core/css/css_style_sheet.h"
#include "core/css/css_value.h"
#include "core/css/media_query_evaluator.h"
#include "core/css/style_sheet_contents.h"
#include "core/css/style_rule.h"
#include "core/css/properties/css_property.h"
#include "core/css/resolver/style_resolver.h"
#include "core/dom/document.h"
#include "core/dom/element.h"
#include "core/css/element_rule_collector.h"
#include "core/css/resolver/style_resolver_state.h"
#include "core/css/resolver/style_cascade.h"
// Extra includes for post-pass background resolution
#include "core/css/resolver/style_recalc_context.h"
#include "core/html/html_body_element.h"
#include "core/html/html_style_element.h"
#include "html_names.h"
// Logging and pending substitution value support
#include "foundation/logging.h"
#include "bindings/qjs/native_string_utils.h"
#include "core/css/css_pending_substitution_value.h"
#include "foundation/dart_readable.h"
#include "core/style/computed_style_constants.h"
#include "foundation/native_string.h"
#include "core/css/white_space.h"
// Keyframes support
#include "core/css/css_keyframes_rule.h"
#include "core/css/style_rule_keyframe.h"
#include "core/css/invalidation/style_invalidator.h"
#include "core/dom/container_node.h"
#include "core/dom/element_traversal.h"
#include "core/dom/qualified_name.h"

namespace webf {

namespace {

struct CSSPropertyIDHash {
  size_t operator()(CSSPropertyID id) const noexcept { return static_cast<size_t>(id); }
};

using InheritedValueMap = std::unordered_map<CSSPropertyID, String, CSSPropertyIDHash>;
using CustomVarMap = std::unordered_map<AtomicString, String, AtomicString::KeyHasher>;

struct InheritedState {
  InheritedValueMap inherited_values;
  CustomVarMap custom_vars;
};

// Very small textual resolver for var() references inside CSS text.
// It substitutes occurrences of var(--name[, fallback]) using provided custom_vars.
// This mirrors Blink's behavior at a high level for our narrow use-case (e.g. rgb(var(--r,g,b))).
static String ResolveVarsInCssText(const String& input, const CustomVarMap& custom_vars) {
  // Operate on UTF-8 for simplicity; our test inputs are ASCII-compatible.
  std::string s = input.ToUTF8String();

  auto ltrim = [](const std::string& str) -> std::string {
    size_t i = 0;
    while (i < str.size() && isspace(static_cast<unsigned char>(str[i]))) i++;
    return str.substr(i);
  };
  auto rtrim = [](const std::string& str) -> std::string {
    if (str.empty()) return str;
    size_t i = str.size();
    while (i > 0 && isspace(static_cast<unsigned char>(str[i - 1]))) i--;
    return str.substr(0, i);
  };
  auto trim = [&](const std::string& str) -> std::string { return rtrim(ltrim(str)); };

  size_t pos = 0;
  while (true) {
    size_t start = s.find("var(", pos);
    if (start == std::string::npos) break;
    size_t i = start + 4;  // after 'var('
    int depth = 1;
    while (i < s.size() && depth > 0) {
      if (s[i] == '(') depth++;
      else if (s[i] == ')') depth--;
      i++;
    }
    if (depth != 0) {
      // Unbalanced; abort further attempts.
      break;
    }
    size_t end = i - 1;  // position of ')'
    std::string inside = s.substr(start + 4, end - (start + 4));

    // Split inside by top-level comma to get name and optional fallback.
    int inner_depth = 0;
    size_t comma_pos = std::string::npos;
    for (size_t k = 0; k < inside.size(); ++k) {
      char c = inside[k];
      if (c == '(') inner_depth++;
      else if (c == ')') inner_depth--;
      else if (c == ',' && inner_depth == 0) { comma_pos = k; break; }
    }
    std::string name_part = comma_pos == std::string::npos ? inside : inside.substr(0, comma_pos);
    std::string fb_part = comma_pos == std::string::npos ? std::string() : inside.substr(comma_pos + 1);
    name_part = trim(name_part);
    fb_part = trim(fb_part);

    std::string replacement_utf8;
    if (name_part.rfind("--", 0) == 0) {
      AtomicString key = AtomicString::CreateFromUTF8(name_part.c_str(), name_part.length());
      auto it = custom_vars.find(key);
      if (it != custom_vars.end()) {
        replacement_utf8 = it->second.ToUTF8String();
      } else {
        // Fallback: recursively resolve fallback text if provided; else keep original var() text
        // (keeping original is conservative; in CSS missing var invalidates the property).
        if (!fb_part.empty()) {
          String fb_str = String::FromUTF8(fb_part.c_str(), fb_part.length());
          replacement_utf8 = ResolveVarsInCssText(fb_str, custom_vars).ToUTF8String();
        } else {
          replacement_utf8 = s.substr(start, end - start + 1);
        }
      }
    } else {
      // Invalid custom ident; leave as-is.
      replacement_utf8 = s.substr(start, end - start + 1);
    }

    s.replace(start, end - start + 1, replacement_utf8);
    pos = start + replacement_utf8.size();
  }

  return String::FromUTF8(s.c_str(), s.size());
}

// Normalize gradient arguments by inserting missing commas between adjacent
// color-stops when a stop value (e.g. 75%) is followed by a color token with
// only whitespace in between. This helps accommodate inputs like
// "green 75% green 100%" by transforming to "green 75%, green 100%".
static String NormalizeGradientArguments(const String& input) {
  std::string s = input.ToUTF8String();
  auto normalize_in_fn = [&](size_t fn_start) {
    // fn_start points at the start of "linear-gradient(" or similar
    size_t lp = s.find('(', fn_start);
    if (lp == std::string::npos) return;
    int depth = 1;
    size_t i = lp + 1;
    while (i < s.size() && depth > 0) {
      if (s[i] == '(') depth++;
      else if (s[i] == ')') depth--;
      i++;
    }
    if (depth != 0) return; // unbalanced; give up
    size_t rp = i - 1; // position of ')'
    // Walk range [lp+1, rp)
    for (size_t k = lp + 1; k + 2 < rp; ++k) {
      // Look for pattern: '%' + whitespace + [a-zA-Z#]
      if (s[k] == '%' && (s[k + 1] == ' ' || s[k + 1] == '\t') &&
          ((s[k + 2] >= 'A' && s[k + 2] <= 'Z') || (s[k + 2] >= 'a' && s[k + 2] <= 'z') || s[k + 2] == '#')) {
        // If there's already a comma, skip.
        if (k + 2 < rp && s[k + 1] == ',' ) continue;
        // Replace single space/tabs with ", "
        s.replace(k + 1, 1, ", ");
        rp += 1; // length increased by 1
      }
    }
  };

  // Process known gradient functions.
  const char* fns[] = {"linear-gradient(", "repeating-linear-gradient(", "radial-gradient(",
                       "repeating-radial-gradient(", "conic-gradient("};
  for (const char* fn : fns) {
    size_t pos = 0;
    while (true) {
      size_t idx = s.find(fn, pos);
      if (idx == std::string::npos) break;
      normalize_in_fn(idx);
      pos = idx + strlen(fn);
    }
  }
  return String::FromUTF8(s.c_str(), s.size());
}
// Trim leading/trailing ASCII whitespace from a String.
static String TrimAsciiWhitespace(const String& input) {
  std::string s = input.ToUTF8String();
  size_t start = 0;
  while (start < s.size() && isspace(static_cast<unsigned char>(s[start]))) start++;
  size_t end = s.size();
  while (end > start && isspace(static_cast<unsigned char>(s[end - 1]))) end--;
  if (start == 0 && end == s.size()) return input;
  return String::FromUTF8(s.c_str() + start, end - start);
}
}  // namespace

void PossiblyScheduleNthPseudoInvalidations(Node& node) {
  if (!node.IsElementNode()) {
    return;
  }
  ContainerNode* parent = node.parentNode();
  if (!parent) {
    return;
  }

  if ((parent->ChildrenAffectedByForwardPositionalRules() && node.nextSibling()) ||
      (parent->ChildrenAffectedByBackwardPositionalRules() && node.previousSibling())) {
    node.GetDocument().GetStyleEngine().ScheduleNthPseudoInvalidations(*parent);
  }
}

StyleEngine::StyleEngine(Document& document) : document_(&document) {
  CreateResolver();
  global_rule_set_ = std::make_shared<CSSGlobalRuleSet>();
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
  // Register @font-face for this sheet (inline <style> path), walking parsed rules.
  if (style_sheet && element.GetDocument().GetExecutingContext() &&
      element.GetDocument().GetExecutingContext()->dartMethodPtr()) {
    ExecutingContext* exe_ctx = element.GetDocument().GetExecutingContext();
    int64_t sheet_id_val = std::bit_cast<int64_t>(style_sheet);
    auto contents = style_sheet->Contents();
    std::string base_href = contents->BaseURL().GetString();
    WEBF_LOG(INFO) << "[font-face][CreateSheet] begin sheetId=" << sheet_id_val << " baseHref=" << base_href;

    const auto& top = contents->ChildRules();
    std::vector<std::shared_ptr<const StyleRuleBase>> childVec;
    childVec.reserve(top.size());
    for (const auto& r : top) childVec.push_back(std::static_pointer_cast<const StyleRuleBase>(r));

    std::function<void(const std::vector<std::shared_ptr<const StyleRuleBase>>&)> walk;
    walk = [&](const std::vector<std::shared_ptr<const StyleRuleBase>>& rules) {
      for (const auto& r : rules) {
        if (!r) continue;
        if (r->IsFontFaceRule()) {
          auto ff = std::static_pointer_cast<const StyleRuleFontFace>(r);
          const CSSPropertyValueSet& props = ff->Properties();
          String family = props.GetPropertyValue(CSSPropertyID::kFontFamily);
          String src = props.GetPropertyValue(CSSPropertyID::kSrc);
          String weight = props.GetPropertyValue(CSSPropertyID::kFontWeight);
          String style = props.GetPropertyValue(CSSPropertyID::kFontStyle);
          if (!family.IsEmpty() && !src.IsEmpty()) {
            String familyLower = family.LowerASCII();
            std::string familyUtf8 = familyLower.ToUTF8String();
            std::string srcUtf8 = src.ToUTF8String();
            if (srcUtf8.size() > 160) srcUtf8 = srcUtf8.substr(0, 160) + "…";
            WEBF_LOG(INFO) << "[font-face][found] family='" << familyUtf8 << "' src='" << srcUtf8 << "'";
            auto baseHrefNative = stringToNativeString(base_href).release();
            auto familyNative = stringToNativeString(familyUtf8).release();
            auto srcNative = stringToNativeString(src.ToUTF8String()).release();
            auto weightNative = stringToNativeString(weight.ToUTF8String()).release();
            auto styleNative = stringToNativeString(style.ToUTF8String()).release();
            exe_ctx->dartMethodPtr()->registerFontFace(exe_ctx->isDedicated(), exe_ctx->contextId(), sheet_id_val,
                                                       familyNative, srcNative, weightNative, styleNative, baseHrefNative);
            WEBF_LOG(INFO) << "[font-face][register] dispatched to Dart (ctx=" << exe_ctx->contextId() << ")"
                           << " family='" << familyUtf8 << "'";
          }
        } else if (r->IsKeyframesRule()) {
          auto kf = std::static_pointer_cast<const StyleRuleKeyframes>(r);
          const AtomicString& name = kf->GetName();
          bool is_prefixed = kf->IsVendorPrefixed();
          // Serialize @keyframes similar to CSSKeyframesRule::cssText()
          StringBuilder kb;
          if (is_prefixed) {
            kb.Append("@-webkit-keyframes "_s);
          } else {
            kb.Append("@keyframes "_s);
          }
          kb.Append(String(name));
          kb.Append(" { \n"_s);
          const auto& frames = kf->Keyframes();
          for (size_t i = 0; i < frames.size(); ++i) {
            kb.Append("  "_s);
            kb.Append(frames[i]->CssText());
            kb.Append('\n');
          }
          kb.Append('}');
          std::string cssText = kb.ReleaseString().ToUTF8String();
          auto nameNative = stringToNativeString(String(name).ToUTF8String()).release();
          auto cssNative = stringToNativeString(cssText).release();
          exe_ctx->dartMethodPtr()->registerKeyframes(exe_ctx->isDedicated(), exe_ctx->contextId(), sheet_id_val,
                                                      nameNative, cssNative, is_prefixed ? 1 : 0);
          WEBF_LOG(INFO) << "[keyframes][register] name='" << String(name).ToUTF8String() << "'";
        } else if (r->IsMediaRule() || r->IsSupportsRule() || r->IsLayerBlockRule() || r->IsContainerRule() ||
                   r->IsScopeRule() || r->IsStartingStyleRule()) {
          auto group = std::static_pointer_cast<const StyleRuleGroup>(r);
          const auto& children = group->ChildRules();
          std::vector<std::shared_ptr<const StyleRuleBase>> nested;
          nested.reserve(children.size());
          for (size_t i = 0; i < children.size(); ++i) nested.push_back(children[i]);
          walk(nested);
        }
      }
    };
    WEBF_LOG(INFO) << "[font-face][CreateSheet] walking top-level rules count=" << childVec.size();
    walk(childVec);
    WEBF_LOG(INFO) << "[font-face][CreateSheet] end sheetId=" << sheet_id_val;
  }

  return style_sheet;
}

CSSStyleSheet* StyleEngine::CreateSheet(Element& element, const String& text, const AtomicString& base_href) {
  assert(GetDocument().GetExecutingContext()->isBlinkEnabled());
  CSSStyleSheet* style_sheet = nullptr;

  // Build a cache key that incorporates base href to avoid cross-base reuse.
  // If the text is large, reuse the hashed form like the other path.
  String key;
  if (text.length() >= 1024) {
    StringBuilder builder;
    builder.AppendNumber(text.Impl() ? text.Impl()->GetHash() : 0);
    builder.Append("|base="_s);
    builder.Append(base_href.GetString());
    key = builder.ReleaseString();
  } else {
    StringBuilder builder;
    builder.Append(text);
    builder.Append("|base="_s);
    builder.Append(base_href.GetString());
    key = builder.ReleaseString();
  }

  if (text_to_sheet_cache_.count(key) == 0 || !text_to_sheet_cache_[key]->IsCacheableForStyleElement()) {
    style_sheet = ParseSheet(element, text, base_href);
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
    contents->SetDidLoadErrorOccur(false);

    style_sheet = CSSStyleSheet::CreateInline(element.GetExecutingContext(), contents, element);
  }

  assert(style_sheet);
  // Register @font-face for this sheet when base href is specified.
  if (style_sheet && element.GetDocument().GetExecutingContext() &&
      element.GetDocument().GetExecutingContext()->dartMethodPtr()) {
    ExecutingContext* exe_ctx = element.GetDocument().GetExecutingContext();
    int64_t sheet_id_val = std::bit_cast<int64_t>(style_sheet);
    auto contents = style_sheet->Contents();
    std::string baseHrefStr = base_href.ToUTF8String();
    const auto& top = contents->ChildRules();
    // Helper to walk group rules without allocating temporary vectors.
    auto walk_group = [&](const StyleRuleGroup& grp, const auto& self_ref) -> void {
      const auto& children = grp.ChildRules();
      for (uint32_t i = 0; i < children.size(); ++i) {
        const auto& r = children[i];
        if (!r) continue;
        if (r->IsFontFaceRule()) {
          auto ff = std::static_pointer_cast<const StyleRuleFontFace>(r);
          const CSSPropertyValueSet& props = ff->Properties();
          String family = props.GetPropertyValue(CSSPropertyID::kFontFamily);
          String src = props.GetPropertyValue(CSSPropertyID::kSrc);
          String weight = props.GetPropertyValue(CSSPropertyID::kFontWeight);
          String style = props.GetPropertyValue(CSSPropertyID::kFontStyle);
          if (!family.IsEmpty() && !src.IsEmpty()) {
            String familyLower = family.LowerASCII();
            auto baseHrefNative = stringToNativeString(baseHrefStr).release();
            auto familyNative = stringToNativeString(familyLower.ToUTF8String()).release();
            auto srcNative = stringToNativeString(src.ToUTF8String()).release();
            auto weightNative = stringToNativeString(weight.ToUTF8String()).release();
            auto styleNative = stringToNativeString(style.ToUTF8String()).release();
            exe_ctx->dartMethodPtr()->registerFontFace(exe_ctx->isDedicated(), exe_ctx->contextId(), sheet_id_val,
                                                       familyNative, srcNative, weightNative, styleNative, baseHrefNative);
          }
        } else if (r->IsMediaRule() || r->IsSupportsRule() || r->IsLayerBlockRule() || r->IsContainerRule() ||
                   r->IsScopeRule() || r->IsStartingStyleRule()) {
          const auto group = std::static_pointer_cast<const StyleRuleGroup>(r);
          self_ref(*group, self_ref);
        }
      }
    };
    // Walk top-level
    for (const auto& r : top) {
      if (!r) continue;
      if (r->IsFontFaceRule()) {
        auto ff = std::static_pointer_cast<const StyleRuleFontFace>(r);
        const CSSPropertyValueSet& props = ff->Properties();
        String family = props.GetPropertyValue(CSSPropertyID::kFontFamily);
        String src = props.GetPropertyValue(CSSPropertyID::kSrc);
        String weight = props.GetPropertyValue(CSSPropertyID::kFontWeight);
        String style = props.GetPropertyValue(CSSPropertyID::kFontStyle);
        if (!family.IsEmpty() && !src.IsEmpty()) {
          String familyLower = family.LowerASCII();
          auto baseHrefNative = stringToNativeString(baseHrefStr).release();
          auto familyNative = stringToNativeString(familyLower.ToUTF8String()).release();
          auto srcNative = stringToNativeString(src.ToUTF8String()).release();
          auto weightNative = stringToNativeString(weight.ToUTF8String()).release();
          auto styleNative = stringToNativeString(style.ToUTF8String()).release();
          exe_ctx->dartMethodPtr()->registerFontFace(exe_ctx->isDedicated(), exe_ctx->contextId(), sheet_id_val,
                                                     familyNative, srcNative, weightNative, styleNative, baseHrefNative);
        }
      } else if (r->IsKeyframesRule()) {
        auto kf = std::static_pointer_cast<const StyleRuleKeyframes>(r);
        const AtomicString& name = kf->GetName();
        bool is_prefixed = kf->IsVendorPrefixed();
        // Serialize @keyframes similar to CSSKeyframesRule::cssText()
        StringBuilder kb;
        if (is_prefixed) {
          kb.Append("@-webkit-keyframes "_s);
        } else {
          kb.Append("@keyframes "_s);
        }
        kb.Append(String(name));
        kb.Append(" { \n"_s);
        const auto& frames = kf->Keyframes();
        for (size_t i = 0; i < frames.size(); ++i) {
          kb.Append("  "_s);
          kb.Append(frames[i]->CssText());
          kb.Append('\n');
        }
        kb.Append('}');
        std::string cssText = kb.ReleaseString().ToUTF8String();
        auto nameNative = stringToNativeString(String(name).ToUTF8String()).release();
        auto cssNative = stringToNativeString(cssText).release();
        exe_ctx->dartMethodPtr()->registerKeyframes(exe_ctx->isDedicated(), exe_ctx->contextId(), sheet_id_val,
                                                    nameNative, cssNative, is_prefixed ? 1 : 0);
      } else if (r->IsMediaRule() || r->IsSupportsRule() || r->IsLayerBlockRule() || r->IsContainerRule() ||
                 r->IsScopeRule() || r->IsStartingStyleRule()) {
        const auto group = std::static_pointer_cast<const StyleRuleGroup>(r);
        walk_group(*group, walk_group);
      }
    }
  }
  return style_sheet;
}

CSSStyleSheet* StyleEngine::ParseSheet(Element& element, const String& text) {
  assert(GetDocument().GetExecutingContext()->isBlinkEnabled());
  // Create parser context with the document and its base URL so relative
  // URLs (including @import) inside inline <style> resolve correctly.
  Document& doc = GetDocument();
  auto parser_context = std::make_shared<CSSParserContext>(doc, doc.BaseURL().GetString());
  auto contents = std::make_shared<StyleSheetContents>(parser_context, doc.BaseURL().GetString());
  contents->ParseString(text);
  // For style elements (inline CSS), ensure no load error is flagged
  contents->SetDidLoadErrorOccur(false);

  CSSStyleSheet* style_sheet = CSSStyleSheet::CreateInline(element.GetExecutingContext(), contents, element);
  return style_sheet;
}

CSSStyleSheet* StyleEngine::ParseSheet(Element& element, const String& text, const AtomicString& base_href) {
  assert(GetDocument().GetExecutingContext()->isBlinkEnabled());
  // Create parser context that uses the provided base URL for resolving URLs in CSS.
  Document& doc = GetDocument();
  auto parser_context = std::make_shared<CSSParserContext>(doc, base_href.ToUTF8String());
  auto contents = std::make_shared<StyleSheetContents>(parser_context, base_href.GetString());
  contents->ParseString(text);
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

void StyleEngine::CollectFeaturesTo(RuleFeatureSet& features) {
  Document& document = GetDocument();
  ExecutingContext* context = document.GetExecutingContext();
  if (!context || !context->isBlinkEnabled()) {
    return;
  }

  MediaQueryEvaluator medium(context);

  for (const auto& contents : author_sheets_) {
    if (!contents) {
      continue;
    }
    std::shared_ptr<RuleSet> rule_set = contents->EnsureRuleSet(medium);
    if (!rule_set) {
      continue;
    }
    features.Merge(rule_set->Features());
  }
}

void StyleEngine::UpdateActiveStyleSheets() {
  Document& document = GetDocument();
  ExecutingContext* context = document.GetExecutingContext();
  if (!context || !context->isBlinkEnabled()) {
    return;
  }

  // Mark the global RuleFeatureSet dirty so selector/invalidation metadata
  // (ids, classes, attributes, nth, etc.) will be rebuilt from the current
  // author sheets before the next invalidation-driven style recomputation.
  if (global_rule_set_) {
    global_rule_set_->MarkDirty();
  }

  Element* root = document.documentElement();
  if (!root) {
    return;
  }

  // Treat any change to the active stylesheet set (add/remove/modify <style>
  // or <link rel=stylesheet>) as potentially affecting the entire document.
  // Mark the root subtree as needing style recalc; RecalcInvalidatedStyles()
  // will recompute styles starting from here on the next frame/flush.
  root->SetNeedsStyleRecalc(
      kSubtreeStyleChange,
      StyleChangeReasonForTracing::Create(style_change_reason::kActiveStylesheetsUpdate));

  // Also mark the document as having pending style invalidation work so that
  // StyleInvalidator is invoked even if no selector-based invalidation sets
  // have been scheduled yet.
  document.SetNeedsStyleInvalidation();
}

void StyleEngine::IdChangedForElement(const AtomicString& old_id,
                                      const AtomicString& new_id,
                                      Element& element) {
  if (!global_rule_set_) {
    return;
  }

  Document& document = GetDocument();
  ExecutingContext* context = document.GetExecutingContext();
  if (!context || !context->isBlinkEnabled()) {
    return;
  }

  global_rule_set_->Update(document);
  const RuleFeatureSet& features = global_rule_set_->GetRuleFeatureSet();

  InvalidationLists invalidation_lists;

  if (!old_id.IsNull() && !old_id.empty()) {
    features.CollectInvalidationSetsForId(invalidation_lists, element, old_id);
  }
  if (!new_id.IsNull() && !new_id.empty()) {
    features.CollectInvalidationSetsForId(invalidation_lists, element, new_id);
  }

  if (!invalidation_lists.descendants.empty() || !invalidation_lists.siblings.empty()) {
    pending_invalidations_.ScheduleInvalidationSetsForNode(invalidation_lists, element);
  }
}

void StyleEngine::ClassAttributeChangedForElement(const AtomicString& old_class_value,
                                                  const AtomicString& new_class_value,
                                                  Element& element) {
  if (!global_rule_set_) {
    return;
  }

  Document& document = GetDocument();
  ExecutingContext* context = document.GetExecutingContext();
  if (!context || !context->isBlinkEnabled()) {
    return;
  }

  global_rule_set_->Update(document);
  const RuleFeatureSet& features = global_rule_set_->GetRuleFeatureSet();

  InvalidationLists invalidation_lists;

  auto collect_for_space_separated = [&](const AtomicString& value) {
    if (value.IsNull() || value.empty()) {
      return;
    }
    SpaceSplitString tokens(value);
    uint32_t size = tokens.size();
    for (uint32_t i = 0; i < size; ++i) {
      const AtomicString& class_name = tokens[i];
      if (class_name.empty()) {
        continue;
      }
      features.CollectInvalidationSetsForClass(invalidation_lists, element, class_name);
    }
  };

  collect_for_space_separated(old_class_value);
  collect_for_space_separated(new_class_value);

  if (!invalidation_lists.descendants.empty() || !invalidation_lists.siblings.empty()) {
    pending_invalidations_.ScheduleInvalidationSetsForNode(invalidation_lists, element);
  }
}

void StyleEngine::AttributeChangedForElement(const AtomicString& attribute_local_name,
                                             Element& element) {
  if (!global_rule_set_) {
    return;
  }

  Document& document = GetDocument();
  ExecutingContext* context = document.GetExecutingContext();
  if (!context || !context->isBlinkEnabled()) {
    return;
  }

  if (attribute_local_name.IsNull() || attribute_local_name.empty()) {
    return;
  }

  global_rule_set_->Update(document);
  const RuleFeatureSet& features = global_rule_set_->GetRuleFeatureSet();

  InvalidationLists invalidation_lists;
  QualifiedName attr_name(attribute_local_name);
  features.CollectInvalidationSetsForAttribute(invalidation_lists, element, attr_name);

  if (!invalidation_lists.descendants.empty() || !invalidation_lists.siblings.empty()) {
    pending_invalidations_.ScheduleInvalidationSetsForNode(invalidation_lists, element);
  }
}

void StyleEngine::RecalcStyle(Document& document) {
  if (!document.GetExecutingContext()->isBlinkEnabled()) {
    return;
  }

  auto begin_calc = std::chrono::steady_clock::now();

  std::function<InheritedState(Element*, const InheritedState&)> apply_for_element =
      [&](Element* element, const InheritedState& parent_state) -> InheritedState {
        if (!element || !element->IsStyledElement()) {
          return parent_state;
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

        // TODO(CGQAQ): figure out we really need optimize here using inline style.
        auto inline_style = const_cast<Element&>(*element).EnsureMutableInlineStyle();
        auto* ctx = document.GetExecutingContext();

        // If there are no winning declared values for this element, we may still
        // need to emit pseudo styles (e.g., ::before/::after/::first-letter/::first-line)
        // when they have declarations. In that case, ensure any previously-emitted
        // inline overrides are cleared so stale styles (from prior matching sheets)
        // are removed, then emit pseudo styles only and skip element overrides.
        if (!property_set || property_set->IsEmpty()) {
          auto* ctx = document.GetExecutingContext();
          // Only clear when there is no author inline style present. Inline styles
          // are handled via Element::NotifyInlineStyleMutation and should not be
          // cleared by stylesheet recomputation.
          if (!(inline_style && inline_style->PropertyCount() > 0)) {
            ctx->uiCommandBuffer()->AddCommand(UICommand::kClearStyle, nullptr, element->bindingObject(), nullptr);
          }
          auto emit_pseudo_if_any = [&](PseudoId pseudo_id, const char* pseudo_name) {
            ElementRuleCollector pseudo_collector(state, SelectorChecker::kResolvingStyle);
            pseudo_collector.SetPseudoElementStyleRequest(PseudoElementStyleRequest(pseudo_id));
            resolver.CollectAllRules(state, pseudo_collector, /*include_smil_properties*/ false);
            pseudo_collector.SortAndTransferMatchedRules();

            StyleCascade pseudo_cascade(state);
            for (const auto& entry : pseudo_collector.GetMatchResult().GetMatchedProperties()) {
              if (entry.is_inline_style) {
                pseudo_cascade.MutableMatchResult().AddInlineStyleProperties(entry.properties);
              } else {
                pseudo_cascade.MutableMatchResult().AddMatchedProperties(entry.properties, entry.origin, entry.layer_level);
              }
            }

            std::shared_ptr<MutableCSSPropertyValueSet> pseudo_set = pseudo_cascade.ExportWinningPropertySet();
            if (!pseudo_set || pseudo_set->PropertyCount() == 0) return false;

            // Clear then emit each winning property for this pseudo.
            {
              auto pseudo_atom = AtomicString::CreateFromUTF8(pseudo_name);
              auto pseudo_ns = pseudo_atom.ToNativeString();
              ctx->uiCommandBuffer()->AddCommand(UICommand::kClearPseudoStyle, std::move(pseudo_ns),
                                                 element->bindingObject(), nullptr);
            }
            for (unsigned i = 0; i < pseudo_set->PropertyCount(); ++i) {
              auto prop = pseudo_set->PropertyAt(i);
              AtomicString prop_name = prop.Name().ToAtomicString();
              String value_string = pseudo_set->GetPropertyValueWithHint(prop_name, i);
              if (value_string.IsNull()) value_string = String("");
              auto key_ns = prop_name.ToStylePropertyNameNativeString();
              AtomicString value_atom(value_string);
              auto val_ns = value_atom.ToNativeString();
              auto* pair = reinterpret_cast<NativePair*>(dart_malloc(sizeof(NativePair)));
              pair->key = key_ns.release();
              pair->value = val_ns.release();
              auto pseudo_atom = AtomicString::CreateFromUTF8(pseudo_name);
              auto pseudo_ns = pseudo_atom.ToNativeString();
              ctx->uiCommandBuffer()->AddCommand(UICommand::kSetPseudoStyle, std::move(pseudo_ns),
                                                 element->bindingObject(), pair);
            }
            return true;
          };

          bool emitted_any_pseudo = false;
          emitted_any_pseudo |= emit_pseudo_if_any(PseudoId::kPseudoIdBefore, "before");
          emitted_any_pseudo |= emit_pseudo_if_any(PseudoId::kPseudoIdAfter, "after");
          emitted_any_pseudo |= emit_pseudo_if_any(PseudoId::kPseudoIdFirstLetter, "first-letter");
          emitted_any_pseudo |= emit_pseudo_if_any(PseudoId::kPseudoIdFirstLine, "first-line");

          // Regardless of whether we emitted, return parent state since there
          // are no element-level properties to override.
          return parent_state;
        }

        // We do have properties to apply; clear existing inline overrides first
        // so subsequent SetStyle updates replace them deterministically.
        ctx->uiCommandBuffer()->AddCommand(UICommand::kClearStyle, nullptr, element->bindingObject(), nullptr);
        bool cleared = true;

        unsigned count = property_set->PropertyCount();
        InheritedValueMap inherited_values(parent_state.inherited_values);
        CustomVarMap custom_vars(parent_state.custom_vars);
        bool emitted_background_shorthand = false;

        WEBF_COND_LOG(STYLEENGINE, VERBOSE) << "[StyleEngine] Applying styles for element tag='" << element->localName().ToUTF8String()
                          << "' id='" << element->id().ToUTF8String() << "' class='"
                          << element->className().ToUTF8String() << "'";
        // Debug: check if common sizing properties exist
        bool has_width = property_set->HasProperty(CSSPropertyID::kWidth);
        bool has_height = property_set->HasProperty(CSSPropertyID::kHeight);
        WEBF_COND_LOG(STYLEENGINE, VERBOSE) << "[StyleEngine] PropertySet sizing: width=" << (has_width ? "present" : "missing")
                          << ", height=" << (has_height ? "present" : "missing");

        // Pre-scan to collect white-space longhands so we can emit shorthand.
        bool have_ws_collapse = false;
        bool have_text_wrap = false;
        WhiteSpaceCollapse ws_collapse_enum = WhiteSpaceCollapse::kCollapse;  // initial
        TextWrap text_wrap_enum = TextWrap::kWrap;                             // initial

        for (unsigned i = 0; i < count; ++i) {
          auto prop = property_set->PropertyAt(i);
          CSSPropertyID id = prop.Id();
          if (id == CSSPropertyID::kInvalid) continue;
          const auto* value_ptr = prop.Value();
          if (!value_ptr || !(*value_ptr)) continue;
          const CSSValue& value = *(*value_ptr);
          if (id == CSSPropertyID::kWhiteSpaceCollapse) {
            // value.CssTextForSerialization() returns identifiers like "collapse", "preserve", "preserve-breaks", "break-spaces"
            String v = value.CssTextForSerialization();
            std::string sv = v.ToUTF8String();
            if (sv == "collapse") {
              ws_collapse_enum = WhiteSpaceCollapse::kCollapse;
              have_ws_collapse = true;
            } else if (sv == "preserve") {
              ws_collapse_enum = WhiteSpaceCollapse::kPreserve;
              have_ws_collapse = true;
            } else if (sv == "preserve-breaks") {
              ws_collapse_enum = WhiteSpaceCollapse::kPreserveBreaks;
              have_ws_collapse = true;
            } else if (sv == "break-spaces") {
              ws_collapse_enum = WhiteSpaceCollapse::kBreakSpaces;
              have_ws_collapse = true;
            }
          } else if (id == CSSPropertyID::kTextWrap) {
            // value.CssTextForSerialization() returns identifiers like "wrap", "nowrap", "balance", "pretty"
            String v = value.CssTextForSerialization();
            std::string sv = v.ToUTF8String();
            if (sv == "wrap") {
              text_wrap_enum = TextWrap::kWrap;
              have_text_wrap = true;
            } else if (sv == "nowrap") {
              text_wrap_enum = TextWrap::kNoWrap;
              have_text_wrap = true;
            } else if (sv == "balance") {
              text_wrap_enum = TextWrap::kBalance;
              have_text_wrap = true;
            } else if (sv == "pretty") {
              text_wrap_enum = TextWrap::kPretty;
              have_text_wrap = true;
            }
          }
        }

        // Whether we should emit white-space shorthand: if either longhand appears in this set,
        // synthesize a shorthand value to keep Dart side stable.
        bool emit_white_space_shorthand = have_ws_collapse || have_text_wrap;
        // Compute shorthand textual value if possible.
        String white_space_value_str;
        if (emit_white_space_shorthand) {
          // Combine longhands; unspecified ones use initial values.
          EWhiteSpace ws = ToWhiteSpace(ws_collapse_enum, text_wrap_enum);
          // Map to standard keyword when it matches a defined shorthand value.
          switch (ws) {
            case EWhiteSpace::kNormal:
              white_space_value_str = String("normal");
              break;
            case EWhiteSpace::kNowrap:
              white_space_value_str = String("nowrap");
              break;
            case EWhiteSpace::kPre:
              white_space_value_str = String("pre");
              break;
            case EWhiteSpace::kPreLine:
              white_space_value_str = String("pre-line");
              break;
            case EWhiteSpace::kPreWrap:
              white_space_value_str = String("pre-wrap");
              break;
            case EWhiteSpace::kBreakSpaces:
              white_space_value_str = String("break-spaces");
              break;
          }
        }

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
          AtomicString prop_name = prop.Name().ToAtomicString();
          // Use property_set->GetPropertyValueWithHint so property-specific normalizations (e.g. initial) apply.
          String value_string = property_set->GetPropertyValueWithHint(prop_name, i);

          // Forward custom properties (CSS variables) to UI and record them for local substitution.
          // Custom properties are represented with kVariable.
          if (id == CSSPropertyID::kVariable) {
            if (value_string.IsNull()) {
              value_string = String("");
            }
            if (!cleared) {
              WEBF_COND_LOG(STYLEENGINE, VERBOSE) << "[StyleEngine] Clear inline styles before applying variables";
              ctx->uiCommandBuffer()->AddCommand(UICommand::kClearStyle, nullptr, element->bindingObject(), nullptr);
              cleared = true;
            }
            WEBF_COND_LOG(STYLEENGINE, VERBOSE) << "[StyleEngine] Emitting custom property '" << prop_name.ToUTF8String()
                              << "' = '" << value_string.ToUTF8String() << "'";
            AtomicString value_atom_custom(value_string);
            std::unique_ptr<SharedNativeString> args_custom = prop_name.ToStylePropertyNameNativeString();
            ctx->uiCommandBuffer()->AddCommand(UICommand::kSetStyle, std::move(args_custom), element->bindingObject(),
                                               value_atom_custom.ToNativeString().release());
            // Update current custom var map (inheritance: variables inherit by default).
            if (!value_string.IsEmpty()) {
              custom_vars[prop_name] = value_string;
            } else {
              custom_vars.erase(prop_name);
            }
            continue;
          }

          bool is_inherited_property = CSSProperty::Get(id).IsInherited();

          // Pending substitution handling: when a shorthand containing var() was
          // expanded to longhands, the longhand values are CSSPendingSubstitutionValue
          // which serialize to empty strings. Mirror Blink by reusing the
          // original shorthand text with variables resolved. For background,
          // emit the shorthand once to ensure Dart parses a consistent set of
          // longhands.
          if (value.IsPendingSubstitutionValue()) {
            const auto& pending = To<cssvalue::CSSPendingSubstitutionValue>(value);
            WEBF_COND_LOG(STYLEENGINE, VERBOSE) << "[StyleEngine] PendingSubstitution on property '"
                              << prop_name.ToUTF8String() << "' from shorthand '"
                              << CSSProperty::Get(pending.ShorthandPropertyId()).GetPropertyNameString().ToUTF8String()
                              << "'";
            if (!emitted_background_shorthand && pending.ShorthandValue() != nullptr &&
                pending.ShorthandPropertyId() == CSSPropertyID::kBackground) {
              String shorthand_text = pending.ShorthandValue()->CustomCSSText();
              // Sanitize potential trailing tokens.
              size_t brace_pos = shorthand_text.Find('}');
              if (brace_pos < shorthand_text.length()) {
                shorthand_text = shorthand_text.Substring(0, brace_pos);
              }
              size_t semi_pos = shorthand_text.RFind(';');
              if (semi_pos < shorthand_text.length()) {
                shorthand_text = shorthand_text.Substring(0, semi_pos);
              }
              // Resolve var(...) usages using current custom property map.
              // Normalize gradient arguments to insert missing commas in color-stops.
              String resolved = NormalizeGradientArguments(shorthand_text);
              resolved = TrimAsciiWhitespace(resolved);
              // Emit the shorthand 'background' once and skip individual longhands.
              if (!cleared) {
                WEBF_COND_LOG(STYLEENGINE, VERBOSE) << "[StyleEngine] Clear inline styles before applying background shorthand";
                ctx->uiCommandBuffer()->AddCommand(UICommand::kClearStyle, nullptr, element->bindingObject(), nullptr);
                cleared = true;
              }
              WEBF_COND_LOG(STYLEENGINE, VERBOSE) << "[StyleEngine] Emitting shorthand 'background' = '" << resolved.ToUTF8String() << "'";
              auto shorthand_name = "background"_as;
              std::unique_ptr<SharedNativeString> args_bg = shorthand_name.ToStylePropertyNameNativeString();
              ctx->uiCommandBuffer()->AddCommand(UICommand::kSetStyle, std::move(args_bg), element->bindingObject(),
                                                 AtomicString(resolved).ToNativeString().release());
              emitted_background_shorthand = true;
              // After emitting shorthand, allow background-image longhand to emit too as a fallback,
              // but skip other background-* longhands.
              if (id != CSSPropertyID::kBackgroundImage) {
                continue;
              }
            } else if (pending.ShorthandPropertyId() == CSSPropertyID::kBackground && emitted_background_shorthand) {
              if (id != CSSPropertyID::kBackgroundImage) {
                WEBF_COND_LOG(STYLEENGINE, VERBOSE) << "[StyleEngine] Skipping background longhand '" << prop_name.ToUTF8String()
                                  << "' (shorthand already emitted)";
                continue;
              }
            }
            if (id == CSSPropertyID::kBackgroundImage && pending.ShorthandValue() != nullptr) {
              value_string = pending.ShorthandValue()->CustomCSSText();
              size_t brace_pos = value_string.Find('}');
              if (brace_pos < value_string.length()) {
                value_string = value_string.Substring(0, brace_pos);
              }
              size_t semi_pos = value_string.RFind(';');
              if (semi_pos < value_string.length()) {
                value_string = value_string.Substring(0, semi_pos);
              }
              value_string = NormalizeGradientArguments(value_string);
              value_string = TrimAsciiWhitespace(value_string);
              WEBF_COND_LOG(STYLEENGINE, VERBOSE) << "[StyleEngine] Using shorthand text for background-image: "
                                << value_string.ToUTF8String();
            } else {
              continue;
            }
          }

          if (is_inherited_property) {
            if (value.IsInheritedValue() || value.IsUnsetValue() || value.IsRevertValue() ||
                value.IsRevertLayerValue()) {
              auto inherited_it = parent_state.inherited_values.find(id);
              if (inherited_it != parent_state.inherited_values.end()) {
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

          // If we plan to emit shorthand, skip the longhand emissions here.
          if (emit_white_space_shorthand &&
              (id == CSSPropertyID::kWhiteSpaceCollapse || id == CSSPropertyID::kTextWrap)) {
            // Defer to shorthand emission below.
          } else {
            AtomicString value_atom(value_string);
            std::unique_ptr<SharedNativeString> args_01 = prop_name.ToStylePropertyNameNativeString();
            WEBF_COND_LOG(STYLEENGINE, VERBOSE) << "[StyleEngine] Emitting property '" << prop_name.ToUTF8String() << "' = '"
                              << value_string.ToUTF8String() << "'";
            ctx->uiCommandBuffer()->AddCommand(UICommand::kSetStyle, std::move(args_01), element->bindingObject(),
                                               value_atom.ToNativeString().release());
          }
        }

        // Emit white-space shorthand at the end to replace skipped longhands.
        if (emit_white_space_shorthand) {
          auto ws_prop = AtomicString::CreateFromUTF8("white-space");
          auto ws_key = ws_prop.ToStylePropertyNameNativeString();
          AtomicString ws_value_atom(white_space_value_str);
          WEBF_COND_LOG(STYLEENGINE, VERBOSE) << "[StyleEngine] Emitting shorthand 'white-space' = '"
                            << white_space_value_str.ToUTF8String() << "'";
          ctx->uiCommandBuffer()->AddCommand(UICommand::kSetStyle, std::move(ws_key), element->bindingObject(),
                                             ws_value_atom.ToNativeString().release());
        }

        // After applying element styles, collect and emit minimal pseudo styles.
        // We currently emit only the 'content' property for ::before and ::after
        // so that the UI side can create/update pseudo elements as needed.
        auto send_pseudo_for = [&](PseudoId pseudo_id, const char* pseudo_name) {
          ElementRuleCollector pseudo_collector(state, SelectorChecker::kResolvingStyle);
          pseudo_collector.SetPseudoElementStyleRequest(PseudoElementStyleRequest(pseudo_id));
          resolver.CollectAllRules(state, pseudo_collector, /*include_smil_properties*/ false);
          pseudo_collector.SortAndTransferMatchedRules();

          StyleCascade pseudo_cascade(state);
          for (const auto& entry : pseudo_collector.GetMatchResult().GetMatchedProperties()) {
            if (entry.is_inline_style) {
              pseudo_cascade.MutableMatchResult().AddInlineStyleProperties(entry.properties);
            } else {
              pseudo_cascade.MutableMatchResult().AddMatchedProperties(entry.properties, entry.origin, entry.layer_level);
            }
          }

          std::shared_ptr<MutableCSSPropertyValueSet> pseudo_set = pseudo_cascade.ExportWinningPropertySet();
          if (!pseudo_set || pseudo_set->PropertyCount() == 0) return;

          // Clear existing pseudo styles only when we have winners to apply.
          {
            auto pseudo_atom = AtomicString::CreateFromUTF8(pseudo_name);
            auto pseudo_ns = pseudo_atom.ToNativeString();
            ctx->uiCommandBuffer()->AddCommand(UICommand::kClearPseudoStyle, std::move(pseudo_ns),
                                               element->bindingObject(), nullptr);
          }

          for (unsigned i = 0; i < pseudo_set->PropertyCount(); ++i) {
            auto prop = pseudo_set->PropertyAt(i);
            AtomicString prop_name = prop.Name().ToAtomicString();

            String value_string = pseudo_set->GetPropertyValueWithHint(prop_name, i);
            if (value_string.IsNull()) value_string = String("");

            auto key_ns = prop_name.ToStylePropertyNameNativeString();
            AtomicString value_atom(value_string);
            auto val_ns = value_atom.ToNativeString();

            auto* pair = reinterpret_cast<NativePair*>(dart_malloc(sizeof(NativePair)));
            pair->key = key_ns.release();
            pair->value = val_ns.release();

            auto pseudo_atom = AtomicString::CreateFromUTF8(pseudo_name);
            auto pseudo_ns = pseudo_atom.ToNativeString();
            ctx->uiCommandBuffer()->AddCommand(UICommand::kSetPseudoStyle, std::move(pseudo_ns),
                                               element->bindingObject(), pair);
          }
        };

        // Emit for ::before, ::after, ::first-letter and ::first-line
        send_pseudo_for(PseudoId::kPseudoIdBefore, "before");
        send_pseudo_for(PseudoId::kPseudoIdAfter, "after");
        send_pseudo_for(PseudoId::kPseudoIdFirstLetter, "first-letter");
        send_pseudo_for(PseudoId::kPseudoIdFirstLine, "first-line");

        InheritedState next_state;
        next_state.inherited_values = std::move(inherited_values);
        next_state.custom_vars = std::move(custom_vars);
        return next_state;
      };

  std::function<void(Node*, const InheritedState&)> walk =
      [&](Node* node, const InheritedState& inherited_state) {
        if (!node) {
          return;
        }

        InheritedState current_state = inherited_state;
        if (node->IsElementNode()) {
          current_state = apply_for_element(static_cast<Element*>(node), inherited_state);
        }

        for (Node* child = node->firstChild(); child; child = child->nextSibling()) {
          walk(child, current_state);
        }
      };

  walk(document.documentElement(), InheritedState());

  auto end_calc = std::chrono::steady_clock::now();

  WEBF_LOG(INFO) << "[StyleEngine] 11Finished Recalc styles(took " << std::chrono::duration_cast<std::chrono::milliseconds>(end_calc - begin_calc).count() << "ms)";
}

void StyleEngine::RecalcStyleForSubtree(Element& root_element) {
  Document& document = GetDocument();
  if (!document.GetExecutingContext()->isBlinkEnabled()) {
    return;
  }

  auto begin_calc = std::chrono::steady_clock::now();

  std::function<InheritedState(Element*, const InheritedState&)> apply_for_element =
      [&](Element* element, const InheritedState& parent_state) -> InheritedState {
        if (!element || !element->IsStyledElement()) {
          return parent_state;
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
          // Even if there are no element-level winners, clear any previously-sent
          // overrides (to avoid stale styles) and emit pseudo styles if any exist.
          auto* ctx = document.GetExecutingContext();
          if (!(inline_style && inline_style->PropertyCount() > 0)) {
            ctx->uiCommandBuffer()->AddCommand(UICommand::kClearStyle, nullptr, element->bindingObject(), nullptr);
          }
          auto emit_pseudo_if_any = [&](PseudoId pseudo_id, const char* pseudo_name) {
            ElementRuleCollector pseudo_collector(state, SelectorChecker::kResolvingStyle);
            pseudo_collector.SetPseudoElementStyleRequest(PseudoElementStyleRequest(pseudo_id));
            resolver.CollectAllRules(state, pseudo_collector, /*include_smil_properties*/ false);
            pseudo_collector.SortAndTransferMatchedRules();

            StyleCascade pseudo_cascade(state);
            for (const auto& entry : pseudo_collector.GetMatchResult().GetMatchedProperties()) {
              if (entry.is_inline_style) {
                pseudo_cascade.MutableMatchResult().AddInlineStyleProperties(entry.properties);
              } else {
                pseudo_cascade.MutableMatchResult().AddMatchedProperties(entry.properties, entry.origin, entry.layer_level);
              }
            }

            std::shared_ptr<MutableCSSPropertyValueSet> pseudo_set = pseudo_cascade.ExportWinningPropertySet();
            if (!pseudo_set || pseudo_set->PropertyCount() == 0) return false;

            {
              auto pseudo_atom = AtomicString::CreateFromUTF8(pseudo_name);
              auto pseudo_ns = pseudo_atom.ToNativeString();
              ctx->uiCommandBuffer()->AddCommand(UICommand::kClearPseudoStyle, std::move(pseudo_ns),
                                                 element->bindingObject(), nullptr);
            }
            for (unsigned i = 0; i < pseudo_set->PropertyCount(); ++i) {
              auto prop = pseudo_set->PropertyAt(i);
              AtomicString prop_name = prop.Name().ToAtomicString();
              String value_string = pseudo_set->GetPropertyValueWithHint(prop_name, i);
              if (value_string.IsNull()) value_string = String("");
              auto key_ns = prop_name.ToStylePropertyNameNativeString();
              AtomicString value_atom(value_string);
              auto val_ns = value_atom.ToNativeString();
              auto* pair = reinterpret_cast<NativePair*>(dart_malloc(sizeof(NativePair)));
              pair->key = key_ns.release();
              pair->value = val_ns.release();
              auto pseudo_atom = AtomicString::CreateFromUTF8(pseudo_name);
              auto pseudo_ns = pseudo_atom.ToNativeString();
              ctx->uiCommandBuffer()->AddCommand(UICommand::kSetPseudoStyle, std::move(pseudo_ns),
                                                 element->bindingObject(), pair);
            }
            return true;
          };

          (void)emit_pseudo_if_any(PseudoId::kPseudoIdBefore, "before");
          (void)emit_pseudo_if_any(PseudoId::kPseudoIdAfter, "after");
          (void)emit_pseudo_if_any(PseudoId::kPseudoIdFirstLetter, "first-letter");
          (void)emit_pseudo_if_any(PseudoId::kPseudoIdFirstLine, "first-line");

          InheritedState next_state;
          next_state.inherited_values = parent_state.inherited_values;
          next_state.custom_vars = parent_state.custom_vars;
          return next_state;
        }

        auto* ctx = document.GetExecutingContext();
        // Only clear when we actually have properties to apply; otherwise we
        // might clear a previously-sent snapshot and leave the element with no
        // inline overrides (e.g., BODY background), causing incorrect paint.
        ctx->uiCommandBuffer()->AddCommand(UICommand::kClearStyle, nullptr, element->bindingObject(), nullptr);
        bool cleared = true;

        if (!property_set || property_set->IsEmpty()) {
          InheritedState next_state;
          next_state.inherited_values = parent_state.inherited_values;
          next_state.custom_vars = parent_state.custom_vars;
          return next_state;
        }

        unsigned count = property_set->PropertyCount();
        InheritedValueMap inherited_values(parent_state.inherited_values);
        CustomVarMap custom_vars(parent_state.custom_vars);

        // Pre-scan white-space longhands
        bool have_ws_collapse = false;
        bool have_text_wrap = false;
        WhiteSpaceCollapse ws_collapse_enum = WhiteSpaceCollapse::kCollapse;
        TextWrap text_wrap_enum = TextWrap::kWrap;
        for (unsigned i = 0; i < count; ++i) {
          auto prop = property_set->PropertyAt(i);
          CSSPropertyID id = prop.Id();
          if (id == CSSPropertyID::kInvalid) continue;
          const auto* value_ptr = prop.Value();
          if (!value_ptr || !(*value_ptr)) continue;
          const CSSValue& value = *(*value_ptr);
          if (id == CSSPropertyID::kWhiteSpaceCollapse) {
            std::string sv = value.CssTextForSerialization().ToUTF8String();
            if (sv == "collapse") { ws_collapse_enum = WhiteSpaceCollapse::kCollapse; have_ws_collapse = true; }
            else if (sv == "preserve") { ws_collapse_enum = WhiteSpaceCollapse::kPreserve; have_ws_collapse = true; }
            else if (sv == "preserve-breaks") { ws_collapse_enum = WhiteSpaceCollapse::kPreserveBreaks; have_ws_collapse = true; }
            else if (sv == "break-spaces") { ws_collapse_enum = WhiteSpaceCollapse::kBreakSpaces; have_ws_collapse = true; }
          } else if (id == CSSPropertyID::kTextWrap) {
            std::string sv = value.CssTextForSerialization().ToUTF8String();
            if (sv == "wrap") { text_wrap_enum = TextWrap::kWrap; have_text_wrap = true; }
            else if (sv == "nowrap") { text_wrap_enum = TextWrap::kNoWrap; have_text_wrap = true; }
            else if (sv == "balance") { text_wrap_enum = TextWrap::kBalance; have_text_wrap = true; }
            else if (sv == "pretty") { text_wrap_enum = TextWrap::kPretty; have_text_wrap = true; }
          }
        }

        bool emit_white_space_shorthand = have_ws_collapse || have_text_wrap;
        String white_space_value_str;
        if (emit_white_space_shorthand) {
          EWhiteSpace ws = ToWhiteSpace(ws_collapse_enum, text_wrap_enum);
          switch (ws) {
            case EWhiteSpace::kNormal: white_space_value_str = String("normal"); break;
            case EWhiteSpace::kNowrap: white_space_value_str = String("nowrap"); break;
            case EWhiteSpace::kPre: white_space_value_str = String("pre"); break;
            case EWhiteSpace::kPreLine: white_space_value_str = String("pre-line"); break;
            case EWhiteSpace::kPreWrap: white_space_value_str = String("pre-wrap"); break;
            case EWhiteSpace::kBreakSpaces: white_space_value_str = String("break-spaces"); break;
          }
        }

        for (unsigned i = 0; i < count; ++i) {
          auto prop = property_set->PropertyAt(i);
          CSSPropertyID id = prop.Id();
          if (id == CSSPropertyID::kInvalid) continue;
          const auto* value_ptr = prop.Value();
          if (!value_ptr || !(*value_ptr)) continue;

          AtomicString prop_name = prop.Name().ToAtomicString();
          String value_string = property_set->GetPropertyValueWithHint(prop_name, i);
          if (value_string.IsNull()) value_string = String("");

          // Skip white-space longhands; will emit shorthand later
          if (id == CSSPropertyID::kWhiteSpaceCollapse || id == CSSPropertyID::kTextWrap) {
            continue;
          }

          // Already cleared above.
          auto key_ns = prop_name.ToStylePropertyNameNativeString();
          AtomicString value_atom(value_string);
          ctx->uiCommandBuffer()->AddCommand(UICommand::kSetStyle, std::move(key_ns), element->bindingObject(),
                                             value_atom.ToNativeString().release());
        }

        if (emit_white_space_shorthand) {
          // Already cleared above.
          auto ws_prop = AtomicString::CreateFromUTF8("white-space");
          auto ws_key = ws_prop.ToStylePropertyNameNativeString();
          AtomicString ws_value_atom(white_space_value_str);
          ctx->uiCommandBuffer()->AddCommand(UICommand::kSetStyle, std::move(ws_key), element->bindingObject(),
                                             ws_value_atom.ToNativeString().release());
        }

        // Pseudo emission (only minimal content properties as in RecalcStyle)
        auto send_pseudo_for = [&](PseudoId pseudo_id, const char* pseudo_name) {
          ElementRuleCollector pseudo_collector(state, SelectorChecker::kResolvingStyle);
          pseudo_collector.SetPseudoElementStyleRequest(PseudoElementStyleRequest(pseudo_id));
          resolver.CollectAllRules(state, pseudo_collector, /*include_smil_properties*/ false);
          pseudo_collector.SortAndTransferMatchedRules();

          StyleCascade pseudo_cascade(state);
          for (const auto& entry : pseudo_collector.GetMatchResult().GetMatchedProperties()) {
            if (entry.is_inline_style) {
              pseudo_cascade.MutableMatchResult().AddInlineStyleProperties(entry.properties);
            } else {
              pseudo_cascade.MutableMatchResult().AddMatchedProperties(entry.properties, entry.origin, entry.layer_level);
            }
          }

          std::shared_ptr<MutableCSSPropertyValueSet> pseudo_set = pseudo_cascade.ExportWinningPropertySet();
          WEBF_COND_LOG(STYLEENGINE, VERBOSE) << "[StyleEngine] Pseudo '" << pseudo_name << "' count="
                            << (pseudo_set ? static_cast<int>(pseudo_set->PropertyCount()) : -1);
          if (!pseudo_set || pseudo_set->PropertyCount() == 0) return;
          {
            auto pseudo_atom = AtomicString::CreateFromUTF8(pseudo_name);
            auto pseudo_ns = pseudo_atom.ToNativeString();
            ctx->uiCommandBuffer()->AddCommand(UICommand::kClearPseudoStyle, std::move(pseudo_ns),
                                               element->bindingObject(), nullptr);
          }
          for (unsigned i = 0; i < pseudo_set->PropertyCount(); ++i) {
            auto prop = pseudo_set->PropertyAt(i);
            AtomicString prop_name = prop.Name().ToAtomicString();
            String value_string = pseudo_set->GetPropertyValueWithHint(prop_name, i);
            if (value_string.IsNull()) value_string = String("");

            auto key_ns = prop_name.ToStylePropertyNameNativeString();
            AtomicString value_atom(value_string);
            auto val_ns = value_atom.ToNativeString();
            auto* pair = reinterpret_cast<NativePair*>(dart_malloc(sizeof(NativePair)));
            pair->key = key_ns.release();
            pair->value = val_ns.release();

            auto pseudo_atom = AtomicString::CreateFromUTF8(pseudo_name);
            auto pseudo_ns = pseudo_atom.ToNativeString();
            ctx->uiCommandBuffer()->AddCommand(UICommand::kSetPseudoStyle, std::move(pseudo_ns),
                                               element->bindingObject(), pair);
          }
        };

        send_pseudo_for(PseudoId::kPseudoIdBefore, "before");
        send_pseudo_for(PseudoId::kPseudoIdAfter, "after");
        send_pseudo_for(PseudoId::kPseudoIdFirstLetter, "first-letter");
        send_pseudo_for(PseudoId::kPseudoIdFirstLine, "first-line");

        InheritedState next_state;
        next_state.inherited_values = std::move(inherited_values);
        next_state.custom_vars = std::move(custom_vars);
        return next_state;
      };

  std::function<void(Node*, const InheritedState&)> walk =
      [&](Node* node, const InheritedState& inherited_state) {
        if (!node) return;
        InheritedState current_state = inherited_state;
        if (node->IsElementNode()) {
          current_state = apply_for_element(static_cast<Element*>(node), inherited_state);
        }
        for (Node* child = node->firstChild(); child; child = child->nextSibling()) {
          walk(child, current_state);
        }
      };

  InheritedState root_state;
  walk(&root_element, root_state);

  auto end_calc = std::chrono::steady_clock::now();
  WEBF_LOG(INFO) << "[StyleEngine] Finished Recalc subtree styles(took " << std::chrono::duration_cast<std::chrono::milliseconds>(end_calc - begin_calc).count() << "ms)";
}

void StyleEngine::RecalcStyleForElementOnly(Element& element) {
  Document& document = GetDocument();
  if (!document.GetExecutingContext()->isBlinkEnabled()) {
    return;
  }

  auto begin_calc = std::chrono::steady_clock::now();

  // Reuse the same per-element styling logic as RecalcStyleForSubtree, but do
  // not recurse into children and ignore inherited/custom-var accumulation.
  std::function<InheritedState(Element*, const InheritedState&)> apply_for_element =
      [&](Element* el, const InheritedState& parent_state) -> InheritedState {
        if (!el || !el->IsStyledElement()) {
          return parent_state;
        }

        StyleResolver& resolver = EnsureStyleResolver();
        StyleResolverState state(document, *el);
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

        auto inline_style = const_cast<Element&>(*el).EnsureMutableInlineStyle();
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

        auto* ctx = document.GetExecutingContext();

        if (!property_set || property_set->IsEmpty()) {
          if (!(inline_style && inline_style->PropertyCount() > 0)) {
            ctx->uiCommandBuffer()->AddCommand(UICommand::kClearStyle, nullptr, el->bindingObject(), nullptr);
          }

          auto emit_pseudo_if_any = [&](PseudoId pseudo_id, const char* pseudo_name) {
            ElementRuleCollector pseudo_collector(state, SelectorChecker::kResolvingStyle);
            pseudo_collector.SetPseudoElementStyleRequest(PseudoElementStyleRequest(pseudo_id));
            resolver.CollectAllRules(state, pseudo_collector, /*include_smil_properties*/ false);
            pseudo_collector.SortAndTransferMatchedRules();

            StyleCascade pseudo_cascade(state);
            for (const auto& entry : pseudo_collector.GetMatchResult().GetMatchedProperties()) {
              if (entry.is_inline_style) {
                pseudo_cascade.MutableMatchResult().AddInlineStyleProperties(entry.properties);
              } else {
                pseudo_cascade.MutableMatchResult().AddMatchedProperties(entry.properties, entry.origin, entry.layer_level);
              }
            }

            std::shared_ptr<MutableCSSPropertyValueSet> pseudo_set = pseudo_cascade.ExportWinningPropertySet();
            if (!pseudo_set || pseudo_set->PropertyCount() == 0) return false;

            auto pseudo_atom = AtomicString::CreateFromUTF8(pseudo_name);
            auto pseudo_ns = pseudo_atom.ToNativeString();
            ctx->uiCommandBuffer()->AddCommand(UICommand::kClearPseudoStyle, std::move(pseudo_ns),
                                               el->bindingObject(), nullptr);
            for (unsigned i = 0; i < pseudo_set->PropertyCount(); ++i) {
              auto prop = pseudo_set->PropertyAt(i);
              AtomicString prop_name = prop.Name().ToAtomicString();
              String value_string = pseudo_set->GetPropertyValueWithHint(prop_name, i);
              if (value_string.IsNull()) value_string = String("");
              auto key_ns = prop_name.ToStylePropertyNameNativeString();
              AtomicString value_atom(value_string);
              auto val_ns = value_atom.ToNativeString();
              auto* pair = reinterpret_cast<NativePair*>(dart_malloc(sizeof(NativePair)));
              pair->key = key_ns.release();
              pair->value = val_ns.release();

              auto pseudo_atom2 = AtomicString::CreateFromUTF8(pseudo_name);
              auto pseudo_ns2 = pseudo_atom2.ToNativeString();
              ctx->uiCommandBuffer()->AddCommand(UICommand::kSetPseudoStyle, std::move(pseudo_ns2),
                                                 el->bindingObject(), pair);
            }
            return true;
          };

          (void)emit_pseudo_if_any(PseudoId::kPseudoIdBefore, "before");
          (void)emit_pseudo_if_any(PseudoId::kPseudoIdAfter, "after");
          (void)emit_pseudo_if_any(PseudoId::kPseudoIdFirstLetter, "first-letter");
          (void)emit_pseudo_if_any(PseudoId::kPseudoIdFirstLine, "first-line");

          InheritedState next_state;
          next_state.inherited_values = parent_state.inherited_values;
          next_state.custom_vars = parent_state.custom_vars;
          return next_state;
        }

        // We have properties to apply. Clear existing overrides and emit winners.
        ctx->uiCommandBuffer()->AddCommand(UICommand::kClearStyle, nullptr, el->bindingObject(), nullptr);

        unsigned count = property_set->PropertyCount();
        InheritedValueMap inherited_values(parent_state.inherited_values);
        CustomVarMap custom_vars(parent_state.custom_vars);

        bool have_ws_collapse = false;
        bool have_text_wrap = false;
        WhiteSpaceCollapse ws_collapse_enum = WhiteSpaceCollapse::kCollapse;
        TextWrap text_wrap_enum = TextWrap::kWrap;
        for (unsigned i = 0; i < count; ++i) {
          auto prop = property_set->PropertyAt(i);
          CSSPropertyID id = prop.Id();
          if (id == CSSPropertyID::kInvalid) continue;
          const auto* value_ptr = prop.Value();
          if (!value_ptr || !(*value_ptr)) continue;
          const CSSValue& value = *(*value_ptr);
          if (id == CSSPropertyID::kWhiteSpaceCollapse) {
            std::string sv = value.CssTextForSerialization().ToUTF8String();
            if (sv == "collapse") { ws_collapse_enum = WhiteSpaceCollapse::kCollapse; have_ws_collapse = true; }
            else if (sv == "preserve") { ws_collapse_enum = WhiteSpaceCollapse::kPreserve; have_ws_collapse = true; }
            else if (sv == "preserve-breaks") { ws_collapse_enum = WhiteSpaceCollapse::kPreserveBreaks; have_ws_collapse = true; }
            else if (sv == "break-spaces") { ws_collapse_enum = WhiteSpaceCollapse::kBreakSpaces; have_ws_collapse = true; }
          } else if (id == CSSPropertyID::kTextWrap) {
            std::string sv = value.CssTextForSerialization().ToUTF8String();
            if (sv == "wrap") { text_wrap_enum = TextWrap::kWrap; have_text_wrap = true; }
            else if (sv == "nowrap") { text_wrap_enum = TextWrap::kNoWrap; have_text_wrap = true; }
            else if (sv == "balance") { text_wrap_enum = TextWrap::kBalance; have_text_wrap = true; }
            else if (sv == "pretty") { text_wrap_enum = TextWrap::kPretty; have_text_wrap = true; }
          }
        }

        bool emit_white_space_shorthand = have_ws_collapse || have_text_wrap;
        String white_space_value_str;
        if (emit_white_space_shorthand) {
          EWhiteSpace ws = ToWhiteSpace(ws_collapse_enum, text_wrap_enum);
          switch (ws) {
            case EWhiteSpace::kNormal: white_space_value_str = String("normal"); break;
            case EWhiteSpace::kNowrap: white_space_value_str = String("nowrap"); break;
            case EWhiteSpace::kPre: white_space_value_str = String("pre"); break;
            case EWhiteSpace::kPreLine: white_space_value_str = String("pre-line"); break;
            case EWhiteSpace::kPreWrap: white_space_value_str = String("pre-wrap"); break;
            case EWhiteSpace::kBreakSpaces: white_space_value_str = String("break-spaces"); break;
          }
        }

        for (unsigned i = 0; i < count; ++i) {
          auto prop = property_set->PropertyAt(i);
          CSSPropertyID id = prop.Id();
          if (id == CSSPropertyID::kInvalid) continue;
          const auto* value_ptr = prop.Value();
          if (!value_ptr || !(*value_ptr)) continue;

          AtomicString prop_name = prop.Name().ToAtomicString();
          String value_string = property_set->GetPropertyValueWithHint(prop_name, i);
          if (value_string.IsNull()) value_string = String("");

          if (id == CSSPropertyID::kWhiteSpaceCollapse || id == CSSPropertyID::kTextWrap) {
            continue;
          }

          auto key_ns = prop_name.ToStylePropertyNameNativeString();
          AtomicString value_atom(value_string);
          ctx->uiCommandBuffer()->AddCommand(UICommand::kSetStyle, std::move(key_ns), el->bindingObject(),
                                             value_atom.ToNativeString().release());
        }

        if (emit_white_space_shorthand) {
          auto ws_prop = AtomicString::CreateFromUTF8("white-space");
          auto ws_key = ws_prop.ToStylePropertyNameNativeString();
          AtomicString ws_value_atom(white_space_value_str);
          ctx->uiCommandBuffer()->AddCommand(UICommand::kSetStyle, std::move(ws_key), el->bindingObject(),
                                             ws_value_atom.ToNativeString().release());
        }

        auto send_pseudo_for = [&](PseudoId pseudo_id, const char* pseudo_name) {
          ElementRuleCollector pseudo_collector(state, SelectorChecker::kResolvingStyle);
          pseudo_collector.SetPseudoElementStyleRequest(PseudoElementStyleRequest(pseudo_id));
          resolver.CollectAllRules(state, pseudo_collector, /*include_smil_properties*/ false);
          pseudo_collector.SortAndTransferMatchedRules();

          StyleCascade pseudo_cascade(state);
          for (const auto& entry : pseudo_collector.GetMatchResult().GetMatchedProperties()) {
            if (entry.is_inline_style) {
              pseudo_cascade.MutableMatchResult().AddInlineStyleProperties(entry.properties);
            } else {
              pseudo_cascade.MutableMatchResult().AddMatchedProperties(entry.properties, entry.origin, entry.layer_level);
            }
          }

          std::shared_ptr<MutableCSSPropertyValueSet> pseudo_set = pseudo_cascade.ExportWinningPropertySet();
          if (!pseudo_set || pseudo_set->PropertyCount() == 0) return;

          auto pseudo_atom = AtomicString::CreateFromUTF8(pseudo_name);
          auto pseudo_ns = pseudo_atom.ToNativeString();
          ctx->uiCommandBuffer()->AddCommand(UICommand::kClearPseudoStyle, std::move(pseudo_ns),
                                             el->bindingObject(), nullptr);
          for (unsigned i = 0; i < pseudo_set->PropertyCount(); ++i) {
            auto prop = pseudo_set->PropertyAt(i);
            AtomicString prop_name = prop.Name().ToAtomicString();
            String value_string = pseudo_set->GetPropertyValueWithHint(prop_name, i);
            if (value_string.IsNull()) value_string = String("");

            auto key_ns = prop_name.ToStylePropertyNameNativeString();
            AtomicString value_atom(value_string);
            auto val_ns = value_atom.ToNativeString();
            auto* pair = reinterpret_cast<NativePair*>(dart_malloc(sizeof(NativePair)));
            pair->key = key_ns.release();
            pair->value = val_ns.release();

            auto pseudo_atom2 = AtomicString::CreateFromUTF8(pseudo_name);
            auto pseudo_ns2 = pseudo_atom2.ToNativeString();
            ctx->uiCommandBuffer()->AddCommand(UICommand::kSetPseudoStyle, std::move(pseudo_ns2),
                                               el->bindingObject(), pair);
          }
        };

        send_pseudo_for(PseudoId::kPseudoIdBefore, "before");
        send_pseudo_for(PseudoId::kPseudoIdAfter, "after");
        send_pseudo_for(PseudoId::kPseudoIdFirstLetter, "first-letter");
        send_pseudo_for(PseudoId::kPseudoIdFirstLine, "first-line");

        InheritedState next_state;
        next_state.inherited_values = std::move(inherited_values);
        next_state.custom_vars = std::move(custom_vars);
        return next_state;
      };

  InheritedState empty_state;
  apply_for_element(&element, empty_state);

  auto end_calc = std::chrono::steady_clock::now();
  WEBF_LOG(INFO) << "[StyleEngine] Finished Recalc element-only styles(took "
                 << std::chrono::duration_cast<std::chrono::milliseconds>(end_calc - begin_calc).count() << "ms)";
}

void StyleEngine::RecalcInvalidatedStyles(Document& document) {
  auto begin_calc = std::chrono::steady_clock::now();
  ExecutingContext* context = document.GetExecutingContext();
  if (!context || !context->isBlinkEnabled()) {
    return;
  }

  Element* root = document.documentElement();
  if (!root) {
    return;
  }

  PendingInvalidationMap& map = pending_invalidations_.GetPendingInvalidationMap();

  if (map.empty() && !document.NeedsStyleInvalidation() && !document.ChildNeedsStyleInvalidation()) {
    // Nothing scheduled via selector-based invalidation; nothing to do.
    return;
  }

  // First, run the StyleInvalidator to translate InvalidationSets into
  // StyleChangeType flags on individual elements.
  {
    StyleInvalidator invalidator(map);
    invalidator.Invalidate(document, root);
  }

  // Then, walk the DOM starting at the document element and perform subtree
  // style recomputation only for elements that have been marked dirty.
  std::function<void(Node*)> clear_flags_for_subtree = [&](Node* node) {
    if (!node) {
      return;
    }
    node->ClearNeedsStyleRecalc();
    node->ClearChildNeedsStyleRecalc();
    for (Node* child = node->firstChild(); child; child = child->nextSibling()) {
      clear_flags_for_subtree(child);
    }
  };

  std::function<void(Node*)> walk = [&](Node* node) {
    if (!node) {
      return;
    }

    if (node->IsElementNode()) {
      Element* element = static_cast<Element*>(node);
      if (element->NeedsStyleRecalc()) {
        StyleChangeType change_type = element->GetStyleChangeType();
        if (change_type == kInlineIndependentStyleChange) {
          // Inline-only independent style changes affect this element but not
          // its descendants. Recompute style just for this element to keep
          // selector results in sync with the rest of the pipeline.
          RecalcStyleForElementOnly(*element);
          element->ClearNeedsStyleRecalc();
        } else {
          // For local or subtree changes, recompute styles for this element and
          // its descendants and then clear dirty bits in that subtree.
          RecalcStyleForSubtree(*element);
          clear_flags_for_subtree(element);
          return;
        }
      }
    }

    for (Node* child = node->firstChild(); child; child = child->nextSibling()) {
      walk(child);
    }
  };

  walk(root);

  auto end_calc = std::chrono::steady_clock::now();
  WEBF_LOG(INFO) << "[StyleEngine] Finished RecalcInvalidatedStyles(took " << std::chrono::duration_cast<std::chrono::milliseconds>(end_calc - begin_calc).count() << "ms)";
}

void StyleEngine::MediaQueryAffectingValueChanged(MediaValueChange change) {
  Document& document = GetDocument();
  ExecutingContext* context = document.GetExecutingContext();
  if (!context || !context->IsContextValid() || !context->isBlinkEnabled()) {
    return;
  }

  // Clear cached RuleSets for any author stylesheets that contain media
  // queries so they will be rebuilt with a fresh MediaValues snapshot
  // (including the updated environment input) the next time styles are
  // resolved.
  for (const auto& contents : author_sheets_) {
    if (!contents) {
      continue;
    }
    // For now we conservatively clear rule sets for all author
    // stylesheets whenever an environment-dependent media value
    // changes so that their media queries are re-evaluated using
    // fresh MediaValues snapshots.
    contents->ClearRuleSet();
  }

  // Also clear cached RuleSets for any style sheets cached by text
  // (typically inline <style> elements). These contents may be reused
  // across multiple HTMLStyleElement instances, so we must ensure their
  // media queries (including prefers-color-scheme) are re-evaluated
  // against the updated MediaValues on the next style resolution.
  for (auto& entry : text_to_sheet_cache_) {
    const auto& contents = entry.second;
    if (contents) {
      contents->ClearRuleSet();
    }
  }

  // Additionally, walk the DOM to clear RuleSets for any inline
  // <style> elements whose contents are not in the shared text cache.
  // This ensures dynamically created inline stylesheets also respond
  // to environment-dependent media value changes such as
  // prefers-color-scheme.
  Element* root_element = document.documentElement();
  if (root_element) {
    std::function<void(Node*)> walk = [&](Node* node) {
      if (!node) {
        return;
      }

      if (node->IsElementNode()) {
        Element* elem = static_cast<Element*>(node);
        if (elem->HasTagName(html_names::kStyle)) {
          auto* html_style = static_cast<HTMLStyleElement*>(elem);
          CSSStyleSheet* sheet = html_style->sheet();
          if (sheet) {
            auto contents = sheet->Contents();
            if (contents) {
              contents->ClearRuleSet();
            }
          }
        }
      }

      for (Node* child = node->firstChild(); child; child = child->nextSibling()) {
        walk(child);
      }
    };
    walk(root_element);
  }

  // For now we conservatively trigger a full style recomputation for any
  // media-value change. This ensures viewport- and device-dependent media
  // queries are re-evaluated using up-to-date environment values provided
  // by the Dart side (viewport size, devicePixelRatio, colorScheme, etc.).
  switch (change) {
    case MediaValueChange::kSize:
    case MediaValueChange::kDynamicViewport:
    case MediaValueChange::kOther:
      RecalcStyle(document);
      break;
  }
}

void StyleEngine::Trace(GCVisitor* visitor) {}

}  // namespace webf
