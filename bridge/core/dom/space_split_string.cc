/*
 * Copyright (C) 2010 Apple Inc. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1.  Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 * 2.  Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY APPLE INC. AND ITS CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL APPLE INC. OR ITS CONTRIBUTORS BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/*
 * Copyright (C) 2007 David Smith (catfish.man@gmail.com)
 * Copyright (C) 2007, 2008, 2011, 2012 Apple Inc. All rights reserved.
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
 * the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 */

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "space_split_string.h"
#include <set>
#include <sstream>
#include "built_in_string.h"

namespace webf {

void SpaceSplitString::Set(JSContext* ctx, const AtomicString& value) {
  if (value.IsNull()) {
    Clear();
    return;
  }
  data_ = std::make_unique<Data>(ctx, value);
}

void SpaceSplitString::Clear() {
  data_ = nullptr;
}

void SpaceSplitString::Add(JSContext* ctx, const AtomicString& string) {
  if (Contains(string))
    return;
  EnsureUnique();
  if (data_) {
    data_->Add(string);
  } else {
    data_ = std::make_unique<Data>(ctx, string);
  }
}

bool SpaceSplitString::Remove(const AtomicString& string) {
  if (!data_)
    return false;
  unsigned i = 0;
  bool changed = false;
  while (i < data_->size()) {
    if ((*data_)[i] == string) {
      if (!changed)
        EnsureUnique();
      data_->Remove(i);
      changed = true;
      continue;
    }
    ++i;
  }
  return changed;
}

void SpaceSplitString::Remove(size_t index) {
  assert(index < size());
  EnsureUnique();
  data_->Remove(index);
}

void SpaceSplitString::ReplaceAt(size_t index, const AtomicString& string) {
  assert(index < data_->size());
  EnsureUnique();
  (*data_)[index] = string;
}

AtomicString SpaceSplitString::SerializeToString(JSContext* ctx) const {
  size_t size = this->size();
  if (size == 0)
    return built_in_string::kempty_string;
  if (size == 1)
    return (*data_)[0];

  std::stringstream ss;
  ss << (*data_)[0].Character8();
  for (size_t i = 1; i < size; ++i) {
    ss << " ";
    ss << (*data_)[i].Character8();
  }

  return {ctx, ss.str()};
}

template <typename CharacterType>
inline void SpaceSplitString::Data::CreateVector(JSContext* ctx,
                                                 const AtomicString& source,
                                                 const CharacterType* characters,
                                                 unsigned int length) {
  assert(vector_.empty());
  std::set<JSAtom> token_set;
  unsigned start = 0;
  while (true) {
    while (start < length && IsHTMLSpace<CharacterType>(characters[start]))
      ++start;
    if (start >= length)
      break;
    unsigned end = start + 1;
    while (end < length && IsNotHTMLSpace<CharacterType>(characters[end]))
      ++end;

    if (start == 0 && end == length) {
      vector_.push_back(source);
      return;
    }

    AtomicString token = AtomicString(ctx, characters + start, end - start);
    // We skip adding |token| to |token_set| for the first token to reduce the
    // cost of HashSet<>::insert(), and adjust |token_set| when the second
    // unique token is found.
    if (vector_.empty()) {
      vector_.push_back(std::move(token));
    } else if (vector_.size() == 1) {
      if (vector_[0] != token) {
        token_set.insert(vector_[0].Impl());
        token_set.insert(token.Impl());
        vector_.push_back(std::move(token));
      }
    } else if (token_set.count(token.Impl()) == 0) {
      token_set.insert(token.Impl());
      vector_.push_back(std::move(token));
    }

    start = end + 1;
  }
}

SpaceSplitString::Data::Data(JSContext* ctx, const AtomicString& string) : key_string_(string) {
  assert(!string.IsNull());
  CreateVector(ctx, string);
}

SpaceSplitString::Data::Data(const Data& other) : vector_(other.vector_) {}

bool SpaceSplitString::Data::ContainsAll(Data& other) {
  if (this == &other)
    return true;

  size_t this_size = vector_.size();
  size_t other_size = other.vector_.size();
  for (size_t i = 0; i < other_size; ++i) {
    const AtomicString& name = other.vector_[i];
    size_t j;
    for (j = 0; j < this_size; ++j) {
      if (vector_[j] == name)
        break;
    }
    if (j == this_size)
      return false;
  }
  return true;
}

void SpaceSplitString::Data::Add(const AtomicString& string) {
  assert(!Contains(string));
  vector_.push_back(string);
}

void SpaceSplitString::Data::Remove(unsigned int index) {
  vector_.erase(vector_.begin() + index);
}

void SpaceSplitString::Data::CreateVector(JSContext* ctx, const AtomicString& string) {
  unsigned length = string.length();
  if (string.Is8Bit()) {
    CreateVector<char>(ctx, string, reinterpret_cast<const char*>(string.Character8()), length);
    return;
  }

  CreateVector<uint16_t>(ctx, string, string.Character16(), length);
}

std::unordered_map<JSAtom, SpaceSplitString::Data*>& SpaceSplitString::SharedDataMap() {
  thread_local static std::unordered_map<JSAtom, SpaceSplitString::Data*> map;
  return map;
}

}  // namespace webf