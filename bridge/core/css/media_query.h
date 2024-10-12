/*
 * CSS Media Query
 *
 * Copyright (C) 2006 Kimmo Kinnunen <kimmo.t.kinnunen@nokia.com>.
 * Copyright (C) 2010 Nokia Corporation and/or its subsidiary(-ies).
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL APPLE COMPUTER, INC. OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 * OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_MEDIA_QUERY_H
#define WEBF_MEDIA_QUERY_H

// TODO(xiezuobing): geometry/axis.h
#include "core/layout/geometry/axis.h"

#include <memory>
#include "bindings/qjs/cppgc/member.h"
#include "bindings/qjs/cppgc/gc_visitor.h"

namespace webf {

class MediaQueryExp;
class MediaQueryExpNode;

using ExpressionHeapVector = std::vector<MediaQueryExp>;

class MediaQuery {
 public:
  enum class RestrictorType : uint8_t { kOnly, kNot, kNone };

  static std::shared_ptr<MediaQuery> CreateNotAll();

  MediaQuery(RestrictorType, std::string media_type, std::shared_ptr<const MediaQueryExpNode>);
  MediaQuery(const MediaQuery&);
  MediaQuery& operator=(const MediaQuery&) = delete;
  ~MediaQuery();
  void Trace(GCVisitor*) const;

  bool HasUnknown() const { return has_unknown_; }
  RestrictorType Restrictor() const;
  const MediaQueryExpNode* ExpNode() const;
  const std::string& MediaType() const;
  bool operator==(const MediaQuery& other) const;
  std::string CssText() const;

 private:
  std::string media_type_;
  std::string serialization_cache_;
  std::shared_ptr<const MediaQueryExpNode> exp_node_;

  RestrictorType restrictor_;
  // Set if |exp_node_| contains any MediaQueryUnknownExpNode instances.
  //
  // If the runtime flag CSSMediaQueries4 is *not* enabled, this will cause the
  // MediaQuery to appear as a "not all".
  //
  // Knowing whether or not something is unknown is useful for use-counting and
  // testing purposes.
  bool has_unknown_;

  std::string Serialize() const;
};

}  // namespace webf

#endif  // WEBF_MEDIA_QUERY_H
