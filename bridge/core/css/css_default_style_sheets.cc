/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "css_default_style_sheets.h"
#include "core/css/style_sheet_contents.h"
#include "core/css/parser/css_parser_context.h"

namespace webf {

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
  
  // TODO: Load actual default stylesheets
  // For now, create empty stylesheets with parser context
  auto parser_context = std::make_shared<CSSParserContext>(kHTMLStandardMode);
  default_html_style_ = std::make_shared<StyleSheetContents>(parser_context);
  default_svg_style_ = std::make_shared<StyleSheetContents>(parser_context);
  default_mathml_style_ = std::make_shared<StyleSheetContents>(parser_context);
  media_controls_style_ = std::make_shared<StyleSheetContents>(parser_context);
  fullscreen_style_ = std::make_shared<StyleSheetContents>(parser_context);
  quirks_style_ = std::make_shared<StyleSheetContents>(parser_context);
  
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
  // TODO: Implement UA sheet parsing
  auto parser_context = std::make_shared<CSSParserContext>(kHTMLStandardMode);
  return std::make_shared<StyleSheetContents>(parser_context);
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