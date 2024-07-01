//
// Created by 谢作兵 on 12/06/24.
//

#ifndef WEBF_CSS_NESTING_TYPE_H
#define WEBF_CSS_NESTING_TYPE_H

namespace webf {

// Note that order matters: kNesting effectively also means kScope,
// and therefore it's convenient to compute the max CSSNestingType
// in some cases.
enum class CSSNestingType {
  // We are not in a nesting context, and '&' resolves like :scope instead.
  kNone,
  // We are in a nesting context as defined by @scope.
  //
  // https://drafts.csswg.org/css-cascade-6/#scope-atrule
  // https://drafts.csswg.org/selectors-4/#scope-pseudo
  kScope,
  // We are in a css-nesting nesting context, and '&' resolves according to:
  // https://drafts.csswg.org/css-nesting-1/#nest-selector
  kNesting,
};

}  // namespace webf

#endif  // WEBF_CSS_NESTING_TYPE_H
