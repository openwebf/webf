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
#include <unordered_set>
#include "core/css/invalidation/invalidation_set.h"
#include "core/css/css_property_name.h"
#include "core/css/css_property_value_set.h"
#include "core/css/css_style_sheet.h"
#include "core/css/css_value.h"
#include "core/css/media_query_evaluator.h"
#include "core/css/style_rule_import.h"
#include "core/css/style_sheet_contents.h"
#include "core/css/style_rule.h"
#include "core/css/properties/css_property.h"
#include "core/css/resolver/style_resolver.h"
#include "core/dom/attribute.h"
#include "core/dom/document.h"
#include "core/dom/element.h"
#include "core/dom/element_traversal.h"
#include "core/css/element_rule_collector.h"
#include "core/css/resolver/style_resolver_state.h"
#include "core/css/resolver/style_cascade.h"
// StyleRecalcChange / StyleRecalcContext API surface (Blink-style).
#include "core/css/style_recalc_change.h"
#include "core/css/style_recalc_context.h"
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
#include "core/css/resolver/media_query_result.h"
#include "core/css/style_rule_keyframe.h"
#include "core/css/invalidation/style_invalidator.h"
#include "core/dom/container_node.h"
#include "core/dom/node_traversal.h"
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

// Collect size-dependent media query evaluation results from a single
// StyleSheetContents into |out_results| using the provided |evaluator|.
// This walks @media rules (including nested group rules) as well as supported
// @import rules (recursively) and records only queries whose evaluation depends
// on viewport or device size. The order of results is deterministic for a given
// stylesheet, which lets MediaQueryAffectingValueChanged compare consecutive
// snapshots cheaply.
static void CollectSizeDependentMediaQueryResults(
    StyleSheetContents& contents,
    const MediaQueryEvaluator& evaluator,
    std::vector<MediaQuerySetResult>& out_results,
    std::unordered_set<const StyleSheetContents*>& visited) {
  if (!visited.insert(&contents).second) {
    return;
  }

  auto is_size_dependent = [](const MediaQueryResultFlags& flags) -> bool {
    return flags.is_viewport_dependent || flags.is_device_dependent;
  };

  auto collect_from_child_vector =
      [&](const StyleRuleBase::ChildRuleVector& child_rules, const auto& self_ref) -> void {
    uint32_t count = child_rules.size();
    for (uint32_t i = 0; i < count; ++i) {
      const std::shared_ptr<const StyleRuleBase>& base_rule_const = child_rules[i];
      if (!base_rule_const) {
        continue;
      }
      StyleRuleBase* base_rule = const_cast<StyleRuleBase*>(base_rule_const.get());

      if (base_rule->IsMediaRule()) {
        auto* media_rule = DynamicTo<StyleRuleMedia>(base_rule);
        if (media_rule) {
          std::shared_ptr<const MediaQuerySet> queries = media_rule->MediaQueriesShared();
          if (queries) {
            MediaQueryResultFlags flags;
            bool match = evaluator.Eval(*queries, &flags);
            if (is_size_dependent(flags)) {
              out_results.emplace_back(std::move(queries), match);
            }
          }
          self_ref(media_rule->ChildRules(), self_ref);
          continue;
        }
      }

      if (auto* group_rule = DynamicTo<StyleRuleGroup>(base_rule)) {
        self_ref(group_rule->ChildRules(), self_ref);
      }
    }
  };

  if (contents.HasMediaQueries()) {
    const auto& top_rules = contents.ChildRules();
    for (const auto& base_rule : top_rules) {
      if (!base_rule) {
        continue;
      }
      StyleRuleBase* rule = base_rule.get();
      if (rule->IsMediaRule()) {
        auto* media_rule = DynamicTo<StyleRuleMedia>(rule);
        if (media_rule) {
          std::shared_ptr<const MediaQuerySet> queries = media_rule->MediaQueriesShared();
          if (queries) {
            MediaQueryResultFlags flags;
            bool match = evaluator.Eval(*queries, &flags);
            if (is_size_dependent(flags)) {
              out_results.emplace_back(std::move(queries), match);
            }
          }
          collect_from_child_vector(media_rule->ChildRules(), collect_from_child_vector);
          continue;
        }
      }

      if (auto* group_rule = DynamicTo<StyleRuleGroup>(rule)) {
        collect_from_child_vector(group_rule->ChildRules(), collect_from_child_vector);
      }
    }
  }

  // Include @import conditions and recurse into imported sheets when the
  // import is currently active (i.e. supported + matching media).
  for (const auto& import_rule : contents.ImportRules()) {
    if (!import_rule || !import_rule->IsSupported()) {
      continue;
    }

    std::shared_ptr<const MediaQuerySet> queries = import_rule->MediaQueries();
    MediaQueryResultFlags flags;
    bool match = true;
    if (queries) {
      match = evaluator.Eval(*queries, &flags);
      if (is_size_dependent(flags)) {
        out_results.emplace_back(std::move(queries), match);
      }
    }

    if (!match) {
      continue;
    }

    std::shared_ptr<StyleSheetContents> child = import_rule->GetStyleSheet();
    if (child) {
      CollectSizeDependentMediaQueryResults(*child, evaluator, out_results, visited);
    }
  }
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
            // Preserve original family name casing to match the value used by style resolution on Dart side.
            std::string familyUtf8 = family.ToUTF8String();
            std::string srcUtf8 = src.ToUTF8String();
            if (srcUtf8.size() > 160) srcUtf8 = srcUtf8.substr(0, 160) + "…";
            auto baseHrefNative = stringToNativeString(base_href).release();
            auto familyNative = stringToNativeString(familyUtf8).release();
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
          auto group = std::static_pointer_cast<const StyleRuleGroup>(r);
          const auto& children = group->ChildRules();
          std::vector<std::shared_ptr<const StyleRuleBase>> nested;
          nested.reserve(children.size());
          for (size_t i = 0; i < children.size(); ++i) nested.push_back(children[i]);
          walk(nested);
        }
      }
    };
    walk(childVec);
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
            auto baseHrefNative = stringToNativeString(baseHrefStr).release();
            auto familyNative = stringToNativeString(family.ToUTF8String()).release();
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
          auto baseHrefNative = stringToNativeString(baseHrefStr).release();
          auto familyNative = stringToNativeString(family.ToUTF8String()).release();
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
  Document& document = GetDocument();
  ExecutingContext* context = document.GetExecutingContext();
  if (!context || !context->isBlinkEnabled()) {
    return;
  }

  MemberMutationScope scope{context};

  // When tearing down a DOM subtree, Blink falls back to using the document
  // itself as the invalidation root so that subsequent SubtreeModified()
  // calls can clear breadcrumbs correctly. Mirror that behavior here.
  if (InDOMRemoval()) {
    ancestor = nullptr;
    dirty_node = &document;
  }

  style_invalidation_root_.Update(ancestor, dirty_node);
}

void StyleEngine::UpdateStyleRecalcRoot(ContainerNode* ancestor, Node* dirty_node) {
  Document& document = GetDocument();
  ExecutingContext* context = document.GetExecutingContext();
  if (!context || !context->isBlinkEnabled()) {
    return;
  }

  MemberMutationScope scope{context};

  // During style recalc we may mark nodes dirty from inside the traversal
  // (e.g., layout-driven updates). In that case Blink skips updating the
  // StyleRecalcRoot and relies on the current traversal to visit the node.
  if (document.InStyleRecalc()) {
    assert(allow_mark_style_dirty_from_recalc_);
    return;
  }

  // If we're tearing down the DOM subtree, treat the document as the root so
  // that subsequent SubtreeModified() calls can clear breadcrumbs correctly.
  if (InDOMRemoval()) {
    ancestor = nullptr;
    dirty_node = &document;
  }

  style_recalc_root_.Update(ancestor, dirty_node);
}

void StyleEngine::ScheduleNthPseudoInvalidations(ContainerNode& nth_parent) {
  Document& document = GetDocument();
  ExecutingContext* context = document.GetExecutingContext();
  if (!context || !context->isBlinkEnabled()) {
    return;
  }
  if (!global_rule_set_) {
    return;
  }
  if (document.InStyleRecalc()) {
    return;
  }

  global_rule_set_->Update(document);
  InvalidationLists invalidation_lists;
  global_rule_set_->GetRuleFeatureSet().CollectNthInvalidationSet(invalidation_lists);
  pending_invalidations_.ScheduleInvalidationSetsForNode(invalidation_lists, nth_parent);
}

void StyleEngine::ScheduleSiblingInvalidationsForElement(Element& element,
                                                         ContainerNode& scheduling_parent,
                                                         unsigned min_direct_adjacent) {
  assert(min_direct_adjacent);

  Document& document = GetDocument();
  ExecutingContext* context = document.GetExecutingContext();
  if (!context || !context->isBlinkEnabled()) {
    return;
  }
  if (!global_rule_set_) {
    return;
  }
  if (&element.GetDocument() != &document) {
    return;
  }
  if (document.InStyleRecalc()) {
    return;
  }

  global_rule_set_->Update(document);
  const RuleFeatureSet& features = global_rule_set_->GetRuleFeatureSet();

  InvalidationLists invalidation_lists;

  if (element.HasID()) {
    features.CollectSiblingInvalidationSetForId(invalidation_lists, element, element.IdForStyleResolution(),
                                                min_direct_adjacent);
  }

  if (element.HasClass()) {
    const SpaceSplitString& class_names = element.ClassNames();
    for (const AtomicString& class_name : class_names) {
      features.CollectSiblingInvalidationSetForClass(invalidation_lists, element, class_name, min_direct_adjacent);
    }
  }

  for (const Attribute& attribute : element.Attributes()) {
    features.CollectSiblingInvalidationSetForAttribute(invalidation_lists, element, attribute.GetName(),
                                                       min_direct_adjacent);
  }

  features.CollectUniversalSiblingInvalidationSet(invalidation_lists, min_direct_adjacent);

  pending_invalidations_.ScheduleSiblingInvalidationsAsDescendants(invalidation_lists, scheduling_parent);
}

void StyleEngine::ScheduleInvalidationsForInsertedSibling(Element* before_element, Element& inserted_element) {
  Document& document = GetDocument();
  ExecutingContext* context = document.GetExecutingContext();
  if (!context || !context->isBlinkEnabled()) {
    return;
  }
  if (!global_rule_set_) {
    return;
  }
  if (&inserted_element.GetDocument() != &document) {
    return;
  }
  if (document.InStyleRecalc()) {
    return;
  }

  ContainerNode* parent = inserted_element.parentNode();
  if (!parent) {
    return;
  }

  global_rule_set_->Update(document);
  const RuleFeatureSet& features = global_rule_set_->GetRuleFeatureSet();

  unsigned affected_siblings =
      parent->ChildrenAffectedByIndirectAdjacentRules() ? SiblingInvalidationSet::kDirectAdjacentMax
                                                        : features.MaxDirectAdjacentSelectors();

  ContainerNode* scheduling_parent = inserted_element.ParentElementOrShadowRoot();
  if (!scheduling_parent) {
    return;
  }

  ScheduleSiblingInvalidationsForElement(inserted_element, *scheduling_parent, 1);

  for (unsigned i = 1; before_element && i <= affected_siblings;
       i++, before_element = ElementTraversal::PreviousSibling(*before_element)) {
    ScheduleSiblingInvalidationsForElement(*before_element, *scheduling_parent, i);
  }
}

void StyleEngine::ScheduleInvalidationsForRemovedSibling(Element* before_element,
                                                         Element& removed_element,
                                                         Element& after_element) {
  Document& document = GetDocument();
  ExecutingContext* context = document.GetExecutingContext();
  if (!context || !context->isBlinkEnabled()) {
    return;
  }
  if (!global_rule_set_) {
    return;
  }
  if (&after_element.GetDocument() != &document || &removed_element.GetDocument() != &document) {
    return;
  }
  if (document.InStyleRecalc()) {
    return;
  }

  ContainerNode* parent = after_element.parentNode();
  if (!parent) {
    return;
  }

  global_rule_set_->Update(document);
  const RuleFeatureSet& features = global_rule_set_->GetRuleFeatureSet();

  unsigned affected_siblings =
      parent->ChildrenAffectedByIndirectAdjacentRules() ? SiblingInvalidationSet::kDirectAdjacentMax
                                                        : features.MaxDirectAdjacentSelectors();

  ContainerNode* scheduling_parent = after_element.ParentElementOrShadowRoot();
  if (!scheduling_parent) {
    return;
  }

  ScheduleSiblingInvalidationsForElement(removed_element, *scheduling_parent, 1);

  for (unsigned i = 1; before_element && i <= affected_siblings;
       i++, before_element = ElementTraversal::PreviousSibling(*before_element)) {
    ScheduleSiblingInvalidationsForElement(*before_element, *scheduling_parent, i);
  }
}

bool StyleEngine::ShouldSkipInvalidationFor(const Element& element) const {
  // Only schedule invalidations using the StyleEngine of the Document that
  // owns the element.
  if (&element.GetDocument() != &GetDocument()) {
    return true;
  }
  // Never schedule selector-based invalidations for elements that are not in
  // the active document. PendingInvalidations expects ContainerNode to return
  // true from InActiveDocument().
  if (!element.InActiveDocument()) {
    return true;
  }
  // Avoid scheduling new invalidations while we are already inside a style
  // recalc traversal; those marks will be picked up by the ongoing walk.
  if (GetDocument().InStyleRecalc()) {
    return true;
  }
  return false;
}

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

void StyleEngine::InvalidateStyle() {
  // Mirror Blink's StyleEngine::InvalidateStyle at a high level: use
  // StyleInvalidator to translate PendingInvalidations into per-element
  // style-change flags, starting from the current invalidation root.
  PendingInvalidationMap& map = pending_invalidations_.GetPendingInvalidationMap();
  if (map.empty() && !GetDocument().NeedsStyleInvalidation() && !GetDocument().ChildNeedsStyleInvalidation()) {
    return;
  }

  StyleInvalidator style_invalidator(map);
  style_invalidator.Invalidate(GetDocument(), style_invalidation_root_.RootElement());
  style_invalidation_root_.Clear();
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

void StyleEngine::UpdateActiveStyle() {
  Document& document = GetDocument();
  ExecutingContext* context = document.GetExecutingContext();
  if (!context || !context->isBlinkEnabled()) {
    return;
  }

  // In Blink this also updates viewport and per-TreeScope active stylesheet
  // collections. WebF currently tracks author stylesheets incrementally via
  // RegisterAuthorSheet / UnregisterAuthorSheet and uses CSSGlobalRuleSet to
  // aggregate selector / invalidation metadata. Refresh that metadata here so
  // subsequent invalidation passes see the latest rules.
  if (global_rule_set_) {
    global_rule_set_->Update(document);
  }
}

void StyleEngine::SetNeedsActiveStyleUpdate() {
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

  // Any structural change to the active stylesheet set (insert/remove/modify
  // <style> / <link rel=stylesheet>) invalidates the cached media query
  // evaluation snapshot used for size-change gating. The next
  // MediaQueryAffectingValueChanged(kSize) call will rebuild it.
  size_media_query_results_.clear();

  // Treat any change to the active stylesheet set (add/remove/modify <style>
  // or <link rel=stylesheet>) as potentially affecting the entire document.
  // Mark the root subtree as needing style recalc; RecalcStyle() will
  // recompute styles starting from here on the next frame/flush.
  root->SetNeedsStyleRecalc(
      kSubtreeStyleChange,
      StyleChangeReasonForTracing::Create(style_change_reason::kActiveStylesheetsUpdate));

  // Also mark the document as having pending style invalidation work so that
  // StyleInvalidator is invoked even if no selector-based invalidation sets
  // have been scheduled yet.
  document.SetNeedsStyleInvalidation();
}

void StyleEngine::InvalidateViewportUnitStylesIfNeeded() {
  Document& document = GetDocument();
  ExecutingContext* context = document.GetExecutingContext();
  if (!context || !context->isBlinkEnabled()) {
    return;
  }

  // Unlike Blink, WebF does not yet track per-element viewport-unit usage in
  // computed styles. Viewport-driven style changes (e.g. media queries using
  // viewport units) are currently handled via MediaQueryAffectingValueChanged,
  // which may trigger a full RecalcStyle when needed. This hook is kept for
  // API compatibility with Blink's style update pipeline and can be extended
  // to perform targeted invalidation when viewport-unit tracking is wired up.
}

void StyleEngine::InvalidateEnvDependentStylesIfNeeded() {
  Document& document = GetDocument();
  ExecutingContext* context = document.GetExecutingContext();
  if (!context || !context->isBlinkEnabled()) {
    return;
  }

  // Blink uses this to invalidate styles that depend on env() variables such
  // as safe-area insets. WebF's style engine does not yet track such
  // dependencies separately; environment-driven changes currently go through
  // MediaQueryAffectingValueChanged and full style recomputation as needed.
  // This no-op keeps the call graph compatible with Blink and provides a
  // natural place to add more granular invalidation later.
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

  if (ShouldSkipInvalidationFor(element)) {
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

  if (ShouldSkipInvalidationFor(element)) {
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

  if (ShouldSkipInvalidationFor(element)) {
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

void StyleEngine::RecalcStyleForSubtree(Element& root_element) {
  Document& document = GetDocument();
  if (!document.GetExecutingContext()->isBlinkEnabled()) {
    return;
  }

  std::function<InheritedState(Element*, const InheritedState&)> apply_for_element =
      [&](Element* element, const InheritedState& parent_state) -> InheritedState {
        if (!element || !element->IsStyledElement()) {
          return parent_state;
        }

        StyleResolver& resolver = EnsureStyleResolver();
        StyleResolverState state(document, *element);
        ElementRuleCollector collector(state, SelectorChecker::kResolvingStyle);
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
              CSSPropertyID id = prop.Id();
              if (id == CSSPropertyID::kInvalid) {
                continue;
              }
              const auto* value_ptr = prop.Value();
              if (!value_ptr || !(*value_ptr)) {
                continue;
              }
              AtomicString prop_name = prop.Name().ToAtomicString();
              String value_string = pseudo_set->GetPropertyValueWithHint(prop_name, i);
              if (value_string.IsNull()) {
                value_string = (*value_ptr)->CssTextForSerialization();
              }
              String base_href_string = pseudo_set->GetPropertyBaseHrefWithHint(prop_name, i);
              auto key_ns = prop_name.ToStylePropertyNameNativeString();
              auto* payload =
                  reinterpret_cast<NativePseudoStyleWithHref*>(dart_malloc(sizeof(NativePseudoStyleWithHref)));
              payload->key = key_ns.release();
              payload->value = stringToNativeString(value_string).release();
              if (!base_href_string.IsEmpty()) {
                payload->href = stringToNativeString(base_href_string.ToUTF8String()).release();
              } else {
                payload->href = nullptr;
              }
              auto pseudo_atom = AtomicString::CreateFromUTF8(pseudo_name);
              auto pseudo_ns = pseudo_atom.ToNativeString();
              ctx->uiCommandBuffer()->AddCommand(UICommand::kSetPseudoStyle, std::move(pseudo_ns),
                                                 element->bindingObject(), payload);
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
          String base_href_string = property_set->GetPropertyBaseHrefWithHint(prop_name, i);
          if (value_string.IsNull()) value_string = String("");

          // Skip white-space longhands; will emit shorthand later
          if (id == CSSPropertyID::kWhiteSpaceCollapse || id == CSSPropertyID::kTextWrap) {
            continue;
          }

          // Already cleared above.
          auto key_ns = prop_name.ToStylePropertyNameNativeString();
          auto* payload = reinterpret_cast<NativeStyleValueWithHref*>(dart_malloc(sizeof(NativeStyleValueWithHref)));
          payload->value = stringToNativeString(value_string).release();
          if (!base_href_string.IsEmpty()) {
            payload->href = stringToNativeString(base_href_string.ToUTF8String()).release();
          } else {
            payload->href = nullptr;
          }
          ctx->uiCommandBuffer()->AddCommand(UICommand::kSetStyle, std::move(key_ns), element->bindingObject(),
                                             payload);
        }

        if (emit_white_space_shorthand) {
          // Already cleared above.
          auto ws_prop = AtomicString::CreateFromUTF8("white-space");
          auto ws_key = ws_prop.ToStylePropertyNameNativeString();
          auto* payload = reinterpret_cast<NativeStyleValueWithHref*>(dart_malloc(sizeof(NativeStyleValueWithHref)));
          payload->value = stringToNativeString(white_space_value_str).release();
          payload->href = nullptr;
          ctx->uiCommandBuffer()->AddCommand(UICommand::kSetStyle, std::move(ws_key), element->bindingObject(),
                                             payload);
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
            CSSPropertyID id = prop.Id();
            if (id == CSSPropertyID::kInvalid) {
              continue;
            }
            const auto* value_ptr = prop.Value();
            if (!value_ptr || !(*value_ptr)) {
              continue;
            }
            AtomicString prop_name = prop.Name().ToAtomicString();
            String value_string = pseudo_set->GetPropertyValueWithHint(prop_name, i);
            if (value_string.IsNull()) {
              value_string = (*value_ptr)->CssTextForSerialization();
            }
            String base_href_string = pseudo_set->GetPropertyBaseHrefWithHint(prop_name, i);

            auto key_ns = prop_name.ToStylePropertyNameNativeString();
            auto* payload =
                reinterpret_cast<NativePseudoStyleWithHref*>(dart_malloc(sizeof(NativePseudoStyleWithHref)));
            payload->key = key_ns.release();
            payload->value = stringToNativeString(value_string).release();
            if (!base_href_string.IsEmpty()) {
              payload->href = stringToNativeString(base_href_string.ToUTF8String()).release();
            } else {
              payload->href = nullptr;
            }

            auto pseudo_atom = AtomicString::CreateFromUTF8(pseudo_name);
            auto pseudo_ns = pseudo_atom.ToNativeString();
            ctx->uiCommandBuffer()->AddCommand(UICommand::kSetPseudoStyle, std::move(pseudo_ns),
                                               element->bindingObject(), payload);
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
}

void StyleEngine::RecalcStyleForElementOnly(Element& element) {
  Document& document = GetDocument();
  if (!document.GetExecutingContext()->isBlinkEnabled()) {
    return;
  }

  // Reuse the same per-element styling logic as RecalcStyleForSubtree, but do
  // not recurse into children and ignore inherited/custom-var accumulation.
  std::function<InheritedState(Element*, const InheritedState&)> apply_for_element =
      [&](Element* el, const InheritedState& parent_state) -> InheritedState {
        if (!el || !el->IsStyledElement()) {
          return parent_state;
        }

        StyleResolver& resolver = EnsureStyleResolver();
        StyleResolverState state(document, *el);
        ElementRuleCollector collector(state, SelectorChecker::kResolvingStyle);
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
              String base_href_string = pseudo_set->GetPropertyBaseHrefWithHint(prop_name, i);
              auto key_ns = prop_name.ToStylePropertyNameNativeString();
              auto* payload =
                  reinterpret_cast<NativePseudoStyleWithHref*>(dart_malloc(sizeof(NativePseudoStyleWithHref)));
              payload->key = key_ns.release();
              payload->value = stringToNativeString(value_string).release();
              if (!base_href_string.IsEmpty()) {
                payload->href = stringToNativeString(base_href_string.ToUTF8String()).release();
              } else {
                payload->href = nullptr;
              }

              auto pseudo_atom2 = AtomicString::CreateFromUTF8(pseudo_name);
              auto pseudo_ns2 = pseudo_atom2.ToNativeString();
              ctx->uiCommandBuffer()->AddCommand(UICommand::kSetPseudoStyle, std::move(pseudo_ns2),
                                                 el->bindingObject(), payload);
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
          String base_href_string = property_set->GetPropertyBaseHrefWithHint(prop_name, i);
          if (value_string.IsNull()) value_string = String("");

          if (id == CSSPropertyID::kWhiteSpaceCollapse || id == CSSPropertyID::kTextWrap) {
            continue;
          }

          auto key_ns = prop_name.ToStylePropertyNameNativeString();
          auto* payload = reinterpret_cast<NativeStyleValueWithHref*>(dart_malloc(sizeof(NativeStyleValueWithHref)));
          payload->value = stringToNativeString(value_string).release();
          if (!base_href_string.IsEmpty()) {
            payload->href = stringToNativeString(base_href_string.ToUTF8String()).release();
          } else {
            payload->href = nullptr;
          }
          ctx->uiCommandBuffer()->AddCommand(UICommand::kSetStyle, std::move(key_ns), el->bindingObject(),
                                             payload);
        }

        if (emit_white_space_shorthand) {
          auto ws_prop = AtomicString::CreateFromUTF8("white-space");
          auto ws_key = ws_prop.ToStylePropertyNameNativeString();
          auto* payload = reinterpret_cast<NativeStyleValueWithHref*>(dart_malloc(sizeof(NativeStyleValueWithHref)));
          payload->value = stringToNativeString(white_space_value_str).release();
          payload->href = nullptr;
          ctx->uiCommandBuffer()->AddCommand(UICommand::kSetStyle, std::move(ws_key), el->bindingObject(),
                                             payload);
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
            CSSPropertyID id = prop.Id();
            if (id == CSSPropertyID::kInvalid) {
              continue;
            }
            const auto* value_ptr = prop.Value();
            if (!value_ptr || !(*value_ptr)) {
              continue;
            }
            AtomicString prop_name = prop.Name().ToAtomicString();
            String value_string = pseudo_set->GetPropertyValueWithHint(prop_name, i);
            if (value_string.IsNull()) {
              value_string = (*value_ptr)->CssTextForSerialization();
            }
            String base_href_string = pseudo_set->GetPropertyBaseHrefWithHint(prop_name, i);

            auto key_ns = prop_name.ToStylePropertyNameNativeString();
            auto* payload =
                reinterpret_cast<NativePseudoStyleWithHref*>(dart_malloc(sizeof(NativePseudoStyleWithHref)));
            payload->key = key_ns.release();
            payload->value = stringToNativeString(value_string).release();
            if (!base_href_string.IsEmpty()) {
              payload->href = stringToNativeString(base_href_string.ToUTF8String()).release();
            } else {
              payload->href = nullptr;
            }

            auto pseudo_atom2 = AtomicString::CreateFromUTF8(pseudo_name);
            auto pseudo_ns2 = pseudo_atom2.ToNativeString();
            ctx->uiCommandBuffer()->AddCommand(UICommand::kSetPseudoStyle, std::move(pseudo_ns2),
                                               el->bindingObject(), payload);
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
}

void StyleEngine::RecalcStyle(StyleRecalcChange change, const StyleRecalcContext& style_recalc_context) {
  Document& document = GetDocument();
  ExecutingContext* context = document.GetExecutingContext();
  if (!context || !context->isBlinkEnabled()) {
    return;
  }

  // Mark the document as being in style recalc so that any style-dirty marks
  // that occur during traversal do not try to update the StyleRecalcRoot.
  // This mirrors Blink's Document::InStyleRecalc + UpdateStyleRecalcRoot
  // interaction at a minimal level.
  struct InStyleRecalcScope {
    Document& doc;
    explicit InStyleRecalcScope(Document& d) : doc(d) { doc.in_style_recalc_ = true; }
    ~InStyleRecalcScope() { doc.in_style_recalc_ = false; }
  } in_style_recalc_scope(document);

  MemberMutationScope scope{context};

  Element* root = nullptr;
  if (style_recalc_root_.GetRootNode()) {
    // When we have a tracked recalc root, start from there to avoid walking
    // the entire document.
    root = &style_recalc_root_.RootElement();
  } else {
    root = document.documentElement();
  }
  if (!root) {
    return;
  }

  PendingInvalidationMap& map = pending_invalidations_.GetPendingInvalidationMap();

  // In addition to selector-based invalidation (tracked via
  // PendingInvalidationMap and the document's style invalidation flags),
  // Blink-style invalidation may mark elements directly dirty for style
  // recalc (e.g., SelfInvalidationSet for simple class changes) without
  // populating PendingInvalidationMap or touching document-level flags.
  // In that case the DOM subtree rooted at |root| still has
  // NeedsStyleRecalc / ChildNeedsStyleRecalc bits set on elements, and we
  // must not early-return here or those changes will never be applied.
  //
  // Mirror Blink's behavior by treating a dirty style subtree as sufficient
  // reason to run the incremental style walk, even when there are no
  // selector-based invalidations scheduled.
  bool subtree_needs_style_recalc = root->NeedsStyleRecalc() || root->ChildNeedsStyleRecalc();

  // In Blink, a non-empty StyleRecalcChange is itself a signal that some work
  // must be done, even if there are no pending invalidations or dirty bits
  // (e.g., container-query driven updates). Mirror that by only bailing out
  // when both the document/subtree are clean *and* the change is empty.
  if (map.empty() && !document.NeedsStyleInvalidation() && !document.ChildNeedsStyleInvalidation() &&
      !subtree_needs_style_recalc && change.IsEmpty()) {
    return;
  }

  // First, run the StyleInvalidator to translate InvalidationSets into
  // StyleChangeType flags on individual elements.
  {
    StyleInvalidator invalidator(map);
    // Blink's StyleInvalidator expects that when the document itself has
    // NeedsStyleInvalidation() set, invalidation starts from the root element
    // (documentElement). Our RecalcStyle() can be invoked with a subtree root
    // via StyleTraversalRoot, so make sure the invalidator still sees the
    // documentElement in that case to keep its invariants while allowing
    // RecalcStyle to limit recomputation to |root|.
    Element* invalidation_root = root;
    if (UNLIKELY(document.NeedsStyleInvalidation())) {
      if (Element* doc_root = document.documentElement()) {
        invalidation_root = doc_root;
      }
    }
    invalidator.Invalidate(document, invalidation_root);
  }

  // If the caller explicitly requested a full subtree recalc (e.g. via
  // ForceRecalcDescendants in a Blink-style code path), honour that by
  // recomputing styles for the entire subtree rooted at |root| regardless of
  // which elements currently have NeedsStyleRecalc set. This is conservative
  // but keeps behavior aligned with Blink: correctness first, with the option
  // to optimize later.
  if (change.RecalcDescendants()) {
    std::function<void(Node*)> clear_flags_for_subtree_force = [&](Node* node) {
      if (!node) {
        return;
      }
      node->ClearNeedsStyleRecalc();
      node->ClearChildNeedsStyleRecalc();
      for (Node* child = node->firstChild(); child; child = child->nextSibling()) {
        clear_flags_for_subtree_force(child);
      }
    };

    RecalcStyleForSubtree(*root);
    clear_flags_for_subtree_force(root);

    for (ContainerNode* ancestor = root->GetStyleRecalcParent(); ancestor;
         ancestor = ancestor->GetStyleRecalcParent()) {
      ancestor->ClearChildNeedsStyleRecalc();
    }

    style_recalc_root_.Clear();
    return;
  }

  // Otherwise, walk the DOM starting at |root| and perform subtree style
  // recomputation only for elements that have been marked dirty.
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

  // Clear breadcrumbs on the traversal root as well, not only its ancestors.
  root->ClearChildNeedsStyleRecalc();

  // If we started from an optimized root, ensure we didn't miss any other dirty
  // nodes (e.g. sibling subtrees). Missing them would cause inline styles to
  // never be exported, since later RecalcStyle() calls may early-return once
  // breadcrumbs are cleared.
  Element* doc_root = document.documentElement();
  auto find_remaining_dirty_node = [&]() -> Node* {
    if (!doc_root) {
      return nullptr;
    }
    for (Node& node : NodeTraversal::InclusiveDescendantsOf(*doc_root)) {
      if (node.NeedsStyleRecalc()) {
        return &node;
      }
    }
    return nullptr;
  };

  if (doc_root && root != doc_root) {
    if (Node* remaining = find_remaining_dirty_node()) {
      walk(doc_root);
      doc_root->ClearChildNeedsStyleRecalc();
    }
  }

  // After a full style walk, clear child-dirty breadcrumbs on ancestors of
  // |root| as well, mirroring Blink's StyleEngine::RecalcStyle. This ensures
  // that StyleTraversalRoot sees a consistent sequence of roots and that the
  // next style mark can safely establish a fresh recalc root.
  for (ContainerNode* ancestor = root->GetStyleRecalcParent(); ancestor;
       ancestor = ancestor->GetStyleRecalcParent()) {
    ancestor->ClearChildNeedsStyleRecalc();
  }

  // After a full style walk and ancestor cleanup, reset the recalc root to
  // allow a fresh root to be established on the next dirty mark.
  style_recalc_root_.Clear();
}

void StyleEngine::RecalcStyle() {
  // Mirror Blink's pattern: the parameterless entry point computes a
  // StyleRecalcContext from the current style_recalc_root_ and then
  // forwards to the overload that accepts a StyleRecalcChange and
  // StyleRecalcContext.
  //
  // When no explicit recalc root has been established yet, fall back to the
  // documentElement() so we retain WebF's existing behavior of treating the
  // whole document as dirty.
  Document& document = GetDocument();
  Element* root = nullptr;
  if (style_recalc_root_.GetRootNode()) {
    root = &style_recalc_root_.RootElement();
  } else {
    root = document.documentElement();
  }
  if (!root) {
    return;
  }

  StyleRecalcChange change;
  StyleRecalcContext context = StyleRecalcContext::FromAncestors(*root);
  RecalcStyle(change, context);
}

void StyleEngine::MarkUserStyleDirty() {}

void StyleEngine::MediaQueryAffectingValueChanged(TreeScope& tree_scope, MediaValueChange change) {
  Document& document = tree_scope.GetDocument();
  if (&document != document_) {
    return;
  }

  ExecutingContext* context = document.GetExecutingContext();
  if (!context || !context->IsContextValid() || !context->isBlinkEnabled()) {
    return;
  }

  // In Blink, media-value changes invalidate active stylesheet RuleSets and
  // trigger an active-style update when needed. WebF uses a text cache for
  // inline <style> sheets; cached StyleSheetContents may be reused later, so
  // clear RuleSets for cached-but-inactive entries to avoid reusing a RuleSet
  // built against stale MediaValues.
  std::unordered_set<const StyleSheetContents*> active_contents;
  active_contents.reserve(author_sheets_.size());
  for (const auto& contents : author_sheets_) {
    if (contents) {
      active_contents.insert(contents.get());
    }
  }

  for (auto& entry : text_to_sheet_cache_) {
    const auto& contents = entry.second;
    if (!contents) {
      continue;
    }
    if (active_contents.find(contents.get()) != active_contents.end()) {
      continue;
    }
    if (!contents->HasMediaQueries() && contents->ImportRules().empty()) {
      continue;
    }
    contents->ClearRuleSet();
  }

  // For viewport size changes, mirror Blink's behavior and gate full style
  // recomputation on whether the set of size-dependent (viewport/device)
  // media queries actually changed. This lets pure resize within a breakpoint
  // range skip
  // style recalc and rely on layout-only updates instead.
  if (change == MediaValueChange::kSize) {
    MediaQueryEvaluator evaluator(context);
    std::vector<MediaQuerySetResult> new_results;
    std::unordered_set<const StyleSheetContents*> visited;
    visited.reserve(author_sheets_.size());

    for (const auto& contents : author_sheets_) {
      if (!contents) {
        continue;
      }
      CollectSizeDependentMediaQueryResults(*contents, evaluator, new_results, visited);
    }

    if (new_results.empty()) {
      // No size-dependent media queries at all: resizing cannot change
      // which stylesheets or @media blocks are active, so skip style recalc.
      size_media_query_results_.clear();
      return;
    }

    bool changed = false;
    if (size_media_query_results_.empty()) {
      // First time we see size-dependent queries for this document; force
      // one style recomputation and establish a baseline for future resizes.
      changed = true;
    } else if (size_media_query_results_.size() != new_results.size()) {
      changed = true;
    } else {
      for (size_t i = 0; i < new_results.size(); ++i) {
        const MediaQuerySet& old_set = size_media_query_results_[i].MediaQueries();
        const MediaQuerySet& new_set = new_results[i].MediaQueries();
        // If the underlying MediaQuerySet objects differ, the stylesheet
        // structure changed without going through SetNeedsActiveStyleUpdate.
        // Be conservative and treat this as changed.
        if (&old_set != &new_set ||
            size_media_query_results_[i].Result() != new_results[i].Result()) {
          changed = true;
          break;
        }
      }
    }

    size_media_query_results_ = std::move(new_results);

    if (!changed) {
      return;
    }

    Element* root = document.documentElement();
    if (root) {
      // Rebuild RuleSets for active author stylesheets against fresh MediaValues.
      for (const auto& contents : author_sheets_) {
        if (contents && (contents->HasMediaQueries() || !contents->ImportRules().empty())) {
          contents->ClearRuleSet();
        }
      }
      if (global_rule_set_) {
        global_rule_set_->MarkDirty();
      }
      root->SetNeedsStyleRecalc(
          kSubtreeStyleChange,
          StyleChangeReasonForTracing::Create(style_change_reason::kStyleRuleChange));
      document.SetNeedsStyleInvalidation();
      RecalcStyle();
      ++media_query_recalc_count_for_test_;
    }
    return;
  }

  // For other media-value changes (dynamic viewport units, DPR, color-scheme,
  // etc.) we conservatively trigger a full style recomputation to ensure all
  // affected media queries are re-evaluated using fresh MediaValues.
  switch (change) {
    case MediaValueChange::kDynamicViewport:
    case MediaValueChange::kOther:
      if (Element* root = document.documentElement()) {
        for (const auto& contents : author_sheets_) {
          if (contents && (contents->HasMediaQueries() || !contents->ImportRules().empty())) {
            contents->ClearRuleSet();
          }
        }
        if (global_rule_set_) {
          global_rule_set_->MarkDirty();
        }
        root->SetNeedsStyleRecalc(
            kSubtreeStyleChange,
            StyleChangeReasonForTracing::Create(style_change_reason::kStyleRuleChange));
        document.SetNeedsStyleInvalidation();
        RecalcStyle();
        ++media_query_recalc_count_for_test_;
      }
      break;
    case MediaValueChange::kSize:
      // Handled above.
      break;
  }
}

void StyleEngine::MediaQueryAffectingValueChanged(UnorderedTreeScopeSet& tree_scopes,
                                                  MediaValueChange change) {
  for (TreeScope* tree_scope : tree_scopes) {
    if (tree_scope) {
      MediaQueryAffectingValueChanged(*tree_scope, change);
    }
  }
}

void StyleEngine::MediaQueryAffectingValueChanged(TextTrackSet& text_tracks, MediaValueChange change) {
  (void)change;
  if (text_tracks.empty()) {
    return;
  }
}

void StyleEngine::MediaQueryAffectingValueChanged(MediaValueChange change) {
  if (AffectedByMediaValueChange(active_user_style_sheets_, change)) {
    MarkUserStyleDirty();
  }
  MediaQueryAffectingValueChanged(GetDocument(), change);
  MediaQueryAffectingValueChanged(active_tree_scopes_, change);
  MediaQueryAffectingValueChanged(text_tracks_, change);
  if (resolver_) {
    resolver_->UpdateMediaType();
  }
}

void StyleEngine::Trace(GCVisitor* visitor) {
  for (const auto& active_sheet : active_user_style_sheets_) {
    visitor->TraceMember(active_sheet.first);
  }

  style_invalidation_root_.Trace(visitor);
  style_recalc_root_.Trace(visitor);
}

}  // namespace webf
