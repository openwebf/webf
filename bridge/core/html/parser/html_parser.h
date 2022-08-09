/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#ifndef KRAKENBRIDGE_HTML_PARSER_H
#define KRAKENBRIDGE_HTML_PARSER_H

#include <third_party/gumbo-parser/src/gumbo.h>
#include <string>
#include "foundation/native_string.h"

namespace kraken {

class Node;
class Element;
class ExecutingContext;

class HTMLParser {
 public:
  static bool parseHTML(const char* code, size_t codeLength, Node* rootNode);
  static bool parseHTML(const std::string& html, Node* rootNode);
  static bool parseHTMLFragment(const char* code, size_t codeLength, Node* rootNode);

 private:
  ExecutingContext* context_;
  static void traverseHTML(Node* root, GumboNode* node);
  static void parseProperty(Element* element, GumboElement* gumboElement);

  static bool parseHTML(const std::string& html, Node* rootNode, bool isHTMLFragment);
};
}  // namespace kraken

#endif  // KRAKENBRIDGE_HTML_PARSER_H
