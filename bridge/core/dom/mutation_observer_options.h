/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

namespace webf {

using MutationObserverOptions = unsigned char;
using MutationRecordDeliveryOptions = unsigned char;

// MutationType represents lower three bits of MutationObserverOptions.
// It doesn't use |enum class| because we'd like to do bitwise operations.
enum MutationType {
  kMutationTypeChildList = 1 << 0,
  kMutationTypeAttributes = 1 << 1,
  kMutationTypeCharacterData = 1 << 2,

  kMutationTypeAll = kMutationTypeChildList | kMutationTypeAttributes |
                     kMutationTypeCharacterData
};


}