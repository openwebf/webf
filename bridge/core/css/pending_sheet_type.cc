//
// Created by 谢作兵 on 06/06/24.
//

#include "pending_sheet_type.h"


#include "core/dom/document.h"
#include "core/dom/element.h"
//#include "core/html/blocking_attribute.h"
#include "core/html/html_element.h"

namespace webf {


std::pair<PendingSheetType, RenderBlockingBehavior>
ComputePendingSheetTypeAndRenderBlockingBehavior(Element& sheet_owner,
                                                 bool is_critical_sheet,
                                                 bool is_created_by_parser) {
  if (!is_critical_sheet) {
    return std::make_pair(PendingSheetType::kNonBlocking,
                          RenderBlockingBehavior::kNonBlocking);
  }
  if (is_created_by_parser) {
    //TODO(xiezuobing):
    bool is_in_body = true;
//    bool is_in_body =
//        sheet_owner.IsDescendantOf(sheet_owner.GetDocument().body());
    return std::make_pair(PendingSheetType::kBlocking,
                          is_in_body
                              ? RenderBlockingBehavior::kInBodyParserBlocking
                              : RenderBlockingBehavior::kBlocking);
  }
  bool potentially_render_blocking =
      IsA<HTMLElement>(sheet_owner);
  // TODO(xiezuobing): HTMLElement.IsPotentiallyRenderBlocking
//          && To<HTMLElement>(sheet_owner).IsPotentiallyRenderBlocking();
  return potentially_render_blocking
             ? std::make_pair(PendingSheetType::kDynamicRenderBlocking,
                              RenderBlockingBehavior::kBlocking)
             : std::make_pair(PendingSheetType::kNonBlocking,
                              RenderBlockingBehavior::kNonBlockingDynamic);
}

}  // namespace webf