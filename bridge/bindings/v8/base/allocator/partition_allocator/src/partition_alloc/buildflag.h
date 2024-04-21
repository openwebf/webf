/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

#ifndef PARTITION_ALLOC_BUILDFLAG_H_
#define PARTITION_ALLOC_BUILDFLAG_H_

// This was copied from chromium's and adapted to partition_alloc.
// Please refer to chromium's //build/buildflag.h original comments.
//
// Using a different macro and internal define allows partition_alloc and
// chromium to cohabit without affecting each other.
#define PA_BUILDFLAG_CAT_INDIRECT(a, b) a##b
#define PA_BUILDFLAG_CAT(a, b) PA_BUILDFLAG_CAT_INDIRECT(a, b)
#define PA_BUILDFLAG(flag) (PA_BUILDFLAG_CAT(PA_BUILDFLAG_INTERNAL_, flag)())

#endif  // PARTITION_ALLOC_BUILDFLAG_H_
