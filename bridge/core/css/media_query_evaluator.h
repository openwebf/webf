/*
 * CSS Media Query Evaluator
 *
 * Copyright (C) 2006 Kimmo Kinnunen <kimmo.t.kinnunen@nokia.com>.
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

#ifndef WEBF_CORE_CSS_MEDIA_QUERY_EVALUATOR_H_
#define WEBF_CORE_CSS_MEDIA_QUERY_EVALUATOR_H_

#include <vector>
#include "core/css/resolver/media_query_result.h"

namespace webf {

class ExecutingContext;
class MediaQuery;
class MediaQueryExpNode;
class MediaQueryFeatureExpNode;
class MediaQuerySet;
class MediaQuerySetResult;
class MediaValues;
class GCVisitor;
struct MediaQueryResultFlags;

// See Kleene 3-valued logic
//
// https://drafts.csswg.org/mediaqueries-4/#evaluating
enum class KleeneValue {
  kTrue,
  kFalse,
  kUnknown,
};

// Class that evaluates css media queries as defined in
// CSS3 Module "Media Queries" (http://www.w3.org/TR/css3-mediaqueries/)
// Special constructors are needed, if simple media queries are to be
// evaluated without knowledge of the medium features. This can happen
// for example when parsing UA stylesheets, if evaluation is done
// right after parsing.
//
// the boolean parameter is used to approximate results of evaluation, if
// the device characteristics are not known. This can be used to prune the
// loading of stylesheets to only those which are probable to match.

class MediaQueryEvaluator final {
 public:
  static void Init();

  MediaQueryEvaluator() = delete;

  // Creates evaluator to evaluate media types only. Evaluator returns true for
  // accepted_media_type and triggers a NOTREACHED returning false for any media
  // features. Should only be used for UA stylesheets.
  explicit MediaQueryEvaluator(const char* accepted_media_type);

  // Creates evaluator which evaluates full media queries.
  explicit MediaQueryEvaluator(ExecutingContext*);

  // Create an evaluator for container queries and preload scanning.
  explicit MediaQueryEvaluator(const MediaValues*);

  MediaQueryEvaluator(const MediaQueryEvaluator&) = delete;
  MediaQueryEvaluator& operator=(const MediaQueryEvaluator&) = delete;

  ~MediaQueryEvaluator();

  const MediaValues& GetMediaValues() const { return *media_values_; }

  bool MediaTypeMatch(const std::string& media_type_to_match) const;

  // Evaluates a list of media queries.
  bool Eval(const MediaQuerySet&) const;
  bool Eval(const MediaQuerySet&, MediaQueryResultFlags*) const;

  // Evaluates media query.
  bool Eval(const MediaQuery&) const;
  bool Eval(const MediaQuery&, MediaQueryResultFlags*) const;

  // https://drafts.csswg.org/mediaqueries-4/#evaluating
  KleeneValue Eval(const MediaQueryExpNode&) const;
  KleeneValue Eval(const MediaQueryExpNode&, MediaQueryResultFlags*) const;

  // Returns true if any of the media queries in the results lists changed its
  // evaluation.
  bool DidResultsChange(const std::vector<MediaQuerySetResult>& results) const;

  void Trace(GCVisitor*) const;

 private:
  KleeneValue EvalNot(const MediaQueryExpNode&, MediaQueryResultFlags*) const;
  KleeneValue EvalAnd(const MediaQueryExpNode&, const MediaQueryExpNode&, MediaQueryResultFlags*) const;
  KleeneValue EvalOr(const MediaQueryExpNode&, const MediaQueryExpNode&, MediaQueryResultFlags*) const;
  KleeneValue EvalFeature(const MediaQueryFeatureExpNode&, MediaQueryResultFlags*) const;
  KleeneValue EvalStyleFeature(const MediaQueryFeatureExpNode&, MediaQueryResultFlags*) const;

  const std::string MediaType() const;

  std::string media_type_;
  std::shared_ptr<const MediaValues> media_values_;
};

}  // namespace webf

#endif  // WEBF_CORE_CSS_MEDIA_QUERY_EVALUATOR_H_
