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

#include <optional>
#include "foundation/atomic_string.h"
#include "core/base/hash/hash.h"
#include "core/platform/static_constructors.h"

namespace webf {

struct QualifiedNameComponents {
  WEBF_DISALLOW_NEW();
  std::shared_ptr<StringImpl> prefix_;
  std::shared_ptr<StringImpl> local_name_;
  std::shared_ptr<StringImpl> namespace_;
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
    static std::shared_ptr<QualifiedNameImpl> Create(const AtomicString& prefix,
                                                     const AtomicString& local_name,
                                                     const AtomicString& namespace_uri,
                                                     bool is_static) {
      return std::make_shared<QualifiedNameImpl>(prefix, local_name, namespace_uri, is_static);
    }

    struct KeyHasher {
      std::size_t operator()(const QualifiedNameImpl& k) const { return k.ComputeHash(); }
    };

    bool operator==(const QualifiedNameImpl& other) const { return other.ComputeHash() == ComputeHash(); }

    unsigned ComputeHash() const;

    // We rely on StringHasher's HashMemory clearing out the top 8 bits when
    // doing hashing and use one of the bits for the is_static_ value.
    mutable unsigned existing_hash_ : 24;
    unsigned is_static_ : 1;
    const AtomicString prefix_;
    const AtomicString local_name_;
    const AtomicString namespace_;
    mutable std::string local_name_upper_;
    QualifiedNameImpl(const AtomicString& prefix,
                      const AtomicString& local_name,
                      const AtomicString& namespace_uri,
                      bool is_static)
        : existing_hash_(0),
          is_static_(is_static),
          prefix_(prefix),
          local_name_(local_name),
          namespace_(namespace_uri) {}

   private:
  };

  [[nodiscard]] std::size_t hash() const { return impl_->ComputeHash(); }

  struct KeyHasher {
    std::size_t operator()(const QualifiedName& k) const { return k.hash(); }
  };

  QualifiedName(const AtomicString& prefix,
                const AtomicString& local_name,
                const AtomicString& namespace_uri);
  // Creates a QualifiedName instance with null prefix, the specified local
  // name, and null namespace.
  explicit QualifiedName(const AtomicString& local_name);

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

  bool HasPrefix() const { return impl_->prefix_ != AtomicString::Empty(); }
  void SetPrefix(const AtomicString& prefix) { *this = QualifiedName(prefix, LocalName(), NamespaceURI()); }

  [[nodiscard]] const AtomicString& Prefix() const { return impl_->prefix_; }
  [[nodiscard]] const AtomicString& LocalName() const { return impl_->local_name_; }
  [[nodiscard]] const AtomicString& NamespaceURI() const { return impl_->namespace_; }

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

  static const QualifiedName Null() { return QualifiedName(AtomicString::Empty(), AtomicString::Empty(), AtomicString::Empty()); }

  // The below methods are only for creating static global QNames that need no
  // ref counting.
  static void CreateStatic(void* target_address, std::string* name);
  static void CreateStatic(void* target_address, std::string* name, const std::string& name_namespace);

 private:
  // This constructor is used only to create global/static QNames that don't
  // require any ref counting.
  QualifiedName(const AtomicString& prefix,
                const AtomicString& local_name,
                const AtomicString& namespace_uri,
                bool is_static);

  std::shared_ptr<QualifiedNameImpl> impl_ = nullptr;
};

extern const QualifiedName& g_any_name;
extern const QualifiedName& g_null_name;

inline unsigned HashComponents(const QualifiedNameComponents& buf) {
  return SuperFastHash((const char*)&buf, sizeof(QualifiedNameComponents)) & 0xFFFFFF;
}

inline const QualifiedName& AnyQName() {
  return g_any_name;
}

}  // namespace webf

namespace std {
template <>
struct hash<webf::QualifiedName> {
  std::size_t operator()(const webf::QualifiedName& q) const noexcept { return q.hash(); }
};
}  // namespace std

#endif  // WEBF_QUALIFIED_NAME_H
