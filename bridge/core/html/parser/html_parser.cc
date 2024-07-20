/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include <utility>

#include "core/dom/document.h"
#include "core/dom/element.h"
#include "core/dom/text.h"
#include "html_element_type_helper.h"
#include "core/html/html_script_element.h"
#include "element_attribute_names.h"
#include "element_namespace_uris.h"
#include "foundation/logging.h"
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

void HTMLParser::traverseHTML(Node* root_node, GumboNode* node) {
  auto* context = root_node->GetExecutingContext();
  JSContext* ctx = root_node->GetExecutingContext()->ctx();

  auto* html_element = DynamicTo<Element>(root_node);
  if (html_element != nullptr && html_element->localName() == html_names::khtml) {
    bool _ = false;
    parseProperty(html_element, &node->v.element, &_, &_);
  }

  const GumboVector* children = &node->v.element.children;
  for (int i = 0; i < children->length; ++i) {
    auto* child = (GumboNode*)children->data[i];

    if (auto* root_container = DynamicTo<ContainerNode>(root_node)) {
      if (child->type == GUMBO_NODE_ELEMENT) {
        std::string tagName;
        if (child->v.element.tag != GUMBO_TAG_UNKNOWN) {
          tagName = gumbo_normalized_tagname(child->v.element.tag);
        } else {
          GumboStringPiece piece = child->v.element.original_tag;
          gumbo_tag_from_original_text(&piece);
          tagName = std::string(piece.data, piece.length);
        }

        Element* element;

        switch (child->v.element.tag_namespace) {
          case ::GUMBO_NAMESPACE_SVG: {
            element = context->document()->createElementNS(element_namespace_uris::ksvg, AtomicString(ctx, tagName),
                                                           ASSERT_NO_EXCEPTION());
            break;
          }

          default: {
            element = context->document()->createElement(AtomicString(ctx, tagName), ASSERT_NO_EXCEPTION());
          }
        }

        bool is_script_element = child->v.element.tag == GumboTag::GUMBO_TAG_SCRIPT;
        bool is_standard_script_element = false;
        bool is_wbc_script_element;
        parseProperty(element, &child->v.element, &is_wbc_script_element, &is_standard_script_element);
        if (is_script_element && child->v.element.children.length > 0) {
          auto& gumbo_script_element = child->v.element;
          assert(gumbo_script_element.children.length == 1);
          auto* script_text_node = (GumboNode*)gumbo_script_element.children.data[0];
          auto* script_element = DynamicTo<HTMLScriptElement>(element);

          if (is_wbc_script_element) {
            auto* bytes = (uint8_t*)script_text_node->v.text.original_text.data;
            size_t total_length = script_text_node->v.text.original_text.length;
            if (script_text_node->v.text.original_text.length < 20) {
              return;
            }
            uint32_t start = -1;
            // Search first 10 bytes to find start
            for (size_t index = 0; index < 11; index++) {
              // Verify the WBC file signature.
              // https://github.com/openwebf/rfc/pull/5/files#diff-b26b0f961278d1abed24f2f4874e802e99d5f92b13cbd5f0652b47597647ed26R34
              if (bytes[index] == 0x89 && bytes[index + 1] == 0x57 && bytes[index + 2] == 0x42 &&
                  bytes[index + 3] == 0x43 && bytes[index + 4] == 0x31 && bytes[index + 5] == 0x0D &&
                  bytes[index + 6] == 0x0A && bytes[index + 7] == 0x1A && bytes[index + 8] == 0x0A) {
                start = index;
                break;
              }
            }
            if (start == -1) continue;

            uint32_t script_id = script_element->StoreWBCByteBuffer(bytes + start, total_length - start);
            script_element->setAttribute(element_attribute_names::k__script_id__,
                                         AtomicString(ctx, std::to_string(script_id)));
          } else {
            uint32_t script_id = script_element->StoreUTF8String(script_text_node->v.text.original_text.data,
                                            script_text_node->v.text.original_text.length);
            script_element->setAttribute(element_attribute_names::k__script_id__,
                                         AtomicString(ctx, std::to_string(script_id)));
          }
          root_container->AppendChild(element);
        } else {
          traverseHTML(element, child);
          root_container->AppendChild(element);
        }
      } else if (child->type == GUMBO_NODE_TEXT) {
        auto* text =
            context->document()->createTextNode(AtomicString(ctx, child->v.text.text), ASSERT_NO_EXCEPTION());
        root_container->AppendChild(text);
      }
    }
  }
}

bool HTMLParser::parseHTML(const std::string& html, Node* root_node, bool isHTMLFragment) {
  if (root_node != nullptr) {
    if (auto* root_container_node = DynamicTo<ContainerNode>(root_node)) {
      {
        MemberMutationScope scope{root_node->GetExecutingContext()};
        root_container_node->RemoveChildren();
      }

      if (!trim(html).empty()) {
        root_node->GetExecutingContext()->dartIsolateContext()->profiler()->StartTrackSteps("HTMLParser::parse");

        GumboOutput* htmlTree = parse(html, isHTMLFragment);

        root_node->GetExecutingContext()->dartIsolateContext()->profiler()->FinishTrackSteps();
        root_node->GetExecutingContext()->dartIsolateContext()->profiler()->StartTrackSteps("HTMLParser::traverseHTML");

        traverseHTML(root_container_node, htmlTree->root);
        // Free gumbo parse nodes.
        gumbo_destroy_output(&kGumboDefaultOptions, htmlTree);

        root_node->GetExecutingContext()->dartIsolateContext()->profiler()->FinishTrackSteps();
      }
    }
  } else {
    WEBF_LOG(ERROR) << "Root node is null.";
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

void HTMLParser::parseProperty(Element* element, GumboElement* gumboElement, bool* is_wbc_scripts_element, bool* is_standard_script_element) {
  auto* context = element->GetExecutingContext();
  JSContext* ctx = context->ctx();

  bool is_script_element = gumboElement->tag == GumboTag::GUMBO_TAG_SCRIPT;

  GumboVector* attributes = &gumboElement->attributes;
  for (int j = 0; j < attributes->length; ++j) {
    auto* attribute = (GumboAttribute*)attributes->data[j];

    std::string strName = attribute->name;
    std::string strValue = attribute->value;

    if (is_script_element) {
      if (strName == "type" && strValue == "application/vnd.webf.bc1") {
        *is_wbc_scripts_element = true;
      } else {
        *is_standard_script_element = true;
      }
    }

    element->setAttribute(AtomicString(ctx, strName), AtomicString(ctx, strValue), ASSERT_NO_EXCEPTION());
  }
}

}  // namespace webf
