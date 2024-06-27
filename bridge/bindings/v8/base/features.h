/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

#ifndef BASE_FEATURES_H_
#define BASE_FEATURES_H_

#include "bindings/v8/base/base_export.h"
#include "bindings/v8/base/feature_list.h"
#include "bindings/v8/base/metrics/field_trial_params.h"

namespace base::features {

// All features in alphabetical order. The features should be documented
// alongside the definition of their values in the .cc file.

// Alphabetical:
BASE_EXPORT BASE_DECLARE_FEATURE(kEnforceNoExecutableFileHandles);

BASE_EXPORT BASE_DECLARE_FEATURE(kNotReachedIsFatal);

BASE_EXPORT BASE_DECLARE_FEATURE(kOptimizeDataUrls);

BASE_EXPORT BASE_DECLARE_FEATURE(kUseRustJsonParser);

#if BUILDFLAG(IS_ANDROID) || BUILDFLAG(IS_CHROMEOS)
BASE_EXPORT BASE_DECLARE_FEATURE(kPartialLowEndModeOn3GbDevices);
BASE_EXPORT BASE_DECLARE_FEATURE(kPartialLowEndModeOnMidRangeDevices);
#endif

#if BUILDFLAG(IS_ANDROID)
BASE_EXPORT BASE_DECLARE_FEATURE(kCollectAndroidFrameTimelineMetrics);
#endif

// Policy for emitting profiler metadata from `ThreadController`.
enum class EmitThreadControllerProfilerMetadata {
  // Always emit metadata.
  kForce,
  // Emit metadata only if enabled via the `FeatureList`.
  kFeatureDependent,
};

// Initializes global variables that depend on `FeatureList`. Must be invoked
// early on process startup, but after `FeatureList` initialization. Different
// parts of //base read experiment state from global variables instead of
// directly from `FeatureList` to avoid data races (default values are used
// before this function is called to initialize the global variables).
BASE_EXPORT void Init(EmitThreadControllerProfilerMetadata
                          emit_thread_controller_profiler_metadata);

}  // namespace base::features

#endif  // BASE_FEATURES_H_

