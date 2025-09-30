/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "css_default_style_sheets.h"
#include "core/css/style_sheet_contents.h"
#include "core/css/parser/css_parser_context.h"
#include "core/css/parser/css_parser.h"
#include "core/css/rule_set.h"
#include "foundation/logging.h"
#include "code_gen/html_css.h"
#include "code_gen/quirks_css.h"

// Undefine Windows macros that conflict with our logging constants
#ifdef ERROR
#undef ERROR
#endif

namespace webf {

// Default HTML stylesheet - loaded from bridge/core/css/resources/html.css via CMake
const char* kHTMLDefaultStyle = kHTMLDefaultCSS;


// Quirks mode stylesheet
const char* kQuirksDefaultStyle = kQuirksDefaultCSS;

std::shared_ptr<StyleSheetContents> CSSDefaultStyleSheets::default_html_style_;
std::shared_ptr<StyleSheetContents> CSSDefaultStyleSheets::default_svg_style_;
std::shared_ptr<StyleSheetContents> CSSDefaultStyleSheets::default_mathml_style_;
std::shared_ptr<StyleSheetContents> CSSDefaultStyleSheets::media_controls_style_;
std::shared_ptr<StyleSheetContents> CSSDefaultStyleSheets::fullscreen_style_;
std::shared_ptr<StyleSheetContents> CSSDefaultStyleSheets::quirks_style_;
bool CSSDefaultStyleSheets::is_initialized_ = false;

void CSSDefaultStyleSheets::Init() {
  if (is_initialized_) {
    return;
  }
  
  // Parse default HTML stylesheet
  default_html_style_ = ParseUASheet(kHTMLDefaultStyle);
  
  if (default_html_style_) {
    WEBF_LOG(VERBOSE) << "UA stylesheet parsed, rule count: " << default_html_style_->RuleCount();
  } else {
    WEBF_LOG(ERROR) << "Failed to parse UA stylesheet";
  }
  
  // Parse quirks mode stylesheet
  quirks_style_ = ParseUASheet(kQuirksDefaultStyle);
  
  // TODO: Add SVG, MathML, media controls, and fullscreen stylesheets when needed
  auto parser_context = std::make_shared<CSSParserContext>(kUASheetMode);
  default_svg_style_ = std::make_shared<StyleSheetContents>(parser_context);
  default_mathml_style_ = std::make_shared<StyleSheetContents>(parser_context);
  media_controls_style_ = std::make_shared<StyleSheetContents>(parser_context);
  fullscreen_style_ = std::make_shared<StyleSheetContents>(parser_context);
  
  is_initialized_ = true;
}

bool CSSDefaultStyleSheets::IsInitialized() {
  return is_initialized_;
}

std::shared_ptr<StyleSheetContents> CSSDefaultStyleSheets::DefaultHTMLStyle() {
  if (!is_initialized_) {
    Init();
  }
  return default_html_style_;
}

std::shared_ptr<StyleSheetContents> CSSDefaultStyleSheets::DefaultSVGStyle() {
  if (!is_initialized_) {
    Init();
  }
  return default_svg_style_;
}

std::shared_ptr<StyleSheetContents> CSSDefaultStyleSheets::DefaultMathMLStyle() {
  if (!is_initialized_) {
    Init();
  }
  return default_mathml_style_;
}

std::shared_ptr<StyleSheetContents> CSSDefaultStyleSheets::MediaControlsStyle() {
  if (!is_initialized_) {
    Init();
  }
  return media_controls_style_;
}

std::shared_ptr<StyleSheetContents> CSSDefaultStyleSheets::FullscreenStyle() {
  if (!is_initialized_) {
    Init();
  }
  return fullscreen_style_;
}

std::shared_ptr<StyleSheetContents> CSSDefaultStyleSheets::QuirksStyle() {
  if (!is_initialized_) {
    Init();
  }
  return quirks_style_;
}

std::shared_ptr<StyleSheetContents> CSSDefaultStyleSheets::ParseUASheet(const char* css) {
  // UA stylesheets always parse in the UA sheet mode
  auto parser_context = std::make_shared<CSSParserContext>(kUASheetMode);
  auto sheet = std::make_shared<StyleSheetContents>(parser_context);


  // TODO: remove UA Style all togather.
  // Parse the CSS string - we need to use ParseSheet directly with the UA context
  // instead of ParseString which creates its own context
  // CSSParser::ParseSheet(parser_context, sheet, String::FromUTF8(css));
  
  // WEBF_LOG(VERBOSE) << "Parsed UA stylesheet, rule count: " << sheet->RuleCount();
  
  return sheet;
}

void CSSDefaultStyleSheets::Reset() {
  // Reset all static style sheets to release memory
  default_html_style_.reset();
  default_svg_style_.reset();
  default_mathml_style_.reset();
  media_controls_style_.reset();
  fullscreen_style_.reset();
  quirks_style_.reset();
  
  // Mark as uninitialized so they can be recreated if needed
  is_initialized_ = false;
}

}  // namespace webf