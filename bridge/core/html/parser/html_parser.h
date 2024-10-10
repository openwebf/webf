/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#ifndef BRIDGE_HTML_PARSER_H
#define BRIDGE_HTML_PARSER_H

#include <third_party/gumbo-parser/src/gumbo.h>
#include <string>
#include "foundation/native_string.h"

namespace webf {

class Node;
class Element;
class ExecutingContext;

std::string trim(const std::string& str);

class HTMLParser {
 public:
  static bool parseHTML(const char* code, size_t codeLength, Node* rootNode);
  static bool parseHTML(const std::string& html, Node* rootNode);
  static bool parseHTMLFragment(const char* code, size_t codeLength, Node* rootNode);

  static GumboOutput* parseSVGResult(const char* code, size_t codeLength);
  static void freeSVGResult(GumboOutput* svgTree);

 private:
  ExecutingContext* context_;
  static void traverseHTML(Node* root, GumboNode* node);
  static void parseProperty(Element* element, GumboElement* gumboElement, bool* is_wbc_scripts_element, bool* is_standard_script_element);

  static bool parseHTML(const std::string& html, Node* rootNode, bool isHTMLFragment);
};
}  // namespace webf

#endif  // BRIDGE_HTML_PARSER_H
