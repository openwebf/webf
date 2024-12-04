/*
 * Copyright (C) 2003, 2004, 2005, 2006, 2007, 2008, 2011, 2012 Apple Inc.
 * All rights reserved.
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
 * THIS SOFTWARE IS PROVIDED BY APPLE COMPUTER, INC. ``AS IS'' AND ANY
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

#ifndef THIRD_PARTY_BLINK_RENDERER_PLATFORM_WEBORIGIN_KURL_H_
#define THIRD_PARTY_BLINK_RENDERER_PLATFORM_WEBORIGIN_KURL_H_

#include <iosfwd>
#include <memory>

#include "url_canon.h"
#include "url_parse.h"
#include "url_util.h"

// KURL stands for the URL parser in KDE's HTML Widget (KHTML). The name hasn't
// changed since Blink forked WebKit, which in turn forked KHTML.
//
// KURL is Blink's URL class and is the analog to GURL in other Chromium
// code. KURL and GURL both share the same underlying URL parser, whose code is
// located in //url, but KURL is backed by Blink specific WTF::Strings. This
// means that KURLs are usually cheap to copy due to WTF::Strings being
// internally ref-counted. However, please don't copy KURLs if you can use a
// const ref, since the size of the parsed structure and related metadata is
// non-trivial.
//
// KURL also has a few other optimizations, including:
// - Fast comparisons since the string spec is stored as an std::string.
// - Cached bit for whether the KURL is http/https
// - Internal reference to the URL protocol (scheme) to avoid std::string allocation
//   for the callers that require it. Common protocols like http and https are
//   stored as shared static strings.

namespace webf {

class KURL {
  USING_FAST_MALLOC(KURL);

 public:
  KURL();
  KURL(const KURL&);

  KURL& operator=(const KURL&);

  // The argument is an absolute URL string. The string is assumed to be
  // output of KURL::GetString() called on a valid KURL object, or
  // indiscernible from such.
  //
  // It is usually best to avoid repeatedly parsing a String, unless memory
  // saving outweigh the possible slow-downs.
  explicit KURL(const std::string&);

  // Resolves the relative URL with the given base URL. If provided, the
  // TextEncoding is used to encode non-ASCII characters. The base URL can be
  // null or empty, in which case the relative URL will be interpreted as
  // absolute.
  // FIXME: If the base URL is invalid, this always creates an invalid
  // URL. Instead I think it would be better to treat all invalid base URLs
  // the same way we treate null and empty base URLs.
  KURL(const KURL& base, const std::string& relative);
  // KURL(const KURL& base, const std::string& relative, const WTF::TextEncoding&);

  // For conversions from other structures that have already parsed and
  // canonicalized the URL. The input must be exactly what KURL would have
  // done with the same input.
  KURL(const std::string& canonical_string, const url::Parsed&, bool is_valid);

  ~KURL();

  KURL UrlStrippedForUseAsReferrer() const;
  std::string StrippedForUseAsReferrer() const;
  std::string StrippedForUseAsHref() const;

  // FIXME: The above functions should be harmonized so that passing a
  // base of null or the empty string gives the same result as the
  // standard std::string constructor.

  bool IsNull() const;
  bool IsEmpty() const;
  bool IsValid() const;

  // Returns true if this URL has a path. Note that "http://foo.com/" has a
  // path of "/", so this function will return true. Only invalid or
  // non-hierarchical (like "javascript:") URLs will have no path.
  bool HasPath() const;

  // Returns true if you can set the host and port for the URL.
  //
  // Note: this returns true for "filesystem" and false for "blob" currently,
  // due to peculiarities of how schemes are registered in  -- neither
  // of these schemes can have hostnames on the outer URL.
  bool CanSetHostOrPort() const;
  bool CanSetPathname() const;

  // Return true if a host can be removed from the URL.
  //
  // URL Standard: https://url.spec.whatwg.org/#host-state
  //
  // > 3.2: Otherwise, if state override is given, buffer is the empty string,
  // > and either url includes credentials or url’s port is non-null, return.
  //
  // Examples:
  //
  // Setting an empty host is allowed:
  //
  // > const url = new URL("git://h/")
  // > url.host = "";
  // > assertEquals(url.href, "git:///");
  //
  // Setting an empty host is disallowed:
  //
  // > const url = new URL("git://u@h/")
  // > url.host = "";
  // > assertEquals(url.href, "git://u@h/");
  bool CanRemoveHost() const;

  // Return true if this URL is hierarchical, which is equivalent to standard
  // URLs.
  //
  // Important note: If kStandardCompliantNonSpecialSchemeURLParsing flag is
  // enabled, returns true also for non-special URLs which don't have an opaque
  // path.
  bool IsHierarchical() const;

  // Return true if this URL is a standard URL.
  bool IsStandard() const;

  // The returned `std::string` is guaranteed to consist of only ASCII
  // characters, but may be 8-bit or 16-bit.
  const std::string& GetString() const { return string_; }

  std::string ElidedString() const;

  std::string Protocol() const;
  std::string Host() const;
  std::string HostView() const;

  // Returns 0 when there is no port or the default port was specified, or the
  // URL is invalid.
  //
  // We treat URLs with out-of-range port numbers as invalid URLs, and they
  // will be rejected by the canonicalizer.
  uint16_t Port() const;
  bool HasPort() const;
  std::string User() const;
  std::string Pass() const;
  std::string GetPath() const;
  // This method handles "parameters" separated by a semicolon.
  std::string LastPathComponent() const;
  std::string Query() const;
  std::string FragmentIdentifier() const;
  bool HasFragmentIdentifier() const;

  std::string BaseAsString() const;

  // Returns true if the current URL's protocol is the same as the StringView
  // argument. The argument must be lower-case.
  bool ProtocolIs(const std::string protocol) const;
  bool ProtocolIsData() const { return ProtocolIs("data"); }
  // This includes at least about:blank and about:srcdoc.
  bool ProtocolIsAbout() const { return ProtocolIs("about"); }
  bool ProtocolIsJavaScript() const;
  bool ProtocolIsInHTTPFamily() const;
  bool IsLocalFile() const;
  bool IsAboutBlankURL() const;   // Is about:blank, ignoring query/ref strings.
  bool IsAboutSrcdocURL() const;  // Is about:srcdoc, ignoring query/ref
                                  // strings..

  bool SetProtocol(const std::string&);
  void SetHost(const std::string&);

  void RemovePort();
  void SetPort(uint16_t);
  void SetPort(const std::string&);

  // Input is like "foo.com" or "foo.com:8000".
  void SetHostAndPort(const std::string&);

  void SetUser(const std::string&);
  void SetPass(const std::string&);

  // If you pass an empty path for HTTP or HTTPS URLs, the resulting path
  // will be "/".
  void SetPath(const std::string&);

  // The query may begin with a question mark, or, if not, one will be added
  // for you. Setting the query to the empty string will leave a "?" in the
  // URL (with nothing after it). To clear the query, pass a null string.
  void SetQuery(const std::string&);

  void SetFragmentIdentifier(const std::string&);
  void RemoveFragmentIdentifier();

  friend bool EqualIgnoringFragmentIdentifier(const KURL&, const KURL&);

  unsigned HostStart() const;
  unsigned HostEnd() const;

  unsigned PathStart() const;
  unsigned PathEnd() const;
  unsigned PathAfterLastSlash() const;

  operator const std::string&() const { return GetString(); }

  const url::Parsed& GetParsed() const { return parsed_; }

  const KURL* InnerURL() const { return inner_url_.get(); }

  bool PotentiallyDanglingMarkup() const { return parsed_.potentially_dangling_markup; }

  // void WriteIntoTrace(perfetto::TracedValue context) const;

 private:
  // friend struct webf::HashTraits<webf::KURL>;

  void Init(const KURL& base, const std::string& relative);

  bool IsAboutURL(const char* allowed_path) const;

  std::string ComponentStringView(const url::Component&) const;
  std::string ComponentString(const url::Component&) const;
  std::string StringViewForInvalidComponent() const;

  // If |preserve_validity| is true, refuse to make changes that would make the
  // KURL invalid.
  template <typename CHAR>
  void ReplaceComponents(const url::Replacements<CHAR>&, bool preserve_validity = false);

  void InitInnerURL();
  void InitProtocolMetadata();

  // Asserts that `string_` is an ASCII string in DCHECK builds.
  void AssertStringSpecIsASCII();

  // URL Standard: https://url.spec.whatwg.org/#include-credentials
  bool IncludesCredentials() const { return !User().empty() || !Pass().empty(); }

  // URL Standard: https://url.spec.whatwg.org/#url-opaque-path
  bool HasOpaquePath() const { return parsed_.has_opaque_path; }

  bool is_valid_;
  bool protocol_is_in_http_family_;

  // Keep a separate string for the protocol to avoid copious copies for
  // protocol().
  std::string protocol_;

  url::Parsed parsed_;
  std::string string_;
  std::unique_ptr<KURL> inner_url_;
};

bool operator==(const KURL&, const KURL&);
bool operator==(const KURL&, const std::string&);
bool operator==(const std::string&, const KURL&);
bool operator!=(const KURL&, const KURL&);
bool operator!=(const KURL&, const std::string&);
bool operator!=(const std::string&, const KURL&);

// Pretty printer for gtest and base/logging.*.  It prepends and appends
// double-quotes, and escapes characters other than ASCII printables.
std::ostream& operator<<(std::ostream&, const KURL&);

bool EqualIgnoringFragmentIdentifier(const KURL&, const KURL&);

const KURL& BlankURL();
const KURL& SrcdocURL();
const KURL& NullURL();

// Functions to do URL operations on strings.
// These are operations that aren't faster on a parsed URL.
// These are also different from the KURL functions in that they don't require
// the string to be a valid and parsable URL.  This is especially important
// because valid javascript URLs are not necessarily considered valid by KURL.

bool ProtocolIs(const std::string& url, const char* protocol);
bool ProtocolIsJavaScript(const std::string& url);

bool IsValidProtocol(const std::string&);

using DecodeURLMode = url::DecodeURLMode;
// Unescapes the given string using URL escaping rules.
//
// DANGER: If the URL has "%00" in it, the resulting string will have embedded
// null characters!
//
// This function is also used to decode javascript: URLs and as a general
// purpose unescaping function.
//
// Caution: Specifying kUTF8OrIsomorphic to the second argument doesn't conform
// to specifications in many cases.
std::string DecodeURLEscapeSequences(const std::string&, DecodeURLMode mode);

std::string EncodeWithURLEscapeSequences(const std::string&);

// Checks an arbitrary string for invalid escape sequences.
//
// A valid percent-encoding is '%' followed by exactly two hex-digits. This
// function returns true if an occurrence of '%' is found and followed by
// anything other than two hex-digits.
bool HasInvalidURLEscapeSequences(const std::string&);

// Some call sites of `KURL::Host` can be made more efficient by not making a
// string copy and just using a std::string instead. This feature flag is used to
// investigate how costly the copying is.
//
// The disabled cases at the call sites are intentionally inefficient.
//
// TODO(crbug.com/339026510): Remove after this investigation.
// BASE_DECLARE_FEATURE(kAvoidWastefulHostCopies);

}  // namespace webf

// namespace webf {
//
//// Defined in kurl_hash.h.
// template <>
// struct HashTraits<webf::KURL>;
//
// template <>
// struct CrossThreadCopier<webf::KURL>
//   : public CrossThreadCopierPassThrough<webf::KURL> {
// WEBF_STATIC_ONLY(CrossThreadCopier);
//};
//
//}  // namespace webf

#endif  // THIRD_PARTY_BLINK_RENDERER_PLATFORM_WEBORIGIN_KURL_H_