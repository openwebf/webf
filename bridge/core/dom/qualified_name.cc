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

namespace webf {

DEFINE_GLOBAL(QualifiedName, g_any_name);
DEFINE_GLOBAL(QualifiedName, g_null_name);

using QualifiedNameCache = std::unordered_set<std::shared_ptr<QualifiedName::QualifiedNameImpl>>;

static QualifiedNameCache& GetQualifiedNameCache() {
  thread_local static QualifiedNameCache g_name_cache;
  return g_name_cache;
}

QualifiedName::QualifiedName(const std::string& p, const std::string& l, const std::string& n) {
  std::shared_ptr<QualifiedNameImpl> data = std::make_shared<QualifiedNameImpl>(p, l, n.empty() ? "" : n, false);
  QualifiedNameCache& cache = GetQualifiedNameCache();
  auto result = cache.insert(data);
  impl_ = data;
}

QualifiedName::QualifiedName(const std::string& local_name) : QualifiedName("", local_name, "") {}

QualifiedName::QualifiedName(const std::string& p, const std::string& l, const std::string& n, bool is_static) {
  std::shared_ptr<QualifiedNameImpl> data = std::make_shared<QualifiedNameImpl>(p, l, n.empty() ? "" : n, is_static);
  QualifiedNameCache& cache = GetQualifiedNameCache();
  auto result = cache.insert(data);
  impl_ = data;
}

QualifiedName::~QualifiedName() = default;

std::string QualifiedName::ToString() const {
  // TODO(guopengfei)：
  JSContext* ctx = nullptr;
  std::string local = LocalName();
  if (HasPrefix())
    return Prefix() + ":" + local;
  return local;
}

unsigned QualifiedName::QualifiedNameImpl::ComputeHash() const {
  QualifiedNameComponents components = {prefix_, local_name_, namespace_};
  return HashComponents(components);
}

}  // namespace webf
