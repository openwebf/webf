/*
 * Copyright (C) 2013 Google Inc. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *
 *     * Redistributions of source code must retain the above copyright
 * notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above
 * copyright notice, this list of conditions and the following disclaimer
 * in the documentation and/or other materials provided with the
 * distribution.
 *     * Neither the name of Google Inc. nor the names of its
 * contributors may be used to endorse or promote products derived from
 * this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#ifndef WEBF_CORE_STYLE_GRID_AREA_H_
#define WEBF_CORE_STYLE_GRID_AREA_H_

#include "core/style/grid_enums.h"
#include "core/platform/math_extras.h"

namespace webf {

// Legacy grid expands out auto-repeaters, so it has a lower cap than GridNG.
// Note that this actually allows a [-999,999] range.
const int kLegacyGridMaxTracks = 1000;
const int kGridMaxTracks = 10000000;

// A span in a single direction (either rows or columns). Note that |start_line|
// and |end_line| are grid lines' indexes.
// Despite line numbers in the spec start in "1", the indexes here start in "0".
struct GridSpan {
  USING_FAST_MALLOC(GridSpan);

 public:
  static GridSpan UntranslatedDefiniteGridSpan(int start_line, int end_line) {
    return GridSpan(start_line, end_line, kUntranslatedDefinite);
  }

  static GridSpan TranslatedDefiniteGridSpan(uint32_t start_line,
                                             uint32_t end_line) {
    return GridSpan(start_line, end_line, kTranslatedDefinite);
  }

  static GridSpan IndefiniteGridSpan(uint32_t span_size = 1) {
    return GridSpan(uint32_t{0}, span_size, kIndefinite);
  }

  bool operator==(const GridSpan& o) const {
    return type_ == o.type_ && start_line_ == o.start_line_ &&
           end_line_ == o.end_line_;
  }

  bool operator<(const GridSpan& o) const {
    assert(IsTranslatedDefinite());
    return start_line_ < o.start_line_ ||
           (start_line_ == o.start_line_ && end_line_ < o.end_line_);
  }

  bool operator<=(const GridSpan& o) const {
    assert(IsTranslatedDefinite());
    return *this < o || *this == o;
  }

  bool Contains(uint32_t line) const {
    assert(IsTranslatedDefinite());
    assert(start_line_ >= 0);
    assert(start_line_ < end_line_);
    return line >= static_cast<uint32_t>(start_line_) &&
           line <= static_cast<uint32_t>(end_line_);
  }

  bool Intersects(GridSpan span) const {
    assert(IsTranslatedDefinite());
    assert(span.IsTranslatedDefinite());
    assert(start_line_ >= 0);
    assert(start_line_ < end_line_);
    assert(span.start_line_ >= 0);
    assert(span.start_line_ < span.end_line_);

    return start_line_ < span.end_line_ && end_line_ >= span.start_line_;
  }

  uint32_t IntegerSpan() const {
    assert(IsTranslatedDefinite());
    assert(start_line_ < end_line_);
    return end_line_ - start_line_;
  }

  uint32_t IndefiniteSpanSize() const {
    assert(IsIndefinite());
    assert(start_line_ == 0);
    assert(end_line_ < 0);
    return end_line_;
  }

  int UntranslatedStartLine() const {
    assert(type_ == kUntranslatedDefinite);
    return start_line_;
  }

  int UntranslatedEndLine() const {
    assert(type_ == kUntranslatedDefinite);
    return end_line_;
  }

  uint32_t StartLine() const {
    assert(IsTranslatedDefinite());
    assert(start_line_ >= 0);
    return start_line_;
  }

  uint32_t EndLine() const {
    assert(IsTranslatedDefinite());
    assert(end_line_ >= 0);
    return end_line_;
  }

  struct GridSpanIterator {
    GridSpanIterator(uint32_t v) : value(v) {}

    uint32_t operator*() const { return value; }
    uint32_t operator++() { return value++; }
    bool operator!=(GridSpanIterator other) const {
      return value != other.value;
    }

    uint32_t value;
  };

  GridSpanIterator begin() const {
    assert(IsTranslatedDefinite());
    return start_line_;
  }

  GridSpanIterator end() const {
    assert(IsTranslatedDefinite());
    return end_line_;
  }

  bool IsUntranslatedDefinite() const { return type_ == kUntranslatedDefinite; }
  bool IsTranslatedDefinite() const { return type_ == kTranslatedDefinite; }
  bool IsIndefinite() const { return type_ == kIndefinite; }

  void Translate(uint32_t offset) {
    assert(type_ != kIndefinite);
    *this =
        GridSpan(start_line_ + offset, end_line_ + offset, kTranslatedDefinite);
  }

  void SetStart(int start_line) {
    assert(type_ != kIndefinite);
    *this = GridSpan(start_line, end_line_, kTranslatedDefinite);
  }

  void SetEnd(int end_line) {
    assert(type_ != kIndefinite);
    *this = GridSpan(start_line_, end_line, kTranslatedDefinite);
  }

  void Intersect(int start_line, int end_line) {
    assert(type_ != kIndefinite);
    *this = GridSpan(std::max(start_line_, start_line),
                     std::min(end_line_, end_line), kTranslatedDefinite);
  }

 private:
  enum GridSpanType { kUntranslatedDefinite, kTranslatedDefinite, kIndefinite };

  template <typename T>
  GridSpan(T start_line, T end_line, GridSpanType type) : type_(type) {
    const int grid_max_tracks = kGridMaxTracks;
    start_line_ =
        ClampTo<int>(start_line, -grid_max_tracks, grid_max_tracks - 1);
    end_line_ = ClampTo<int>(end_line, start_line_ + 1, grid_max_tracks);

#if DCHECK_IS_ON()
    DCHECK_LT(start_line_, end_line_);
    if (type == kTranslatedDefinite) {
      DCHECK_GE(start_line_, 0);
    }
#endif
  }

  int start_line_;
  int end_line_;
  GridSpanType type_;
};

// This represents a grid area that spans in both rows' and columns' direction.
struct GridArea {
  USING_FAST_MALLOC(GridArea);

 public:
  // HashMap requires a default constuctor.
  GridArea()
      : columns(GridSpan::IndefiniteGridSpan()),
        rows(GridSpan::IndefiniteGridSpan()) {}

  GridArea(const GridSpan& r, const GridSpan& c) : columns(c), rows(r) {}

  const GridSpan& Span(GridTrackSizingDirection track_direction) const {
    return (track_direction == kForColumns) ? columns : rows;
  }

  void SetSpan(const GridSpan& span, GridTrackSizingDirection track_direction) {
    if (track_direction == kForColumns) {
      columns = span;
    } else {
      rows = span;
    }
  }

  uint32_t StartLine(GridTrackSizingDirection track_direction) const {
    return Span(track_direction).StartLine();
  }

  uint32_t EndLine(GridTrackSizingDirection track_direction) const {
    return Span(track_direction).EndLine();
  }

  uint32_t SpanSize(GridTrackSizingDirection track_direction) const {
    return Span(track_direction).IntegerSpan();
  }

  void Transpose() { std::swap(columns, rows); }

  bool operator==(const GridArea& o) const {
    return columns == o.columns && rows == o.rows;
  }

  bool operator!=(const GridArea& o) const { return !(*this == o); }

  GridSpan columns;
  GridSpan rows;
};

typedef std::unordered_map<std::string, GridArea> NamedGridAreaMap;

}  // namespace webf

#endif  // WEBF_CORE_STYLE_GRID_AREA_H_
