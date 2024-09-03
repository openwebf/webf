/*
 * Copyright (C) 1999-2003 Lars Knoll (knoll@kde.org)
 *               1999 Waldo Bastian (bastian@kde.org)
 *               2001 Andreas Schlapbach (schlpbch@iam.unibe.ch)
 *               2001-2003 Dirk Mueller (mueller@kde.org)
 * Copyright (C) 2002, 2006, 2007, 2008, 2009, 2010 Apple Inc. All rights
 * reserved.
 * Copyright (C) 2008 David Smith (catfish.man@gmail.com)
 * Copyright (C) 2010 Google Inc. All rights reserved.
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

#include "css_selector.h"

#include <algorithm>
#include <memory>
#include "core/css/css_markup.h"
#include "core/css/css_selector_list.h"
#include "core/css/parser/css_parser_context.h"
#include "core/css/parser/css_parser_token_range.h"
#include "core/css/parser/css_selector_parser.h"
#include "global_string.h"
#include "style_rule.h"
// #include "core/css/parser/css_tokenizer.h"
#include "core/dom/document.h"
// #include "core/dom/pseudo_element.h"
#include "core/executing_context.h"
// #include "core/html/html_document.h"
// #include "core/html_names.h"
#include "foundation/string_builder.h"

namespace webf {

CSSSelector::CSSSelector()
    : bits_(RelationField::encode(kSubSelector) | MatchField::encode(kUnknown) |
            PseudoTypeField::encode(kPseudoUnknown) | IsLastInSelectorListField::encode(false) |
            IsLastInComplexSelectorField::encode(false) | HasRareDataField::encode(false) |
            IsForPageField::encode(false) | IsImplicitlyAddedField::encode(false) |
            IsCoveredByBucketingField::encode(false) | SignalField::encode(static_cast<unsigned>(Signal::kNone)) |
            IsInvisibleField::encode(false)),
      data_(DataUnion::kConstructEmptyValue) {}

CSSSelector::CSSSelector(const CSSSelector& o) : bits_(o.bits_), data_(DataUnion::kConstructUninitialized) {
  if (o.Match() == kTag) {
    new (&data_.tag_q_name_) QualifiedName(o.data_.tag_q_name_);
  } else if (o.Match() == kPseudoClass && o.GetPseudoType() == kPseudoParent) {
    data_.parent_rule_ = o.data_.parent_rule_;
  } else if (o.HasRareData()) {
    data_.rare_data_ = o.data_.rare_data_;  // Oilpan-managed.
  } else {
    data_.value_ = o.data_.value_;
  }
}

CSSSelector::CSSSelector(CSSSelector&& o) : data_(DataUnion::kConstructUninitialized) {
  // Seemingly Clang started generating terrible code for the obvious move
  // constructor (i.e., using similar code as in the copy constructor above)
  // after moving to Oilpan, copying the bits one by one. We already allow
  // memcpy + memset by traits, so we can do it by ourselves, too.
  memcpy(this, &o, sizeof(*this));
  memset(&o, 0, sizeof(o));
}

CSSSelector::CSSSelector(std::shared_ptr<const StyleRule> parent_rule, bool is_implicit)
    : bits_(RelationField::encode(kSubSelector) | MatchField::encode(kPseudoClass) |
            PseudoTypeField::encode(kPseudoParent) | IsLastInSelectorListField::encode(false) |
            IsLastInComplexSelectorField::encode(false) | HasRareDataField::encode(false) |
            IsForPageField::encode(false) | IsImplicitlyAddedField::encode(is_implicit) |
            IsCoveredByBucketingField::encode(false) | SignalField::encode(static_cast<unsigned>(Signal::kNone)) |
            IsInvisibleField::encode(false)),
      data_(std::move(parent_rule)) {}

CSSSelector::CSSSelector(const std::string& pseudo_name, bool is_implicit)
    : bits_(RelationField::encode(kSubSelector) | MatchField::encode(kPseudoClass) |
            PseudoTypeField::encode(NameToPseudoType(pseudo_name,
                                                     /* has_arguments */ false,
                                                     /* document */ nullptr)) |
            IsLastInSelectorListField::encode(false) | IsLastInComplexSelectorField::encode(false) |
            HasRareDataField::encode(false) | IsForPageField::encode(false) |
            IsImplicitlyAddedField::encode(is_implicit) | IsCoveredByBucketingField::encode(false) |
            SignalField::encode(static_cast<unsigned>(Signal::kNone)) | IsInvisibleField::encode(false)),
      data_(pseudo_name) {}

CSSSelector::~CSSSelector() {
  if (Match() == kTag) {
    data_.tag_q_name_.~QualifiedName();
  } else if (Match() == kPseudoClass && GetPseudoType() == kPseudoParent)
    ;  // Nothing to do.
  else if (HasRareData())
    ;  // Nothing to do.
  else {
  }
}

std::string CSSSelector::SelectorText() const {
  std::string result;
  for (const CSSSelector* compound = this; compound; compound = compound->NextSimpleSelector()) {
    std::string builder;
    compound = compound->SerializeCompound(builder);
    if (!compound) {
      return builder + result;
    }

    RelationType relation = compound->Relation();
    assert(relation < kSubSelector);
    assert(relation < kScopeActivation);

    const CSSSelector* next_compound = compound->NextSimpleSelector();
    assert(next_compound);

    // Skip leading :true. This internal pseudo-class is not supposed to
    // affect serialization.
    if (next_compound->GetPseudoType() == kPseudoTrue) {
      next_compound = next_compound->NextSimpleSelector();
    }

    // If we are combining with an implicit :scope, it is as if we
    // used a relative combinator.
    if (!next_compound || (next_compound->Match() == kPseudoClass && next_compound->GetPseudoType() == kPseudoScope &&
                           next_compound->IsImplicit())) {
      relation = ConvertRelationToRelative(relation);
    }

    switch (relation) {
      case kDescendant:
        result = " " + builder + result;
        break;
      case kChild:
        result = " > " + builder + result;
        break;
      case kDirectAdjacent:
        result = " + " + builder + result;
        break;
      case kIndirectAdjacent:
        result = " ~ " + builder + result;
        break;
      case kSubSelector:
      case kScopeActivation:
        assert(false);
        break;
      case kShadowPart:
      case kUAShadow:
      case kShadowSlot:
        result = builder + result;
        break;
      case kRelativeDescendant:
        return builder + result;
      case kRelativeChild:
        return "> " + builder + result;
      case kRelativeDirectAdjacent:
        return "+ " + builder + result;
      case kRelativeIndirectAdjacent:
        return "~ " + builder + result;
    }
  }
  assert(false);
  return "";
}

static void SerializeIdentifierOrAny(const std::string& identifier, const std::string& any, std::string& builder) {
  if (identifier != any) {
    SerializeIdentifier(identifier, builder);
  } else {
    builder.append("*");
  }
}

static void SerializeNamespacePrefixIfNeeded(const std::string& prefix,
                                             const std::string& any,
                                             std::string& builder,
                                             bool is_attribute_selector) {
  if (prefix.empty() || (prefix.empty() && is_attribute_selector)) {
    return;
  }
  SerializeIdentifierOrAny(prefix, any, builder);
  builder.append("|");
}

std::string CSSSelector::SimpleSelectorTextForDebug() const {
  std::string builder;
  if (Match() == kTag && !IsImplicit()) {
    SerializeNamespacePrefixIfNeeded(TagQName().Prefix(), global_string_stdstring::kstar_atom, builder,
                                     IsAttributeSelector());
    SerializeIdentifierOrAny(TagQName().LocalName(), UniversalSelectorAtom(), builder);
  } else {
    SerializeSimpleSelector(builder);
  }
  return builder;
}

CSSSelector::RelationType ConvertRelationToRelative(CSSSelector::RelationType relation) {
  switch (relation) {
    case CSSSelector::kSubSelector:
    case CSSSelector::kDescendant:
      return CSSSelector::kRelativeDescendant;
    case CSSSelector::kChild:
      return CSSSelector::kRelativeChild;
    case CSSSelector::kDirectAdjacent:
      return CSSSelector::kRelativeDirectAdjacent;
    case CSSSelector::kIndirectAdjacent:
      return CSSSelector::kRelativeIndirectAdjacent;
    default:

      assert_m(false, "NOTREACHED_IN_MIGRATION");
      return {};
  }
}

PseudoId CSSSelector::GetPseudoId(PseudoType type) {
  switch (type) {
    case kPseudoFirstLine:
      return kPseudoIdFirstLine;
    case kPseudoFirstLetter:
      return kPseudoIdFirstLetter;
    case kPseudoSelection:
      return kPseudoIdSelection;
    case kPseudoBefore:
      return kPseudoIdBefore;
    case kPseudoAfter:
      return kPseudoIdAfter;
    case kPseudoMarker:
      return kPseudoIdMarker;
    case kPseudoBackdrop:
      return kPseudoIdBackdrop;
    case kPseudoScrollbar:
      return kPseudoIdScrollbar;
    case kPseudoScrollMarker:
      return kPseudoIdScrollMarker;
    case kPseudoScrollMarkerGroup:
      return kPseudoIdScrollMarkerGroup;
    case kPseudoScrollbarButton:
      return kPseudoIdScrollbarButton;
    case kPseudoScrollbarCorner:
      return kPseudoIdScrollbarCorner;
    case kPseudoScrollbarThumb:
      return kPseudoIdScrollbarThumb;
    case kPseudoScrollbarTrack:
      return kPseudoIdScrollbarTrack;
    case kPseudoScrollbarTrackPiece:
      return kPseudoIdScrollbarTrackPiece;
    case kPseudoResizer:
      return kPseudoIdResizer;
    case kPseudoSearchText:
      return kPseudoIdSearchText;
    case kPseudoTargetText:
      return kPseudoIdTargetText;
    case kPseudoHighlight:
      return kPseudoIdHighlight;
    case kPseudoSpellingError:
      return kPseudoIdSpellingError;
    case kPseudoGrammarError:
      return kPseudoIdGrammarError;
    case kPseudoViewTransition:
      return kPseudoIdViewTransition;
    case kPseudoViewTransitionGroup:
      return kPseudoIdViewTransitionGroup;
    case kPseudoViewTransitionImagePair:
      return kPseudoIdViewTransitionImagePair;
    case kPseudoViewTransitionOld:
      return kPseudoIdViewTransitionOld;
    case kPseudoViewTransitionNew:
      return kPseudoIdViewTransitionNew;
    case kPseudoActive:
    case kPseudoActiveViewTransition:
    case kPseudoActiveViewTransitionType:
    case kPseudoAny:
    case kPseudoAnyLink:
    case kPseudoAutofill:
    case kPseudoAutofillPreviewed:
    case kPseudoAutofillSelected:
    case kPseudoBlinkInternalElement:
    case kPseudoChecked:
    case kPseudoClosed:
    case kPseudoCornerPresent:
    case kPseudoCue:
    case kPseudoCurrent:
    case kPseudoDecrement:
    case kPseudoDefault:
    case kPseudoDefined:
    case kPseudoDetailsContent:
    case kPseudoDialogInTopLayer:
    case kPseudoDir:
    case kPseudoDisabled:
    case kPseudoDoubleButton:
    case kPseudoDrag:
    case kPseudoEmpty:
    case kPseudoEnabled:
    case kPseudoEnd:
    case kPseudoFileSelectorButton:
    case kPseudoFirstChild:
    case kPseudoFirstOfType:
    case kPseudoFirstPage:
    case kPseudoFocus:
    case kPseudoFocusVisible:
    case kPseudoFocusWithin:
    case kPseudoFullPageMedia:
    case kPseudoFullScreen:
    case kPseudoFullScreenAncestor:
    case kPseudoFullscreen:
    case kPseudoFutureCue:
    case kPseudoHas:
    case kPseudoHasDatalist:
    case kPseudoHorizontal:
    case kPseudoHost:
    case kPseudoHostContext:
    case kPseudoHostHasAppearance:
    case kPseudoHover:
    case kPseudoInRange:
    case kPseudoIncrement:
    case kPseudoIndeterminate:
    case kPseudoInvalid:
    case kPseudoIs:
    case kPseudoIsHtml:
    case kPseudoLang:
    case kPseudoLastChild:
    case kPseudoLastOfType:
    case kPseudoLeftPage:
    case kPseudoLink:
    case kPseudoListBox:
    case kPseudoModal:
    case kPseudoMultiSelectFocus:
    case kPseudoNoButton:
    case kPseudoNot:
    case kPseudoNthChild:
    case kPseudoNthLastChild:
    case kPseudoNthLastOfType:
    case kPseudoNthOfType:
    case kPseudoOnlyChild:
    case kPseudoOnlyOfType:
    case kPseudoOpen:
    case kPseudoOptional:
    case kPseudoOutOfRange:
    case kPseudoParent:
    case kPseudoPart:
    case kPseudoPastCue:
    case kPseudoPaused:
    case kPseudoPermissionGranted:
    case kPseudoPictureInPicture:
    case kPseudoPlaceholder:
    case kPseudoPlaceholderShown:
    case kPseudoPlaying:
    case kPseudoPopoverInTopLayer:
    case kPseudoPopoverOpen:
    case kPseudoReadOnly:
    case kPseudoReadWrite:
    case kPseudoRelativeAnchor:
    case kPseudoRequired:
    case kPseudoRightPage:
    case kPseudoRoot:
    case kPseudoScope:
    case kPseudoSelectFallbackButton:
    case kPseudoSelectFallbackButtonIcon:
    case kPseudoSelectFallbackButtonText:
    case kPseudoSelectFallbackDatalist:
    case kPseudoSelectorFragmentAnchor:
    case kPseudoSingleButton:
    case kPseudoSlotted:
    case kPseudoSpatialNavigationFocus:
    case kPseudoStart:
    case kPseudoState:
    case kPseudoStateDeprecatedSyntax:
    case kPseudoTarget:
    case kPseudoTrue:
    case kPseudoUnknown:
    case kPseudoUnparsed:
    case kPseudoUserInvalid:
    case kPseudoUserValid:
    case kPseudoValid:
    case kPseudoVertical:
    case kPseudoVideoPersistent:
    case kPseudoVideoPersistentAncestor:
    case kPseudoVisited:
    case kPseudoWebKitAutofill:
    case kPseudoWebKitCustomElement:
    case kPseudoWebkitAnyLink:
    case kPseudoWhere:
    case kPseudoWindowInactive:
    case kPseudoXrOverlay:
      return kPseudoIdNone;
  }

  assert_m(false, "NOTREACHED_IN_MIGRATION");
  return kPseudoIdNone;
}
// Could be made smaller and faster by replacing pointer with an
// offset into a string buffer and making the bit fields smaller but
// that could not be maintained by hand.
struct NameToPseudoStruct {
  const char* string;
  unsigned type : 8;
};

// These tables must be kept sorted.
const static NameToPseudoStruct kPseudoTypeWithoutArgumentsMap[] = {
    {"-internal-autofill-previewed", CSSSelector::kPseudoAutofillPreviewed},
    {"-internal-autofill-selected", CSSSelector::kPseudoAutofillSelected},
    {"-internal-dialog-in-top-layer", CSSSelector::kPseudoDialogInTopLayer},
    {"-internal-has-datalist", CSSSelector::kPseudoHasDatalist},
    {"-internal-is-html", CSSSelector::kPseudoIsHtml},
    {"-internal-list-box", CSSSelector::kPseudoListBox},
    {"-internal-media-controls-overlay-cast-button", CSSSelector::kPseudoWebKitCustomElement},
    {"-internal-multi-select-focus", CSSSelector::kPseudoMultiSelectFocus},
    {"-internal-popover-in-top-layer", CSSSelector::kPseudoPopoverInTopLayer},
    {"-internal-relative-anchor", CSSSelector::kPseudoRelativeAnchor},
    {"-internal-selector-fragment-anchor", CSSSelector::kPseudoSelectorFragmentAnchor},
    {"-internal-shadow-host-has-appearance", CSSSelector::kPseudoHostHasAppearance},
    {"-internal-spatial-navigation-focus", CSSSelector::kPseudoSpatialNavigationFocus},
    {"-internal-video-persistent", CSSSelector::kPseudoVideoPersistent},
    {"-internal-video-persistent-ancestor", CSSSelector::kPseudoVideoPersistentAncestor},
    {"-webkit-any-link", CSSSelector::kPseudoWebkitAnyLink},
    {"-webkit-autofill", CSSSelector::kPseudoWebKitAutofill},
    {"-webkit-drag", CSSSelector::kPseudoDrag},
    {"-webkit-full-page-media", CSSSelector::kPseudoFullPageMedia},
    {"-webkit-full-screen", CSSSelector::kPseudoFullScreen},
    {"-webkit-full-screen-ancestor", CSSSelector::kPseudoFullScreenAncestor},
    {"-webkit-resizer", CSSSelector::kPseudoResizer},
    {"-webkit-scrollbar", CSSSelector::kPseudoScrollbar},
    {"-webkit-scrollbar-button", CSSSelector::kPseudoScrollbarButton},
    {"-webkit-scrollbar-corner", CSSSelector::kPseudoScrollbarCorner},
    {"-webkit-scrollbar-thumb", CSSSelector::kPseudoScrollbarThumb},
    {"-webkit-scrollbar-track", CSSSelector::kPseudoScrollbarTrack},
    {"-webkit-scrollbar-track-piece", CSSSelector::kPseudoScrollbarTrackPiece},
    {"active", CSSSelector::kPseudoActive},
    {"active-view-transition", CSSSelector::kPseudoActiveViewTransition},
    {"after", CSSSelector::kPseudoAfter},
    {"any-link", CSSSelector::kPseudoAnyLink},
    {"autofill", CSSSelector::kPseudoAutofill},
    {"backdrop", CSSSelector::kPseudoBackdrop},
    {"before", CSSSelector::kPseudoBefore},
    {"checked", CSSSelector::kPseudoChecked},
    {"closed", CSSSelector::kPseudoClosed},
    {"corner-present", CSSSelector::kPseudoCornerPresent},
    {"cue", CSSSelector::kPseudoWebKitCustomElement},
    {"current", CSSSelector::kPseudoCurrent},
    {"decrement", CSSSelector::kPseudoDecrement},
    {"default", CSSSelector::kPseudoDefault},
    {"defined", CSSSelector::kPseudoDefined},
    {"details-content", CSSSelector::kPseudoDetailsContent},
    {"disabled", CSSSelector::kPseudoDisabled},
    {"double-button", CSSSelector::kPseudoDoubleButton},
    {"empty", CSSSelector::kPseudoEmpty},
    {"enabled", CSSSelector::kPseudoEnabled},
    {"end", CSSSelector::kPseudoEnd},
    {"file-selector-button", CSSSelector::kPseudoFileSelectorButton},
    {"first", CSSSelector::kPseudoFirstPage},
    {"first-child", CSSSelector::kPseudoFirstChild},
    {"first-letter", CSSSelector::kPseudoFirstLetter},
    {"first-line", CSSSelector::kPseudoFirstLine},
    {"first-of-type", CSSSelector::kPseudoFirstOfType},
    {"focus", CSSSelector::kPseudoFocus},
    {"focus-visible", CSSSelector::kPseudoFocusVisible},
    {"focus-within", CSSSelector::kPseudoFocusWithin},
    {"fullscreen", CSSSelector::kPseudoFullscreen},
    {"future", CSSSelector::kPseudoFutureCue},
    {"grammar-error", CSSSelector::kPseudoGrammarError},
    {"granted", CSSSelector::kPseudoPermissionGranted},
    {"horizontal", CSSSelector::kPseudoHorizontal},
    {"host", CSSSelector::kPseudoHost},
    {"hover", CSSSelector::kPseudoHover},
    {"in-range", CSSSelector::kPseudoInRange},
    {"increment", CSSSelector::kPseudoIncrement},
    {"indeterminate", CSSSelector::kPseudoIndeterminate},
    {"invalid", CSSSelector::kPseudoInvalid},
    {"last-child", CSSSelector::kPseudoLastChild},
    {"last-of-type", CSSSelector::kPseudoLastOfType},
    {"left", CSSSelector::kPseudoLeftPage},
    {"link", CSSSelector::kPseudoLink},
    {"marker", CSSSelector::kPseudoMarker},
    {"modal", CSSSelector::kPseudoModal},
    {"no-button", CSSSelector::kPseudoNoButton},
    {"only-child", CSSSelector::kPseudoOnlyChild},
    {"only-of-type", CSSSelector::kPseudoOnlyOfType},
    {"open", CSSSelector::kPseudoOpen},
    {"optional", CSSSelector::kPseudoOptional},
    {"out-of-range", CSSSelector::kPseudoOutOfRange},
    {"past", CSSSelector::kPseudoPastCue},
    {"paused", CSSSelector::kPseudoPaused},
    {"picture-in-picture", CSSSelector::kPseudoPictureInPicture},
    {"placeholder", CSSSelector::kPseudoPlaceholder},
    {"placeholder-shown", CSSSelector::kPseudoPlaceholderShown},
    {"playing", CSSSelector::kPseudoPlaying},
    {"popover-open", CSSSelector::kPseudoPopoverOpen},
    {"read-only", CSSSelector::kPseudoReadOnly},
    {"read-write", CSSSelector::kPseudoReadWrite},
    {"required", CSSSelector::kPseudoRequired},
    {"right", CSSSelector::kPseudoRightPage},
    {"root", CSSSelector::kPseudoRoot},
    {"scope", CSSSelector::kPseudoScope},
    {"scroll-marker", CSSSelector::kPseudoScrollMarker},
    {"scroll-marker-group", CSSSelector::kPseudoScrollMarkerGroup},
    {"search-text", CSSSelector::kPseudoSearchText},
    {"select-fallback-button", CSSSelector::kPseudoSelectFallbackButton},
    {"select-fallback-button-icon", CSSSelector::kPseudoSelectFallbackButtonIcon},
    {"select-fallback-button-text", CSSSelector::kPseudoSelectFallbackButtonText},
    {"select-fallback-datalist", CSSSelector::kPseudoSelectFallbackDatalist},
    {"selection", CSSSelector::kPseudoSelection},
    {"single-button", CSSSelector::kPseudoSingleButton},
    {"spelling-error", CSSSelector::kPseudoSpellingError},
    {"start", CSSSelector::kPseudoStart},
    {"target", CSSSelector::kPseudoTarget},
    {"target-text", CSSSelector::kPseudoTargetText},
    {"user-invalid", CSSSelector::kPseudoUserInvalid},
    {"user-valid", CSSSelector::kPseudoUserValid},
    {"valid", CSSSelector::kPseudoValid},
    {"vertical", CSSSelector::kPseudoVertical},
    {"view-transition", CSSSelector::kPseudoViewTransition},
    {"visited", CSSSelector::kPseudoVisited},
    {"window-inactive", CSSSelector::kPseudoWindowInactive},
    {"xr-overlay", CSSSelector::kPseudoXrOverlay},
};

const static NameToPseudoStruct kPseudoTypeWithArgumentsMap[] = {
    {"-webkit-any", CSSSelector::kPseudoAny},
    {"active-view-transition-type", CSSSelector::kPseudoActiveViewTransitionType},
    {"cue", CSSSelector::kPseudoCue},
    {"dir", CSSSelector::kPseudoDir},
    {"has", CSSSelector::kPseudoHas},
    {"highlight", CSSSelector::kPseudoHighlight},
    {"host", CSSSelector::kPseudoHost},
    {"host-context", CSSSelector::kPseudoHostContext},
    {"is", CSSSelector::kPseudoIs},
    {"lang", CSSSelector::kPseudoLang},
    {"not", CSSSelector::kPseudoNot},
    {"nth-child", CSSSelector::kPseudoNthChild},
    {"nth-last-child", CSSSelector::kPseudoNthLastChild},
    {"nth-last-of-type", CSSSelector::kPseudoNthLastOfType},
    {"nth-of-type", CSSSelector::kPseudoNthOfType},
    {"part", CSSSelector::kPseudoPart},
    {"slotted", CSSSelector::kPseudoSlotted},
    {"state", CSSSelector::kPseudoState},
    {"view-transition-group", CSSSelector::kPseudoViewTransitionGroup},
    {"view-transition-image-pair", CSSSelector::kPseudoViewTransitionImagePair},
    {"view-transition-new", CSSSelector::kPseudoViewTransitionNew},
    {"view-transition-old", CSSSelector::kPseudoViewTransitionOld},
    {"where", CSSSelector::kPseudoWhere},
};

CSSSelector::PseudoType CSSSelector::NameToPseudoType(const std::string& name,
                                                      bool has_arguments,
                                                      const Document* document) {
  if (name.empty()) {
    return CSSSelector::kPseudoUnknown;
  }

  const NameToPseudoStruct* pseudo_type_map;
  const NameToPseudoStruct* pseudo_type_map_end;
  if (has_arguments) {
    pseudo_type_map = kPseudoTypeWithArgumentsMap;
    pseudo_type_map_end = kPseudoTypeWithArgumentsMap + std::size(kPseudoTypeWithArgumentsMap);
  } else {
    pseudo_type_map = kPseudoTypeWithoutArgumentsMap;
    pseudo_type_map_end = kPseudoTypeWithoutArgumentsMap + std::size(kPseudoTypeWithoutArgumentsMap);
  }
  const NameToPseudoStruct* match = std::lower_bound(
      pseudo_type_map, pseudo_type_map_end, name, [](const NameToPseudoStruct& entry, const std::string& name) -> bool {
        assert(entry.string);
        // If strncmp returns 0, then either the keys are equal, or |name| sorts
        // before |entry|.
        return strncmp(entry.string, reinterpret_cast<const char*>(name.c_str()), name.length()) < 0;
      });
  if (match == pseudo_type_map_end || match->string != reinterpret_cast<const char*>(name.c_str())) {
    return CSSSelector::kPseudoUnknown;
  }

  if (match->type == CSSSelector::kPseudoPaused) {
    return CSSSelector::kPseudoUnknown;
  }

  if (match->type == CSSSelector::kPseudoPlaying) {
    return CSSSelector::kPseudoUnknown;
  }

  if (match->type == CSSSelector::kPseudoState) {
    return CSSSelector::kPseudoUnknown;
  }

  if (match->type == CSSSelector::kPseudoDetailsContent) {
    return CSSSelector::kPseudoUnknown;
  }

  if (match->type == CSSSelector::kPseudoPermissionGranted) {
    return CSSSelector::kPseudoUnknown;
  }

  if ((match->type == CSSSelector::kPseudoScrollMarker || match->type == CSSSelector::kPseudoScrollMarkerGroup)) {
    return CSSSelector::kPseudoUnknown;
  }

  if ((match->type == CSSSelector::kPseudoOpen || match->type == CSSSelector::kPseudoClosed)) {
    return CSSSelector::kPseudoUnknown;
  }

  if ((match->type == CSSSelector::kPseudoSelectFallbackButton ||
       match->type == CSSSelector::kPseudoSelectFallbackButtonIcon ||
       match->type == CSSSelector::kPseudoSelectFallbackButtonText ||
       match->type == CSSSelector::kPseudoSelectFallbackDatalist)) {
    return CSSSelector::kPseudoUnknown;
  }

  if ((match->type == CSSSelector::kPseudoSearchText || match->type == CSSSelector::kPseudoCurrent)) {
    return CSSSelector::kPseudoUnknown;
  }

  return static_cast<CSSSelector::PseudoType>(match->type);
}

void CSSSelector::UpdatePseudoType(const std::string& value,
                                   const CSSParserContext& context,
                                   bool has_arguments,
                                   CSSParserMode mode) {
  assert(Match() == kPseudoClass || Match() == kPseudoElement);
  // TODO(xiezuobing): 源代码 [ AtomicString lower_value = value.LowerASCII() ]
  std::string lower_value = value;
  PseudoType pseudo_type = CSSSelectorParser::ParsePseudoType(lower_value, has_arguments, context.GetDocument());
  SetPseudoType(pseudo_type);
  SetValue(pseudo_type == kPseudoStateDeprecatedSyntax ? value : lower_value);

  switch (GetPseudoType()) {
    case kPseudoAfter:
    case kPseudoBefore:
    case kPseudoFirstLetter:
    case kPseudoFirstLine:
      // The spec says some pseudos allow both single and double colons like
      // :before for backwards compatability. Single colon becomes PseudoClass,
      // but should be PseudoElement like double colon.
      if (Match() == kPseudoClass) {
        bits_.set<MatchField>(kPseudoElement);
      }
      [[fallthrough]];
    // For pseudo elements
    case kPseudoBackdrop:
    case kPseudoCue:
    case kPseudoMarker:
    case kPseudoPart:
    case kPseudoPlaceholder:
    case kPseudoFileSelectorButton:
    case kPseudoResizer:
    case kPseudoScrollbar:
    case kPseudoScrollbarCorner:
    case kPseudoScrollbarButton:
    case kPseudoScrollbarThumb:
    case kPseudoScrollbarTrack:
    case kPseudoScrollbarTrackPiece:
    case kPseudoScrollMarker:
    case kPseudoScrollMarkerGroup:
    case kPseudoSelectFallbackButton:
    case kPseudoSelectFallbackButtonIcon:
    case kPseudoSelectFallbackButtonText:
    case kPseudoSelectFallbackDatalist:
    case kPseudoSelection:
    case kPseudoWebKitCustomElement:
    case kPseudoSlotted:
    case kPseudoSearchText:
    case kPseudoTargetText:
    case kPseudoHighlight:
    case kPseudoSpellingError:
    case kPseudoGrammarError:
    case kPseudoViewTransition:
    case kPseudoViewTransitionGroup:
    case kPseudoViewTransitionImagePair:
    case kPseudoViewTransitionOld:
    case kPseudoViewTransitionNew:
    case kPseudoDetailsContent:
      if (Match() != kPseudoElement) {
        bits_.set<PseudoTypeField>(kPseudoUnknown);
      }
      break;
    case kPseudoBlinkInternalElement:
      if (Match() != kPseudoElement || mode != kUASheetMode) {
        bits_.set<PseudoTypeField>(kPseudoUnknown);
      }
      break;
    case kPseudoHasDatalist:
    case kPseudoHostHasAppearance:
    case kPseudoIsHtml:
    case kPseudoListBox:
    case kPseudoMultiSelectFocus:
    case kPseudoSpatialNavigationFocus:
    case kPseudoVideoPersistent:
    case kPseudoVideoPersistentAncestor:
      if (mode != kUASheetMode) {
        bits_.set<PseudoTypeField>(kPseudoUnknown);
        break;
      }
      [[fallthrough]];
    // For pseudo classes
    case kPseudoActive:
    case kPseudoActiveViewTransition:
    case kPseudoActiveViewTransitionType:
    case kPseudoAny:
    case kPseudoAnyLink:
    case kPseudoAutofill:
    case kPseudoAutofillPreviewed:
    case kPseudoAutofillSelected:
    case kPseudoChecked:
    case kPseudoClosed:
    case kPseudoCornerPresent:
    case kPseudoCurrent:
    case kPseudoDecrement:
    case kPseudoDefault:
    case kPseudoDefined:
    case kPseudoDialogInTopLayer:
    case kPseudoDir:
    case kPseudoDisabled:
    case kPseudoDoubleButton:
    case kPseudoDrag:
    case kPseudoEmpty:
    case kPseudoEnabled:
    case kPseudoEnd:
    case kPseudoFirstChild:
    case kPseudoFirstOfType:
    case kPseudoFocus:
    case kPseudoFocusVisible:
    case kPseudoFocusWithin:
    case kPseudoFullPageMedia:
    case kPseudoFullScreen:
    case kPseudoFullScreenAncestor:
    case kPseudoFullscreen:
    case kPseudoFutureCue:
    case kPseudoHas:
    case kPseudoHorizontal:
    case kPseudoHost:
    case kPseudoHostContext:
    case kPseudoHover:
    case kPseudoInRange:
    case kPseudoIncrement:
    case kPseudoIndeterminate:
    case kPseudoInvalid:
    case kPseudoIs:
    case kPseudoLang:
    case kPseudoLastChild:
    case kPseudoLastOfType:
    case kPseudoLink:
    case kPseudoModal:
    case kPseudoNoButton:
    case kPseudoNot:
    case kPseudoNthChild:
    case kPseudoNthLastChild:
    case kPseudoNthLastOfType:
    case kPseudoNthOfType:
    case kPseudoOnlyChild:
    case kPseudoOnlyOfType:
    case kPseudoOpen:
    case kPseudoOptional:
    case kPseudoOutOfRange:
    case kPseudoParent:
    case kPseudoPastCue:
    case kPseudoPaused:
    case kPseudoPermissionGranted:
    case kPseudoPictureInPicture:
    case kPseudoPlaceholderShown:
    case kPseudoPlaying:
    case kPseudoPopoverInTopLayer:
    case kPseudoPopoverOpen:
    case kPseudoReadOnly:
    case kPseudoReadWrite:
    case kPseudoRelativeAnchor:
    case kPseudoRequired:
    case kPseudoRoot:
    case kPseudoScope:
    case kPseudoSelectorFragmentAnchor:
    case kPseudoSingleButton:
    case kPseudoStart:
    case kPseudoState:
    case kPseudoStateDeprecatedSyntax:
    case kPseudoTarget:
    case kPseudoTrue:
    case kPseudoUnknown:
    case kPseudoUnparsed:
    case kPseudoUserInvalid:
    case kPseudoUserValid:
    case kPseudoValid:
    case kPseudoVertical:
    case kPseudoVisited:
    case kPseudoWebKitAutofill:
    case kPseudoWebkitAnyLink:
    case kPseudoWhere:
    case kPseudoWindowInactive:
    case kPseudoXrOverlay:
      if (Match() != kPseudoClass) {
        bits_.set<PseudoTypeField>(kPseudoUnknown);
      }
      break;
    case kPseudoFirstPage:
    case kPseudoLeftPage:
    case kPseudoRightPage:
      bits_.set<PseudoTypeField>(kPseudoUnknown);
      break;
  }
}

void CSSSelector::SetUnparsedPlaceholder(CSSNestingType unparsed_nesting_type, const std::string& value) {
  assert(Match() == kPseudoClass);
  SetPseudoType(kPseudoUnparsed);
  CreateRareData();
  SetValue(value);
  data_.rare_data_->bits_.unparsed_nesting_type_ = unparsed_nesting_type;
}

void CSSSelector::SetTrue() {
  SetMatch(kPseudoClass);
  SetPseudoType(kPseudoTrue);
  bits_.set<IsImplicitlyAddedField>(true);
}
void CSSSelector::CreateRareData() {
  assert(Match() != kTag);
  if (HasRareData()) {
    return;
  }
  // This transitions the DataUnion from |value_| to |rare_data_| and thus needs
  // to be careful to correctly manage explicitly destruction of |value_|
  // followed by placement new of |rare_data_|. A straight-assignment will
  // compile and may kinda work, but will be undefined behavior.
  std::shared_ptr<RareData> rare_data = std::make_shared<RareData>(data_.value_);
  data_.rare_data_ = rare_data;
  bits_.set<HasRareDataField>(true);
}

void CSSSelector::SetValue(const std::string& value, bool match_lower_case) {
  assert(Match() != static_cast<unsigned>(kTag));
  assert(!(Match() == kPseudoClass && GetPseudoType() == kPseudoParent));
  if (match_lower_case && !HasRareData() && !IsASCIILower(value)) {
    CreateRareData();
  }

  if (!HasRareData()) {
    data_.value_ = value;
    return;
  }
  // TODO(xiezuobing): [LowerASCII] match_lower_case ? value.LowerASCII() : value;
  data_.rare_data_->matching_value_ = match_lower_case ? value : value;
  data_.rare_data_->serializing_value_ = value;
}

CSSSelector& CSSSelector::operator=(CSSSelector&& other) {
  this->~CSSSelector();
  new (this) CSSSelector(std::move(other));
  return *this;
}

bool CSSSelector::IsASCIILower(const std::string& value) {
  for (uint32_t i = 0; i < value.length(); ++i) {
    if (IsASCIIUpper(value[i])) {
      return false;
    }
  }
  return true;
}

std::string CSSSelector::FormatPseudoTypeForDebugging(PseudoType type) {
  for (const auto& s : kPseudoTypeWithoutArgumentsMap) {
    if (s.type == type) {
      return s.string;
    }
  }
  for (const auto& s : kPseudoTypeWithArgumentsMap) {
    if (s.type == type) {
      return s.string;
    }
  }
  StringBuilder builder;
  builder.Append("pseudo-");
  builder.Append(std::to_string(static_cast<int>(type)));
  return builder.ReleaseString();
}

CSSSelector::RareData::RareData(const std::string& value)
    : matching_value_(value),
      serializing_value_(value),
      bits_(),
      attribute_(AnyQName()),
      argument_(global_string_stdstring::knull_atom) {}

CSSSelector::RareData::~RareData() = default;

QualifiedName::~QualifiedName() = default;

}  // namespace webf
