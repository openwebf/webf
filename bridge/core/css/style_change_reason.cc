// Copyright 2014 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#include "core/css/style_change_reason.h"
// #include "third_party/blink/renderer/platform/wtf/static_constructors.h"

namespace webf {

namespace style_change_reason {
const char kAccessibility[] = "Accessibility";
const char kActiveStylesheetsUpdate[] = "ActiveStylesheetsUpdate";
const char kAffectedByHas[] = "Affected by :has()";
const char kAnimation[] = "Animation";
const char kAttribute[] = "Attribute";
const char kConditionalBackdrop[] = "Conditional ::backdrop";
const char kControl[] = "Control";
const char kControlValue[] = "ControlValue";
const char kDeclarativeContent[] = "Extension declarativeContent.css";
const char kDesignMode[] = "DesignMode";
const char kDialog[] = "Dialog";
const char kDisplayLock[] = "DisplayLock";
const char kEditContext[] = "EditContext";
const char kViewTransition[] = "ViewTransition";
const char kFlatTreeChange[] = "FlatTreeChange";
const char kFonts[] = "Fonts";
const char kFrame[] = "Frame";
const char kFullscreen[] = "Fullscreen";
const char kFunctionRuleChange[] = "@function rule change";
const char kInheritedStyleChangeFromParentFrame[] = "InheritedStyleChangeFromParentFrame";
const char kInlineCSSStyleMutated[] = "Inline CSS style declaration was mutated";
const char kInspector[] = "Inspector";
const char kKeyframesRuleChange[] = "@keyframes rule change";
const char kLanguage[] = "Language";
const char kLinkColorChange[] = "LinkColorChange";
const char kPictureSourceChanged[] = "PictureSourceChange";
const char kPlatformColorChange[] = "PlatformColorChange";
const char kPluginChanged[] = "Plugin Changed";
const char kPopoverVisibilityChange[] = "Popover Visibility Change";
const char kPositionTryChange[] = "@position-try change";
const char kPrinting[] = "Printing";
const char kPropertyRegistration[] = "PropertyRegistration";
const char kPseudoClass[] = "PseudoClass";
const char kRelatedStyleRule[] = "Related style rule";
const char kScrollTimeline[] = "ScrollTimeline";
const char kSVGContainerSizeChange[] = "SVGContainerSizeChange";
const char kSettings[] = "Settings";
const char kShadow[] = "Shadow";
const char kStyleAttributeChange[] = "Style attribute change";
const char kStyleRuleChange[] = "Style rule change";
const char kTopLayer[] = "TopLayer";
const char kUseFallback[] = "UseFallback";
const char kViewportDefiningElement[] = "ViewportDefiningElement";
const char kViewportUnits[] = "ViewportUnits";
const char kVisuallyOrdered[] = "VisuallyOrdered";
const char kWritingModeChange[] = "WritingModeChange";
const char kZoom[] = "Zoom";
}  // namespace style_change_reason

namespace style_change_extra_data {
DEFINE_GLOBAL(std::string, g_active);
DEFINE_GLOBAL(std::string, g_active_view_transition);
DEFINE_GLOBAL(std::string, g_active_view_transition_type);
DEFINE_GLOBAL(std::string, g_disabled);
DEFINE_GLOBAL(std::string, g_drag);
DEFINE_GLOBAL(std::string, g_focus);
DEFINE_GLOBAL(std::string, g_focus_visible);
DEFINE_GLOBAL(std::string, g_focus_within);
DEFINE_GLOBAL(std::string, g_hover);
DEFINE_GLOBAL(std::string, g_past);
DEFINE_GLOBAL(std::string, g_unresolved);

void Init() {
  new ((void*)&g_active) std::string(":active");
  new ((void*)&g_active_view_transition) std::string(":active_view_transition");
  new ((void*)&g_active_view_transition_type) std::string(":active_view_transition_type");
  new ((void*)&g_disabled) std::string(":disabled");
  new ((void*)&g_drag) std::string(":-webkit-drag");
  new ((void*)&g_focus) std::string(":focus");
  new ((void*)&g_focus_visible) std::string(":focus-visible");
  new ((void*)&g_focus_within) std::string(":focus-within");
  new ((void*)&g_hover) std::string(":hover");
  new ((void*)&g_past) std::string(":past");
  new ((void*)&g_unresolved) std::string(":unresolved");
}

}  // namespace style_change_extra_data

}  // namespace webf