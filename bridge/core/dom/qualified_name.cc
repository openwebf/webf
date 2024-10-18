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

QualifiedName::QualifiedName(const std::optional<std::string>& p,
                             const std::optional<std::string>& l,
                             const std::optional<std::string>& n) {
  std::shared_ptr<QualifiedNameImpl> data =
      std::make_shared<QualifiedNameImpl>(p, l, n.has_value() && n.value().empty() ? std::nullopt : n, false);
  QualifiedNameCache& cache = GetQualifiedNameCache();
  auto result = cache.insert(data);
  impl_ = data;
}

QualifiedName::QualifiedName(const std::optional<std::string>& local_name)
    : QualifiedName(std::nullopt, local_name, std::nullopt) {}

QualifiedName::QualifiedName(const std::optional<std::string>& p,
                             const std::optional<std::string>& l,
                             const std::optional<std::string>& n,
                             bool is_static) {
  std::shared_ptr<QualifiedNameImpl> data =
      std::make_shared<QualifiedNameImpl>(p, l, n.has_value() && n.value().empty() ? "" : n, is_static);
  QualifiedNameCache& cache = GetQualifiedNameCache();
  cache.insert(data);
  impl_ = data;
}

QualifiedName::~QualifiedName() = default;

void QualifiedName::InitAndReserveCapacityForSize(unsigned size) {
  GetQualifiedNameCache().reserve(size + 2 /*g_star_atom and g_null_atom */);
  new ((void*)&g_any_name) QualifiedName(std::nullopt, std::nullopt, std::optional<std::string>("*"), true);
  new ((void*)&g_null_name) QualifiedName(std::nullopt, std::nullopt, std::nullopt, true);
}

std::string QualifiedName::ToString() const {
  std::optional<std::string> local = LocalName();
  if (HasPrefix())
    return Prefix().value() + ":" + local.value();
  return local.value();
}

unsigned QualifiedName::QualifiedNameImpl::ComputeHash() const {
  QualifiedNameComponents components = {prefix_.value(), local_name_.value(), namespace_.value()};
  return HashComponents(components);
}

}  // namespace webf
