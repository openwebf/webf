/*
 * Copyright (C) 2005, 2006, 2009 Apple Inc. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public License
 * along with this library; see the file COPYING.LIB.  If not, write to
 * the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301, USA.
 */

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_QUALIFIED_NAME_H
#define WEBF_QUALIFIED_NAME_H

#include <built_in_string.h>
#include "bindings/qjs/atomic_string.h"
#include "core/base/hash/hash.h"
#include "core/platform/hash_traits.h"
#include "core/platform/static_constructors.h"

namespace webf {

struct QualifiedNameComponents {
  WEBF_DISALLOW_NEW();
  std::string prefix_;
  std::string local_name_;
  std::string namespace_;
};

// This struct is used to pass data between QualifiedName and the
// QNameTranslator.  For hashing and equality only the QualifiedNameComponents
// fields are used.
struct QualifiedNameData {
  WEBF_DISALLOW_NEW();
  QualifiedNameComponents components_;
  bool is_static_;
};

class QualifiedName {
  USING_FAST_MALLOC(QualifiedName);

 public:
  class QualifiedNameImpl {
   public:
    static std::shared_ptr<QualifiedNameImpl> Create(const std::string& prefix,
                                                     const std::string& local_name,
                                                     const std::string& namespace_uri,
                                                     bool is_static) {
      return std::make_shared<QualifiedNameImpl>(prefix, local_name, namespace_uri, is_static);
    }

    struct KeyHasher {
      std::size_t operator()(const QualifiedNameImpl& k) const { return k.ComputeHash(); }
    };

    bool operator==(const QualifiedNameImpl& other) const {
      return other.ComputeHash() == ComputeHash();
    }

    unsigned ComputeHash() const;

    // We rely on StringHasher's HashMemory clearing out the top 8 bits when
    // doing hashing and use one of the bits for the is_static_ value.
    mutable unsigned existing_hash_ : 24;
    unsigned is_static_ : 1;
    const std::string prefix_;
    const std::string local_name_;
    const std::string namespace_;
    mutable std::string local_name_upper_;
    QualifiedNameImpl(std::string prefix, std::string local_name, std::string namespace_uri, bool is_static)
        : existing_hash_(0),
          is_static_(is_static),
          prefix_(std::move(prefix)),
          local_name_(std::move(local_name)),
          namespace_(std::move(namespace_uri)) {
      assert(!namespace_.empty());
    }

   private:
  };

  [[nodiscard]] std::size_t hash() const { return impl_->ComputeHash(); }

  struct KeyHasher {
    std::size_t operator()(const QualifiedName& k) const { return k.hash(); }
  };

  QualifiedName(const std::string& prefix, const std::string& local_name, const std::string& namespace_uri);
  // Creates a QualifiedName instance with null prefix, the specified local
  // name, and null namespace.
  explicit QualifiedName(const std::string& local_name);
  ~QualifiedName();

  QualifiedName(const QualifiedName& other) = default;
  const QualifiedName& operator=(const QualifiedName& other) {
    impl_ = other.impl_;
    return *this;
  }
  QualifiedName(QualifiedName&& other) = default;
  QualifiedName& operator=(QualifiedName&& other) = default;

  bool operator==(const QualifiedName& other) const { return impl_ == other.impl_; }
  bool operator!=(const QualifiedName& other) const { return !(*this == other); }

  bool Matches(const QualifiedName& other) const {
    return impl_ == other.impl_ || (LocalName() == other.LocalName() && NamespaceURI() == other.NamespaceURI());
  }

  bool HasPrefix() const { return impl_->prefix_ != built_in_string_stdstring::knull; }
  void SetPrefix(const std::string& prefix) { *this = QualifiedName(prefix, LocalName(), NamespaceURI()); }

  [[nodiscard]] const std::string& Prefix() const { return impl_->prefix_; }
  [[nodiscard]] const std::string& LocalName() const { return impl_->local_name_; }
  [[nodiscard]] const std::string& NamespaceURI() const { return impl_->namespace_; }

  // Uppercased localName, cached for efficiency
  [[nodiscard]] const std::string& LocalNameUpper() const {
    if (!impl_->local_name_upper_.empty())
      return impl_->local_name_upper_;
    return LocalNameUpperSlow();
  }

  [[nodiscard]] const std::string& LocalNameUpperSlow() const;

  // Returns true if this is a built-in name. That is, one of the names defined
  // at build time (such as <img>).
  bool IsDefinedName() const { return impl_ && impl_->is_static_; }

  [[nodiscard]] std::string ToString() const;

  QualifiedNameImpl* Impl() const { return impl_.get(); }

  // Init routine for globals
  static void InitAndReserveCapacityForSize(unsigned size);

  static const QualifiedName Null() { return QualifiedName("", "", ""); }

  // The below methods are only for creating static global QNames that need no
  // ref counting.
  static void CreateStatic(void* target_address, std::string* name);
  static void CreateStatic(void* target_address, std::string* name, const std::string& name_namespace);

 private:
  friend struct HashTraits<QualifiedName>;

  // This constructor is used only to create global/static QNames that don't
  // require any ref counting.
  QualifiedName(const std::string& prefix,
                const std::string& local_name,
                const std::string& namespace_uri,
                bool is_static);

  std::shared_ptr<QualifiedNameImpl> impl_ = nullptr;
};

DEFINE_GLOBAL(QualifiedName, g_any_name);
DEFINE_GLOBAL(QualifiedName, g_null_name);

template <>
struct HashTraits<QualifiedName::QualifiedNameImpl*> : GenericHashTraits<QualifiedName::QualifiedNameImpl*> {
  static unsigned GetHash(const QualifiedName::QualifiedNameImpl* name) {
    if (!name->existing_hash_) {
      name->existing_hash_ = name->ComputeHash();
    }
    return name->existing_hash_;
  }
  static constexpr bool kSafeToCompareToEmptyOrDeleted = false;
};

template <>
struct HashTraits<webf::QualifiedName> : GenericHashTraits<webf::QualifiedName> {
  using QualifiedNameImpl = webf::QualifiedName::QualifiedNameImpl;
  static unsigned GetHash(const webf::QualifiedName& name) { return webf::GetHash(name.Impl()); }
  static constexpr bool kSafeToCompareToEmptyOrDeleted = false;

  static constexpr bool kEmptyValueIsZero = false;
  static const webf::QualifiedName EmptyValue() { return webf::QualifiedName::Null(); }

  static bool IsDeletedValue(const QualifiedName& value) {
    return HashTraits<std::shared_ptr<QualifiedNameImpl>>::IsDeletedValue(value.impl_);
  }
  static void ConstructDeletedValue(QualifiedName& slot) {
    HashTraits<std::shared_ptr<QualifiedNameImpl>>::ConstructDeletedValue(slot.impl_);
  }
};

inline unsigned HashComponents(const QualifiedNameComponents& buf) {
  return SuperFastHash((const char*) &buf, sizeof(QualifiedNameComponents)) & 0xFFFFFF;
}

}  // namespace webf

namespace std {
template <>
struct hash<webf::QualifiedName> {
  std::size_t operator()(const webf::QualifiedName& q) const noexcept { return q.hash(); }
};
}  // namespace std

#endif  // WEBF_QUALIFIED_NAME_H
