/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "css_default_style_sheets.h"
#include "core/css/style_sheet_contents.h"
#include "core/css/parser/css_parser_context.h"
#include "core/css/parser/css_parser.h"
#include "core/css/rule_set.h"
#include "foundation/logging.h"

namespace webf {

// Default HTML stylesheet
const char kHTMLDefaultStyle[] = R"CSS(
/* base elements */

body {
    display: block;
    margin: 8px;
}

p {
    display: block;
    margin-top: 1em;
    margin-bottom: 1em;
    margin-left: 0;
    margin-right: 0;
}

div {
    display: block;
}

/* other common elements */
article, aside, footer, header, main, nav, section {
    display: block;
}
)CSS";

// Full HTML stylesheet - temporarily disabled
const char kHTMLDefaultStyleFull[] = R"CSS(
html {
    display: block;
}

/* generic block-level elements */

body {
    display: block;
    margin: 8px;
}

p {
    display: block;
    margin-top: 1em;
    margin-bottom: 1em;
    margin-left: 0;
    margin-right: 0;
}

div {
    display: block
}

article, aside, footer, header, hgroup, main, nav, section {
    display: block
}

address {
    display: block
}

blockquote {
    display: block;
    margin-block-start: 1em;
    margin-block-end: 1em;
    margin-inline-start: 40px;
    margin-inline-end: 40px;
}

figcaption {
    display: block
}

figure {
    display: block;
    margin-block-start: 1em;
    margin-block-end: 1em;
    margin-inline-start: 40px;
    margin-inline-end: 40px;
}

q {
    display: inline
}

/* TODO: Enable pseudo-element rules after fixing selector matching
q:before {
    content: open-quote;
}

q:after {
    content: close-quote;
}
*/

center {
    display: block;
    text-align: center
}

hr {
    display: block;
    margin-block-start: 0.5em;
    margin-block-end: 0.5em;
    margin-inline-start: auto;
    margin-inline-end: auto;
    border-style: inset;
    border-width: 1px
}

/* heading elements */

h1 {
    display: block;
    font-size: 2em;
    margin-block-start: 0.67em;
    margin-block-end: 0.67em;
    margin-inline-start: 0;
    margin-inline-end: 0;
    font-weight: bold
}

h2 {
    display: block;
    font-size: 1.5em;
    margin-block-start: 0.83em;
    margin-block-end: 0.83em;
    margin-inline-start: 0;
    margin-inline-end: 0;
    font-weight: bold
}

h3 {
    display: block;
    font-size: 1.17em;
    margin-block-start: 1em;
    margin-block-end: 1em;
    margin-inline-start: 0;
    margin-inline-end: 0;
    font-weight: bold
}

h4 {
    display: block;
    margin-block-start: 1.33em;
    margin-block-end: 1.33em;
    margin-inline-start: 0;
    margin-inline-end: 0;
    font-weight: bold
}

h5 {
    display: block;
    font-size: .83em;
    margin-block-start: 1.67em;
    margin-block-end: 1.67em;
    margin-inline-start: 0;
    margin-inline-end: 0;
    font-weight: bold
}

h6 {
    display: block;
    font-size: .67em;
    margin-block-start: 2.33em;
    margin-block-end: 2.33em;
    margin-inline-start: 0;
    margin-inline-end: 0;
    font-weight: bold
}

/* lists */

ul, menu, dir {
    display: block;
    list-style-type: disc;
    margin-block-start: 1em;
    margin-block-end: 1em;
    margin-inline-start: 0;
    margin-inline-end: 0;
    padding-inline-start: 40px
}

ol {
    display: block;
    list-style-type: decimal;
    margin-block-start: 1em;
    margin-block-end: 1em;
    margin-inline-start: 0;
    margin-inline-end: 0;
    padding-inline-start: 40px
}

li {
    display: list-item;
    text-align: match-parent;
}

ul ul, ol ul {
    list-style-type: circle
}

ol ol ul, ol ul ul, ul ol ul, ul ul ul {
    list-style-type: square
}

dd {
    display: block;
    margin-inline-start: 40px
}

dl {
    display: block;
    margin-block-start: 1em;
    margin-block-end: 1em;
    margin-inline-start: 0;
    margin-inline-end: 0;
}

dt {
    display: block
}

/* form elements */

form {
    display: block;
    margin-top: 0em;
}

label {
    cursor: default;
}

legend {
    display: block;
    padding-inline-start: 2px;
    padding-inline-end: 2px;
    border: none
}

fieldset {
    display: block;
    margin-inline-start: 2px;
    margin-inline-end: 2px;
    padding-block-start: 0.35em;
    padding-inline-start: 0.75em;
    padding-inline-end: 0.75em;
    padding-block-end: 0.625em;
    border: 2px groove ThreeDFace;
    min-inline-size: min-content;
}

button {
    appearance: auto;
}

/* tables */

table {
    display: table;
    border-collapse: separate;
    border-spacing: 2px;
    border-color: gray
}

thead {
    display: table-header-group;
    vertical-align: middle;
    border-color: inherit
}

tbody {
    display: table-row-group;
    vertical-align: middle;
    border-color: inherit
}

tfoot {
    display: table-footer-group;
    vertical-align: middle;
    border-color: inherit
}

/* for tables without table section elements (can happen with XHTML or dynamically created tables) */
table > tr {
    vertical-align: middle;
}

col {
    display: table-column
}

colgroup {
    display: table-column-group
}

tr {
    display: table-row;
    vertical-align: inherit;
    border-color: inherit
}

td, th {
    display: table-cell;
    vertical-align: inherit
}

th {
    font-weight: bold;
    text-align: center
}

caption {
    display: table-caption;
    text-align: center
}

/* inline elements */

a:link {
    color: -webkit-link;
    text-decoration: underline;
    cursor: pointer;
}

a:visited {
    color: -webkit-visited-link;
    text-decoration: underline;
    cursor: pointer;
}

a:active {
    color: -webkit-active-link;
}

b, strong {
    font-weight: bold
}

i, cite, em, var, address, dfn {
    font-style: italic
}

tt, code, kbd, samp {
    font-family: monospace
}

pre, xmp, plaintext, listing {
    display: block;
    font-family: monospace;
    white-space: pre;
    margin: 1em 0
}

mark {
    background-color: yellow;
    color: black
}

big {
    font-size: larger
}

small {
    font-size: smaller
}

s, strike, del {
    text-decoration: line-through
}

sub {
    vertical-align: sub;
    font-size: smaller
}

sup {
    vertical-align: super;
    font-size: smaller
}

nobr {
    white-space: nowrap
}

/* states */

:focus {
    outline: auto 5px -webkit-focus-ring-color
}

/* HTML5 ruby elements */

ruby, rt {
    text-indent: 0;
}

rt {
    line-height: normal;
}

ruby > rt {
    display: block;
    font-size: 50%;
    text-align: start;
}

ruby > rp {
    display: none;
}

/* other elements */

noframes {
    display: none
}

frameset, frame {
    display: block
}

frameset {
    border-color: inherit
}

iframe {
    border: 2px inset
}

details {
    display: block
}

summary {
    display: block
}

template {
    display: none
}

bdi, output {
    unicode-bidi: isolate;
}

bdo {
    unicode-bidi: bidi-override;
}

textarea {
    appearance: auto;
    border: 1px solid -internal-light-dark(rgb(118, 118, 118), rgb(133, 133, 133));
    font-family: monospace;
    white-space: pre-wrap;
    overflow-wrap: break-word;
    column-count: initial !important;
    resize: auto;
    cursor: text;
    padding: 2px;
}

input {
    appearance: auto;
    padding: 1px;
    background-color: white;
    border: 2px inset;
    cursor: text;
}

input[type="button"], input[type="submit"], input[type="reset"] {
    appearance: auto;
    cursor: default;
}

input[type="checkbox"], input[type="radio"] {
    margin: 3px 0.5ex;
    padding: initial;
    background-color: initial;
    border: initial;
}

input[type="button"], input[type="submit"], input[type="reset"], button {
    align-items: flex-start;
    text-align: center;
    cursor: default;
    color: ButtonText;
    padding: 2px 6px 3px 6px;
    border: 2px outset ButtonFace;
    background-color: ButtonFace;
    box-sizing: border-box;
}

input[type="range"] {
    appearance: auto;
    cursor: default;
    padding: initial;
    border: initial;
    margin: 2px;
}

input[type="file"] {
    align-items: baseline;
    cursor: default;
    overflow: hidden;
}

input:-webkit-autofill {
    background-color: #FAFFBD !important;
    background-image: none !important;
    color: -internal-light-dark(black, white) !important;
}

/* HTML5 meter and progress elements */

meter {
    appearance: auto;
    box-sizing: border-box;
    display: inline-block;
    height: 1em;
    width: 5em;
    vertical-align: -0.2em;
}

progress {
    appearance: auto;
    box-sizing: border-box;
    display: inline-block;
    height: 1em;
    width: 10em;
    vertical-align: -0.2em;
}

/* inline tables */

table[align="left"] {
    float: left;
}

table[align="right"] {
    float: right;
}

/* https://html.spec.whatwg.org/multipage/rendering.html#the-hr-element-rendering */
hr[align=left] {
    margin-left: 0;
    margin-right: auto;
}

hr[align=right] {
    margin-left: auto;
    margin-right: 0;
}

hr[align=center] {
    margin-left: auto;
    margin-right: auto;
}

/* noscript is handled internally, as it depends on settings. */

/* Default media controls */

video {
    object-fit: contain;
}

video:-webkit-full-page-media {
    margin: auto;
    position: absolute;
    top: 0;
    right: 0;
    bottom: 0;
    left: 0;
    max-height: 100%;
    max-width: 100%;
}

audio:not([controls]) {
    display: none !important;
}

audio {
    width: 300px;
    height: 30px;
}

/* Default styles for the HTML5 hidden attribute */

[hidden] {
    display: none
}

/* Heading navigation */

h1[id],
h2[id],
h3[id],
h4[id],
h5[id],
h6[id] {
    scroll-margin-block: 0.5em;
}

/* Margin collapsing quirks */

td > p:first-child, th > p:first-child {
    margin-block-start: 0;
}

td > p:last-child, th > p:last-child {
    margin-block-end: 0;
}
)CSS";

// Quirks mode stylesheet
const char kQuirksDefaultStyle[] = R"CSS(
/* Give floated images margins of 3px */
img[align="left" i] {
    margin-right: 3px;
}
img[align="right" i] {
    margin-left: 3px;
}

/* Tables reset both line-height and white-space in quirks mode. */
/* Compatible with WinIE. Note that font-family is *not* reset. */
table {
    white-space: normal;
    line-height: normal;
    font-weight: normal;
    font-size: medium;
    font-variant: normal;
    font-style: normal;
    color: -internal-quirk-inherit;
    text-align: start;
}

/* This will apply only to text fields, since all other inputs already use border box sizing */
input:not([type=image i]), textarea {
    box-sizing: border-box;
}

/* Set margin-bottom for form element in quirks mode. */
/* Compatible with Gecko. (Doing this only for quirks mode is a fix for bug 17696.) */
form {
    margin-block-end: 1em
}
)CSS";

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
  
  // Parse the CSS string - we need to use ParseSheet directly with the UA context
  // instead of ParseString which creates its own context
  CSSParser::ParseSheet(parser_context, sheet, css);
  
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