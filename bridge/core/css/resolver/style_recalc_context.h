// Copyright 2021 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef WEBF_CORE_CSS_RESOLVER_STYLE_RECALC_CONTEXT_H_
#define WEBF_CORE_CSS_RESOLVER_STYLE_RECALC_CONTEXT_H_

#include <memory>
#include "core/css/css_value.h"
#include "core/style/computed_style.h"

namespace webf {

class Element;
class HTMLSlotElement;
class LayoutObject;

// StyleRecalcContext is an object that is passed on the style recalc() tree
// walk. It contains context information needed for matching/computing style on
// child elements.
// StyleRecalcContext is used both for style recalc and the interleaved
// style/layout for container queries.
struct StyleRecalcContext {
  // Using the ancestor chain, build a StyleRecalcContext suitable for
  // resolving the style of the given Element. The Element is not required to
  // have a ComputedStyle.
  static StyleRecalcContext FromAncestors(Element&);

  // If the passed in element is a container for size container queries,
  // calling this method will ensure that we have an up-to-date InterpolationSize
  // for the container which will be used for container query evaluation. The
  // interpolation size will be the one from the LayoutObject, or if the
  // LayoutObject does not exist, the result will be an empty size.
  StyleRecalcContext WithInterpolationSize(Element& container);

  // The current container element, if any, for resolving container queries.
  // For a given element, this will be either the nearest ancestor container,
  // or the originating element itself if it is a container.
  Element* container = nullptr;

  // The nearest container that can have size queries queried against it.
  // TODO(crbug.com/1213888): This field is the exception to the principle that
  // StyleRecalcContext values aren't "from ComputedStyle", since whether
  // something is a size container doesn't need to be interleaved (unlike normal
  // queries). When we go back to splitting computed style updates from the
  // layout updates for containers in a lifecycle phase (or just not computing
  // them inline), we should change it so that the interleaving flag is computed
  // directly from the DOM tree, and so that size containers are eagerly laid
  // out before any lifecycle phases are run.
  Element* size_container = nullptr;

  // When updating style for a child element using StyleRecalcContext, the child
  // element inherits the parent computed style and the parent should have a
  // LayoutObject when updating the style for the child. There are some
  // exceptions:
  //
  // - display:none elements don't generate LayoutObjects. The computed style is
  //   still updated for the element and children.
  // - display:contents elements don't generate LayoutObjects on their own, but
  //   the children inherit style from the display:contents element but the first
  //   LayoutObject up the tree is the LayoutObject for the display:contents
  //   element's parent element. Keep the LayoutObject in this context up-to-date
  //   in order to let the child style recalc eventually write the resulting
  //   style to the correct LayoutObject.
  LayoutObject* layout_parent = nullptr;

  // This is set to the slot element when the <slot> element needs to reattach
  // its assigned nodes during style recalc traversal of a DOM tree. This happens
  // when the <slot> element's children/siblings/subtree have changed but the
  // assigned nodes and their children have not, so they do not get their styles
  // invalidated/recalculated.
  //
  // A good example of use would be an ancestor of the <slot> element gets
  // display:none. In this case we need to detach layout tree for the assigned
  // nodes by traversing into them during the layout tree detach phase of the
  // style recalc walk of the <slot>.
  HTMLSlotElement* force_reattach_slot = nullptr;

  // The ComputedStyle to be used for container unit resolution on the current
  // element.
  const ComputedStyle* old_style = nullptr;
};

}  // namespace webf

#endif  // WEBF_CORE_CSS_RESOLVER_STYLE_RECALC_CONTEXT_H_