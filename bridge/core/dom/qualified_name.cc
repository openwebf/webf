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
 *
 */

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "core/dom/qualified_name.h"
#include <unordered_set>

//TODO(xiezuobing): qualified实现
namespace webf {

// Global init routines
//DEFINE_GLOBAL(QualifiedName, g_any_name);
//DEFINE_GLOBAL(QualifiedName, g_null_name);

using QualifiedNameCache = std::unordered_set<QualifiedName::QualifiedNameImpl*>;

static QualifiedNameCache& GetQualifiedNameCache() {
  // This code is lockless and thus assumes it all runs on one thread!
  // TODO(guopengfei)：注释IsMainThread
  //DCHECK(IsMainThread());
  thread_local static QualifiedNameCache* g_name_cache = new QualifiedNameCache;
  return *g_name_cache;
}

struct QNameComponentsTranslator {
  static unsigned GetHash(const QualifiedNameData& data) {
    return HashComponents(data.components_);
  }
  static bool Equal(QualifiedName::QualifiedNameImpl* name,
                    const QualifiedNameData& data) {
    return data.components_.prefix_ == &(name->prefix_) &&
           data.components_.local_name_ == &(name->local_name_) &&
           data.components_.namespace_ == &(name->namespace_);
  }
  static void Store(QualifiedName::QualifiedNameImpl*& location,
                    const QualifiedNameData& data,
                    unsigned) {
    const QualifiedNameComponents& components = data.components_;
    auto name = QualifiedName::QualifiedNameImpl::Create(
        *components.prefix_, *components.local_name_, *components.namespace_,
        data.is_static_);
    location = name.get();
  }
};

QualifiedName::QualifiedName(const AtomicString& p,
                             const AtomicString& l,
                             const AtomicString& n) {
                             /* // TODO(guopengfei)：注释release
  QualifiedNameData data = {{p, l, n.IsEmpty() ? g_null_atom : n}, false};
  QualifiedNameCache::AddResult add_result =
      GetQualifiedNameCache().AddWithTranslator<QNameComponentsTranslator>(
          data);
  impl_ = *add_result.stored_value;
  if (add_result.is_new_entry)
    impl_->release();

                              */
}

QualifiedName::QualifiedName(const AtomicString& local_name)
    : QualifiedName(g_null_atom, local_name, g_null_atom) {}

QualifiedName::QualifiedName(const AtomicString& p,
                             const AtomicString& l,
                             const AtomicString& n,
                             bool is_static) {
                             /* //TODO(guopengfei)：
  QualifiedNameData data = {{p.Impl(), l.Impl(), n.Impl()}, is_static};
  QualifiedNameCache::AddResult add_result =
      GetQualifiedNameCache().AddWithTranslator<QNameComponentsTranslator>(
          data);
  impl_ = *add_result.stored_value;
  if (add_result.is_new_entry)
    impl_->Release();

                              */
}

QualifiedName::~QualifiedName() = default;

std::string QualifiedName::ToString() const {
  //TODO(guopengfei)：
  JSContext* ctx = nullptr;
  std::string local = LocalName().ToStdString(ctx);
  if (HasPrefix())
    return Prefix().ToStdString(ctx) + ":" + local;
  return local;
}

}  // namespace webf
