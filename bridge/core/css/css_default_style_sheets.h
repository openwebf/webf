/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CSS_DEFAULT_STYLE_SHEETS_H
#define WEBF_CSS_DEFAULT_STYLE_SHEETS_H

#include <memory>
#include "foundation/macros.h"

namespace webf {

class StyleSheetContents;
class Document;

// Manages the default style sheets for different contexts
class CSSDefaultStyleSheets {
  WEBF_STATIC_ONLY(CSSDefaultStyleSheets);

 public:
  // Get the default HTML style sheet
  static std::shared_ptr<StyleSheetContents> DefaultHTMLStyle();
  
  // Get the default SVG style sheet
  static std::shared_ptr<StyleSheetContents> DefaultSVGStyle();
  
  // Get the default MathML style sheet
  static std::shared_ptr<StyleSheetContents> DefaultMathMLStyle();
  
  // Get the default media controls style sheet
  static std::shared_ptr<StyleSheetContents> MediaControlsStyle();
  
  // Get the default full screen style sheet
  static std::shared_ptr<StyleSheetContents> FullscreenStyle();
  
  // Get the quirks mode style sheet
  static std::shared_ptr<StyleSheetContents> QuirksStyle();
  
  // Initialize default styles
  static void Init();
  
  // Check if initialized
  static bool IsInitialized();
  
  // Reset all default style sheets (for testing)
  static void Reset();
  
 private:
  static std::shared_ptr<StyleSheetContents> ParseUASheet(const char* css);
  
  static std::shared_ptr<StyleSheetContents> default_html_style_;
  static std::shared_ptr<StyleSheetContents> default_svg_style_;
  static std::shared_ptr<StyleSheetContents> default_mathml_style_;
  static std::shared_ptr<StyleSheetContents> media_controls_style_;
  static std::shared_ptr<StyleSheetContents> fullscreen_style_;
  static std::shared_ptr<StyleSheetContents> quirks_style_;
  static bool is_initialized_;
};

}  // namespace webf

#endif  // WEBF_CSS_DEFAULT_STYLE_SHEETS_H