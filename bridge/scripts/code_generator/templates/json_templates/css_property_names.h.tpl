#ifndef WEBF_CORE_CSS_CSS_PROPERTY_NAMES_H_
#define WEBF_CORE_CSS_CSS_PROPERTY_NAMES_H_

#include <cstddef>
#include <cassert>
#include <string>
#include "foundation/macros.h"

namespace webf {

class ExecutingContext;

enum class CSSPropertyID {
    kInvalid = 0,
    kVariable = 1,
<% _.each(properties.properties_including_aliases, (property, index) => { %>
    <%= property.enum_key %> = <%= property.enum_value %>,
<% }); %>
};

const CSSPropertyID kCSSPropertyAliasList[] = {
<% _.each(properties.aliases, (property, index) => { %>
    CSSPropertyID::<%= property.enum_key %>,
<% }); %>
};

const CSSPropertyID kCSSComputableProperties[] = {
<% _.each(properties.computable, (property, index) => { %>
    CSSPropertyID::<%= property.enum_key %>,
<% }); %>
};

// The lowest CSSPropertyID excluding kInvalid and kVariable.
const int kIntFirstCSSProperty = <%= properties.first_property_id %>;
const CSSPropertyID kFirstCSSProperty =
    static_cast<CSSPropertyID>(kIntFirstCSSProperty);

// The number of unresolved CSS properties excluding kInvalid and kVariable.
const int kNumCSSProperties = <%= properties.properties_including_aliases.length %>;

// The highest resolved CSSPropertyID.
const int kIntLastCSSProperty = <%= properties.last_property_id %>;
const CSSPropertyID kLastCSSProperty =
    static_cast<CSSPropertyID>(kIntLastCSSProperty);

// The highest unresolved CSSPropertyID.
const CSSPropertyID kLastUnresolvedCSSProperty =
    static_cast<CSSPropertyID>(<%= properties.last_unresolved_property_id %>);

const CSSPropertyID kFirstHighPriorityCSSProperty = kFirstCSSProperty;
const CSSPropertyID kLastHighPriorityCSSProperty = CSSPropertyID::<%= properties.last_high_priority_property_id %>;

// 1 + <The highest unresolved CSSPropertyID>.
const int kNumCSSPropertyIDs = static_cast<int>(kLastUnresolvedCSSProperty) + 1;

const size_t kMaxCSSPropertyNameLength = <%= Math.max(...Object.keys(properties.properties_by_id).map(property => property.length)) %>;
constexpr size_t kCSSPropertyIDBitLength = <%= properties.property_id_bit_length %>;
constexpr size_t kMaxShorthandExpansion = <%= properties.max_shorthand_expansion %>;

static_assert((static_cast<size_t>(1) << kCSSPropertyIDBitLength) >
                  static_cast<size_t>(kLastUnresolvedCSSProperty),
              "kCSSPropertyIDBitLength has enough bits");

// These are basically just change-detector tests, so that we do not
// accidentally add new high-priority properties or break the code generator.
static_assert(CSSPropertyID::kColorScheme == kFirstHighPriorityCSSProperty);
static_assert(CSSPropertyID::kZoom == kLastHighPriorityCSSProperty);
static_assert((static_cast<int>(kLastHighPriorityCSSProperty) -
               static_cast<int>(kFirstHighPriorityCSSProperty)) == 36,
              "There should a low number of high-priority properties");

inline int GetCSSPropertyIDIndex(CSSPropertyID id) {
    assert(id > kFirstCSSProperty);
    assert(id < kLastCSSProperty);
    return static_cast<int>(id) - kIntFirstCSSProperty;
}

constexpr bool IsHighPriority(CSSPropertyID id) {
  return id >= kFirstHighPriorityCSSProperty &&
      id <= kLastHighPriorityCSSProperty;
}

inline bool IsCSSPropertyIDWithName(CSSPropertyID id)
{
    return id >= kFirstCSSProperty && id <= kLastUnresolvedCSSProperty;
}

inline bool IsValidCSSPropertyID(CSSPropertyID id)
{
    return id != CSSPropertyID::kInvalid;
}

inline CSSPropertyID ConvertToCSSPropertyID(int value)
{
    assert(value > static_cast<int>(CSSPropertyID::kInvalid));
    assert(value < kIntLastCSSProperty);
    return static_cast<CSSPropertyID>(value);
}

int ResolveCSSPropertyAlias(int value);

inline bool IsPropertyAlias(CSSPropertyID id) {
  return static_cast<int>(id) >= <%= properties.alias_offset %>;
}

CSSPropertyID CssPropertyID(const ExecutingContext* execution_context,
                            const std::string& string);

inline CSSPropertyID ResolveCSSPropertyID(CSSPropertyID id)
{
  int int_id = static_cast<int>(id);
  if (IsPropertyAlias(id))
    int_id = ResolveCSSPropertyAlias(int_id);
  return ConvertToCSSPropertyID(int_id);
}

class CSSPropertyIDList {
  WEBF_STACK_ALLOCATED();

 public:
  class Iterator {
    WEBF_STACK_ALLOCATED();
   public:
    Iterator(int id) : id_(id) {}
    CSSPropertyID operator*() const { return ConvertToCSSPropertyID(id_); }
    Iterator& operator++() {
      id_++;
      return *this;
    }
    bool operator!=(const Iterator& i) const { return id_ != i.id_; }

   private:
    int id_;
  };
  Iterator begin() const { return Iterator(kIntFirstCSSProperty); }
  Iterator end() const { return Iterator(kIntLastCSSProperty + 1); }
};

}  // namespace blink

#endif  // WEBF_CORE_CSS_CSS_PROPERTY_NAMES_H_
