/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include <utility>

#include "core/dom/document.h"
#include "core/dom/element.h"
#include "core/dom/text.h"
#include "core/executing_context.h"
#include "element_namespace_uris.h"
#include "core/html/html_element.h"
#include "foundation/logging.h"
#include "gumbo-parser/src/error.h"
#include "html_names.h"
#include "html_parser.h"

namespace webf {

std::string trim(const std::string& str) {
  std::string tmp = str;
  tmp.erase(0, tmp.find_first_not_of(' '));  // prefixing spaces
  tmp.erase(tmp.find_last_not_of(' ') + 1);  // surfixing spaces
  return tmp;
}

// Parse html,isHTMLFragment should be false if you need to automatically complete html, head, and body when they are
// missing.
GumboOutput* parse(const std::string& html, bool isHTMLFragment = false) {
  // Gumbo-parser parse HTML.
  GumboOutput* htmlTree = gumbo_parse_with_options(&kGumboDefaultOptions, html.c_str(), html.length());

  if (isHTMLFragment) {
    // Find body.
    const GumboVector* children = &htmlTree->root->v.element.children;
    for (int i = 0; i < children->length; ++i) {
      auto* child = (GumboNode*)children->data[i];
      if (child->type == GUMBO_NODE_ELEMENT) {
        std::string tagName;
        if (child->v.element.tag != GUMBO_TAG_UNKNOWN) {
          tagName = gumbo_normalized_tagname(child->v.element.tag);
        } else {
          GumboStringPiece piece = child->v.element.original_tag;
          gumbo_tag_from_original_text(&piece);
          tagName = std::string(piece.data, piece.length);
        }

        if (tagName.compare("body") == 0) {
          htmlTree->root = child;
          break;
        }
      }
    }
  }

  return htmlTree;
}

void transToSVG(GumboNode* node) {
  if (node->type == GUMBO_NODE_ELEMENT) {
    auto element = &node->v.element;
    gumbo_tag_from_original_text(&element->original_tag);
    const GumboVector* children = &element->children;
    for (int i = 0; i < children->length; ++i) {
      auto* child = (GumboNode*)children->data[i];
      transToSVG(child);
    }
  }
}

GumboOutput* parseSVG(const char* buffer, size_t length) {
  GumboOptions options = kGumboDefaultOptions;
  options.fragment_namespace = GumboNamespaceEnum::GUMBO_NAMESPACE_SVG;
  GumboOutput* svgTree = gumbo_parse_with_options(&options, buffer, length);

  return svgTree;
}

GumboNode* findSVGRoot(GumboNode* node) {
  if (node->type == GUMBO_NODE_ELEMENT) {
    auto element = &node->v.element;
    if (element->tag == GUMBO_TAG_SVG && element->tag_namespace == GUMBO_NAMESPACE_SVG) {
      return node;
    }
    auto children = &element->children;
    GumboNode* ret = nullptr;
    for (int i = 0; i < children->length; i++) {
      ret = findSVGRoot((GumboNode*)children->data[i]);
      if (ret != nullptr) {
        return ret;
      }
    }
  }

  return nullptr;
}

bool HTMLParser::traverseHTML(Node* root_node, GumboNode* node) {
  if (root_node == nullptr || node == nullptr) {
    WEBF_LOG(ERROR) << "Invalid node in traverseHTML";
    return false;
  }

  auto* context = root_node->GetExecutingContext();
  if (context == nullptr) {
    WEBF_LOG(ERROR) << "No executing context in traverseHTML";
    return false;
  }

  JSContext* ctx = context->ctx();

  // Handle root element attributes (e.g., <html> tag)
  if (node->type == GUMBO_NODE_ELEMENT) {
    auto* html_element = DynamicTo<Element>(root_node);
    if (html_element != nullptr && html_element->localName() == html_names::kHtml) {
      parseProperty(html_element, &node->v.element);
    }
  }

  // Process children nodes
  if (node->type == GUMBO_NODE_ELEMENT) {
    const GumboVector* children = &node->v.element.children;
    for (int i = 0; i < children->length; ++i) {
      auto* child = (GumboNode*)children->data[i];
      
      if (child == nullptr) {
        continue; // Skip null children
      }

      auto* root_container = DynamicTo<ContainerNode>(root_node);
      if (root_container == nullptr) {
        continue; // Skip if not a container
      }

      if (child->type == GUMBO_NODE_ELEMENT) {
        std::string tagName;
        if (child->v.element.tag != GUMBO_TAG_UNKNOWN) {
          tagName = gumbo_normalized_tagname(child->v.element.tag);
        } else {
          GumboStringPiece piece = child->v.element.original_tag;
          gumbo_tag_from_original_text(&piece);
          tagName = std::string(piece.data, piece.length);
        }

        // Skip empty tag names
        if (tagName.empty()) {
          WEBF_LOG(WARN) << "Skipping element with empty tag name";
          continue;
        }

        Element* element = nullptr;
        ExceptionState exception_state;

        switch (child->v.element.tag_namespace) {
          case ::GUMBO_NAMESPACE_SVG: {
            element = context->document()->createElementNS(element_namespace_uris::ksvg, AtomicString(ctx, tagName),
                                                           exception_state);
            break;
          }
          default: {
            element = context->document()->createElement(AtomicString(ctx, tagName), exception_state);
          }
        }

        if (exception_state.HasException()) {
          context->HandleException(exception_state);
          WEBF_LOG(ERROR) << "Failed to create element: " << tagName;
          continue; // Continue processing other elements
        }

        if (element == nullptr) {
          WEBF_LOG(ERROR) << "Failed to create element (null): " << tagName;
          continue;
        }

        // Recursively traverse children
        if (!traverseHTML(element, child)) {
          // Log but continue processing other children
          WEBF_LOG(WARN) << "Failed to traverse child element: " << tagName;
        }

        // Append child
        root_container->AppendChild(element);
        
        // Parse attributes
        parseProperty(element, &child->v.element);
        
      } else if (child->type == GUMBO_NODE_TEXT) {
        // Handle text nodes
        const char* text_content = child->v.text.text;
        if (text_content != nullptr) {
          ExceptionState exception_state;
          auto* text = context->document()->createTextNode(AtomicString(ctx, text_content), exception_state);
          if (!exception_state.HasException() && text != nullptr) {
            root_container->AppendChild(text);
          } else if (exception_state.HasException()) {
            context->HandleException(exception_state);
          }
        }
      } else if (child->type == GUMBO_NODE_CDATA) {
        // Handle CDATA sections as text
        const char* cdata_content = child->v.text.text;
        if (cdata_content != nullptr) {
          ExceptionState exception_state;
          auto* text = context->document()->createTextNode(AtomicString(ctx, cdata_content), exception_state);
          if (!exception_state.HasException() && text != nullptr) {
            root_container->AppendChild(text);
          } else if (exception_state.HasException()) {
            context->HandleException(exception_state);
          }
        }
      }
      // Ignore other node types (comments, etc.)
    }
  }

  return true;
}

bool HTMLParser::parseHTML(const std::string& html, Node* root_node, bool isHTMLFragment) {
  if (root_node == nullptr) {
    WEBF_LOG(ERROR) << "Root node is null.";
    return false;
  }

  auto* context = root_node->GetExecutingContext();
  if (context == nullptr) {
    WEBF_LOG(ERROR) << "Executing context is null.";
    return false;
  }

  auto* root_container_node = DynamicTo<ContainerNode>(root_node);
  if (root_container_node == nullptr) {
    ExceptionState exception_state;
    exception_state.ThrowException(context->ctx(), ErrorType::TypeError, "Root node is not a container node");
    context->HandleException(exception_state);
    return false;
  }

  // Clear existing children
  {
    MemberMutationScope scope{context};
    root_container_node->RemoveChildren();
  }

  std::string trimmed_html = trim(html);
  if (trimmed_html.empty()) {
    // Empty HTML is valid - just return success
    return true;
  }

  // Parse HTML with Gumbo - it has built-in error recovery
  GumboOutput* htmlTree = parse(html, isHTMLFragment);
  if (htmlTree == nullptr) {
    ExceptionState exception_state;
    exception_state.ThrowException(context->ctx(), ErrorType::TypeError, "Failed to parse HTML: Invalid HTML content");
    context->HandleException(exception_state);
    return false;
  }

  // Check for parsing errors but continue - Gumbo provides error recovery
  if (htmlTree->errors.length > 0) {
    WEBF_LOG(WARN) << "HTML parsing completed with " << htmlTree->errors.length << " recoverable errors.";
    // Log first few errors for debugging
    for (int i = 0; i < std::min(3, (int)htmlTree->errors.length); i++) {
      auto* error = (GumboError*)htmlTree->errors.data[i];
      WEBF_LOG(VERBOSE) << "HTML Error at line " << error->position.line
                      << ", column " << error->position.column;
    }
  }

  // Traverse and build DOM tree
  bool traverse_result = traverseHTML(root_container_node, htmlTree->root);
  
  // Free gumbo parse nodes
  gumbo_destroy_output(&kGumboDefaultOptions, htmlTree);
  
  // Return success even if some elements failed - partial DOM is better than no DOM
  if (!traverse_result) {
    WEBF_LOG(WARN) << "HTML traversal completed with errors - partial DOM tree may have been created";
  }
  
  return true;
}

bool HTMLParser::parseHTML(const std::string& html, Node* root_node) {
  return parseHTML(html, root_node, false);
}

bool HTMLParser::parseHTML(const char* code, size_t codeLength, Node* root_node) {
  std::string html = std::string(code, codeLength);
  return parseHTML(html, root_node, false);
}

bool HTMLParser::parseHTMLFragment(const char* code, size_t codeLength, Node* rootNode) {
  std::string html = std::string(code, codeLength);
  return parseHTML(html, rootNode, true);
}

GumboOutput* HTMLParser::parseSVGResult(const char* code, size_t codeLength) {
  std::string svg = std::string(code, codeLength);
  auto result = parseSVG(code, codeLength);
  auto root = findSVGRoot(result->root);
  if (root != nullptr) {
    transToSVG(root);
  }

  return result;
}

void HTMLParser::freeSVGResult(GumboOutput* svgTree) {
  gumbo_destroy_output(&kGumboDefaultOptions, svgTree);
}

void HTMLParser::parseProperty(Element* element, GumboElement* gumboElement) {
  auto* context = element->GetExecutingContext();
  JSContext* ctx = context->ctx();

  GumboVector* attributes = &gumboElement->attributes;
  for (int j = 0; j < attributes->length; ++j) {
    auto* attribute = (GumboAttribute*)attributes->data[j];

    std::string strName = attribute->name;
    std::string strValue = attribute->value;
    element->setAttribute(AtomicString(ctx, strName), AtomicString(ctx, strValue), ASSERT_NO_EXCEPTION());
  }
}

}  // namespace webf
