/*
* Copyright (C) 2010 Apple Inc. All Rights Reserved.
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
* THIS SOFTWARE IS PROVIDED BY APPLE, INC. ``AS IS'' AND ANY
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
*
*/

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#ifndef WEBF_SCHEME_REGISTRY_H
#define WEBF_SCHEME_REGISTRY_H

#include <iostream>
#include <unordered_set>
#include <unordered_map>

#include "core/platform/hash_traits.h"
#include "foundation/macros.h"

namespace webf {

using URLSchemesSet = std::unordered_set<std::string>;

template <typename Mapped>
using URLSchemesMap = std::unordered_map<std::string, Mapped>;

class  SchemeRegistry {
  WEBF_STATIC_ONLY(SchemeRegistry);

 public:
  static bool ShouldTreatURLSchemeAsRestrictingMixedContent(const std::string&);

  // Display-isolated schemes can only be displayed (in the sense of
  // SecurityOrigin::canDisplay) by documents from the same scheme.
  static void RegisterURLSchemeAsDisplayIsolated(const std::string&);
  static bool ShouldTreatURLSchemeAsDisplayIsolated(const std::string&);

  static bool ShouldLoadURLSchemeAsEmptyDocument(const std::string&);

  static void SetDomainRelaxationForbiddenForURLSchemeForTest(bool forbidden,
                                                              const std::string&);
  static void ResetDomainRelaxationForTest();
  static bool IsDomainRelaxationForbiddenForURLScheme(const std::string&);

  // Such schemes should delegate to SecurityOrigin::canRequest for any URL
  // passed to SecurityOrigin::canDisplay.
  static bool CanDisplayOnlyIfCanRequest(const std::string& scheme);

  // Schemes against which javascript: URLs should not be allowed to run (stop
  // bookmarklets from running on sensitive pages).
  static void RegisterURLSchemeAsNotAllowingJavascriptURLs(
      const std::string& scheme);
  static void RemoveURLSchemeAsNotAllowingJavascriptURLs(const std::string& scheme);
  static bool ShouldTreatURLSchemeAsNotAllowingJavascriptURLs(
      const std::string& scheme);

  static bool ShouldTreatURLSchemeAsCorsEnabled(const std::string& scheme);

  // Serialize the registered schemes in a comma-separated list.
  static std::string ListOfCorsEnabledURLSchemes();

  // Does the scheme represent a location relevant to web compatibility metrics?
  static bool ShouldTrackUsageMetricsForScheme(const std::string& scheme);

  // Schemes that can register a service worker.
  static void RegisterURLSchemeAsAllowingServiceWorkers(const std::string& scheme);
  static bool ShouldTreatURLSchemeAsAllowingServiceWorkers(
      const std::string& scheme);

  // HTTP-like schemes that are treated as supporting the Fetch API.
  static void RegisterURLSchemeAsSupportingFetchAPI(const std::string& scheme);
  static bool ShouldTreatURLSchemeAsSupportingFetchAPI(const std::string& scheme);

  // https://url.spec.whatwg.org/#special-scheme
  static bool IsSpecialScheme(const std::string& scheme);

  // Schemes which override the first-/third-party checks on a Document.
  static void RegisterURLSchemeAsFirstPartyWhenTopLevel(const std::string& scheme);
  static void RemoveURLSchemeAsFirstPartyWhenTopLevel(const std::string& scheme);
  static bool ShouldTreatURLSchemeAsFirstPartyWhenTopLevel(
      const std::string& scheme);

  // Like RegisterURLSchemeAsFirstPartyWhenTopLevel, but requires the present
  // document to be delivered over a secure scheme.
  static void RegisterURLSchemeAsFirstPartyWhenTopLevelEmbeddingSecure(
      const std::string& scheme);
  static bool ShouldTreatURLSchemeAsFirstPartyWhenTopLevelEmbeddingSecure(
      const std::string& top_level_scheme,
      const std::string& child_scheme);

  // Schemes that can be used in a referrer.
  static void RegisterURLSchemeAsAllowedForReferrer(const std::string& scheme);
  static void RemoveURLSchemeAsAllowedForReferrer(const std::string& scheme);
  static bool ShouldTreatURLSchemeAsAllowedForReferrer(const std::string& scheme);

  // Schemes used for internal error pages, for failed navigations.
  static void RegisterURLSchemeAsError(const std::string&);
  static bool ShouldTreatURLSchemeAsError(const std::string& scheme);

  // Schemes which should always allow access to SharedArrayBuffers.
  // TODO(crbug.com/1184892): Remove once fixed.
  static void RegisterURLSchemeAsAllowingSharedArrayBuffers(const std::string&);
  static bool ShouldTreatURLSchemeAsAllowingSharedArrayBuffers(const std::string&);

  // Allow resources from some schemes to load on a page, regardless of its
  // Content Security Policy.
  enum PolicyAreas : uint32_t {
    kPolicyAreaNone = 0,
    kPolicyAreaImage = 1 << 0,
    kPolicyAreaStyle = 1 << 1,
    // Add more policy areas as needed by clients.
    kPolicyAreaAll = ~static_cast<uint32_t>(0),
  };
  static void RegisterURLSchemeAsBypassingContentSecurityPolicy(
      const std::string& scheme,
      PolicyAreas = kPolicyAreaAll);
  static void RemoveURLSchemeRegisteredAsBypassingContentSecurityPolicy(
      const std::string& scheme);
  static bool SchemeShouldBypassContentSecurityPolicy(
      const std::string& scheme,
      PolicyAreas = kPolicyAreaAll);

  // Schemes which bypass Secure Context checks defined in
  // https://w3c.github.io/webappsec-secure-contexts/#is-origin-trustworthy
  static void RegisterURLSchemeBypassingSecureContextCheck(
      const std::string& scheme);
  static bool SchemeShouldBypassSecureContextCheck(const std::string& scheme);

  // Schemes that can use 'wasm-eval'.
  static void RegisterURLSchemeAsAllowingWasmEvalCSP(const std::string& scheme);
  static bool SchemeSupportsWasmEvalCSP(const std::string& scheme);

  // Schemes that represent trusted browser UI.
  // TODO(chromium:1197375) Reconsider usages of this category. Are there
  // meaningful ways to define more abstract permissions or requirements that
  // could be used instead?
  static void RegisterURLSchemeAsWebUI(const std::string& scheme);
  static void RemoveURLSchemeAsWebUI(const std::string& scheme);
  static bool IsWebUIScheme(const std::string& scheme);

  // Like the above, but without threading safety checks.
  static void RegisterURLSchemeAsWebUIForTest(const std::string& scheme);
  static void RemoveURLSchemeAsWebUIForTest(const std::string& scheme);

  // Schemes which can use code caching but must check in the renderer whether
  // the script content has changed rather than relying on a response time match
  // from the network cache.
  static void RegisterURLSchemeAsCodeCacheWithHashing(const std::string& scheme);
  static void RemoveURLSchemeAsCodeCacheWithHashing(const std::string& scheme);
  static bool SchemeSupportsCodeCacheWithHashing(const std::string& scheme);

 private:
  static const URLSchemesSet& LocalSchemes();
};

}  // namespace webf

#endif  // WEBF_SCHEME_REGISTRY_H
