/*
 * Copyright (C) 2004, 2007, 2008, 2011, 2012 Apple Inc. All rights reserved.
 * Copyright (C) 2012 Research In Motion Limited. All rights reserved.
 * Copyright (C) 2008, 2009, 2011 Google Inc. All rights reserved.
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
 * THIS SOFTWARE IS PROVIDED BY APPLE INC. ``AS IS'' AND ANY
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

#ifdef UNSAFE_BUFFERS_BUILD
// TODO(crbug.com/351564777): Remove this and convert code to safer constructs.
#pragma allow_unsafe_buffers
#endif

#include "kurl.h"

#include <algorithm>
#include <codecvt>
#include <string_view>

#include "core/base/numerics/checked_math.h"
#include "core/base/numerics/safe_conversions.h"
#include "core/base/strings/string_number_conversions.h"
#include "core/base/strings/string_util.h"
#include "core/platform/math_extras.h"
#include "core/platform/std_lib_extras.h"
#include "foundation/ascii_types.h"
#include "scheme_registry.h"
#include "url_canon.h"
#include "url_constants.h"
#include "url_util.h"
#ifndef NDEBUG
#include <stdio.h>
#endif

namespace webf {

#if DCHECK_IS_ON()
static void AssertProtocolIsGood(const std::string protocol) {
  DCHECK(protocol != "");
  for (size_t i = 0; i < protocol.length(); ++i) {
    int8_t c = protocol[i];
    DCHECK(c > ' ' && c < 0x7F && !(c >= 'A' && c <= 'Z'));
  }
}
#endif

// Note: You must ensure that |spec| is a valid canonicalized URL before calling
// this function.
static const char* AsURint8_t8Subtle(const std::string& spec) {
  // DCHECK(spec.Is8Bit());
  // characters8 really return characters in Latin-1, but because we
  // canonicalize URL strings, we know that everything before the fragment
  // identifier will actually be ASCII, which means this cast is safe as long as
  // you don't look at the fragment component.
  return reinterpret_cast<const char*>(spec.data());
}

// Returns the characters for the given string, or a pointer to a static empty
// string if the input string is null. This will always ensure we have a non-
// null character pointer since ReplaceComponents has special meaning for null.
static const char* CharactersOrEmpty(const std::string& string) {
  static const char kZero = 0;
  return string.data() ? string.data() : &kZero;
}

static bool IsSchemeFirstChar(char c) {
  return (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z');
}

static bool IsSchemeChar(char c) {
  return IsSchemeFirstChar(c) || (c >= '0' && c <= '9') || c == '.' || c == '-' || c == '+';
}

static bool IsUnicodeEncoding() {
  return true;
}

bool IsValidProtocol(const std::string& protocol) {
  // RFC3986: ALPHA *( ALPHA / DIGIT / "+" / "-" / "." )
  if (protocol.empty())
    return false;
  if (!IsSchemeFirstChar(protocol[0]))
    return false;
  unsigned protocol_length = protocol.length();
  for (unsigned i = 1; i < protocol_length; i++) {
    if (!IsSchemeChar(protocol[i]))
      return false;
  }
  return true;
}

KURL KURL::UrlStrippedForUseAsReferrer() const {
  if (!SchemeRegistry::ShouldTreatURLSchemeAsAllowedForReferrer(Protocol()))
    return KURL();

  KURL referrer(*this);

  referrer.SetUser(std::string());
  referrer.SetPass(std::string());
  referrer.RemoveFragmentIdentifier();

  return referrer;
}

std::string KURL::StrippedForUseAsReferrer() const {
  return UrlStrippedForUseAsReferrer().GetString();
}

std::string KURL::StrippedForUseAsHref() const {
  if (parsed_.username.is_nonempty() || parsed_.password.is_nonempty()) {
    KURL href(*this);
    href.SetUser(std::string());
    href.SetPass(std::string());
    return href.GetString();
  }
  return GetString();
}

bool KURL::IsLocalFile() const {
  // Including feed here might be a bad idea since drag and drop uses this check
  // and including feed would allow feeds to potentially let someone's blog
  // read the contents of the clipboard on a drag, even without a drop.
  // Likewise with using the FrameLoader::shouldTreatURLAsLocal() function.
  return ProtocolIs(url::kFileScheme);
}

bool ProtocolIsJavaScript(const std::string& url) {
  return ProtocolIs(url, url::kJavaScriptScheme);
}

const KURL& BlankURL() {
  thread_local static KURL blank_url = KURL(url::kAboutBlankURL);
  return blank_url;
}

const KURL& SrcdocURL() {
  thread_local static KURL srcdoc_url = KURL(url::kAboutSrcdocURL);
  return srcdoc_url;
}

namespace {

// static
bool IsAboutPath(std::string_view actual_path, std::string_view allowed_path) {
  if (!base::StartsWith(actual_path, allowed_path))
    return false;

  if (actual_path.size() == allowed_path.size()) {
    DCHECK_EQ(actual_path, allowed_path);
    return true;
  }

  if ((actual_path.size() == allowed_path.size() + 1) && actual_path.back() == '/') {
    DCHECK_EQ(actual_path, std::string(allowed_path) + '/');
    return true;
  }

  return false;
}

}  // namespace

bool KURL::IsAboutURL(const char* allowed_path) const {
  if (!ProtocolIsAbout())
    return false;

  // Using `is_nonempty` for `host` and `is_valid` for `username` and `password`
  // to replicate how GURL::IsAboutURL (and GURL::has_host vs
  // GURL::has_username) works.
  if (parsed_.host.is_nonempty() || parsed_.username.is_valid() || parsed_.password.is_valid() || HasPort()) {
    return false;
  }

  std::string path = ComponentStringView(parsed_.path);
  std::string_view path_utf8(path);
  return IsAboutPath(path_utf8, allowed_path);
}

bool KURL::IsAboutBlankURL() const {
  return IsAboutURL(url::kAboutBlankPath);
}

bool KURL::IsAboutSrcdocURL() const {
  return IsAboutURL(url::kAboutSrcdocPath);
}

const KURL& NullURL() {
  thread_local static KURL static_null_url = KURL();
  return static_null_url;
}

std::string KURL::ElidedString() const {
  const std::string& string = string_;
  if (string.length() <= 1024) {
    return string;
  }

  return string.substr(0, 511) + "..." + string.substr(string.length() - 510, 510);
}

KURL::KURL() : is_valid_(false), protocol_is_in_http_family_(false) {}

// Initializes with a string representing an absolute URL. No encoding
// information is specified. This generally happens when a KURL is converted
// to a string and then converted back. In this case, the URL is already
// canonical and in proper escaped form so needs no encoding. We treat it as
// UTF-8 just in case.
KURL::KURL(const std::string& url) {
  if (!url.empty()) {
    Init(NullURL(), url);
    AssertStringSpecIsASCII();
  } else {
    // WebCore expects us to preserve the nullness of strings when this
    // constructor is used. In all other cases, it expects a non-null
    // empty string, which is what Init() will create.
    is_valid_ = false;
    protocol_is_in_http_family_ = false;
  }
}

// Constructs a new URL given a base URL and a possibly relative input URL.
// This assumes UTF-8 encoding.
KURL::KURL(const KURL& base, const std::string& relative) {
  Init(base, relative);
  AssertStringSpecIsASCII();
}

// Constructs a new URL given a base URL and a possibly relative input URL.
// Any query portion of the relative URL will be encoded in the given encoding.
// KURL::KURL(const KURL& base,
//          const std::string& relative,
//          const WTF::TextEncoding& encoding) {
// Init(base, relative, &encoding.EncodingForFormSubmission());
// AssertStringSpecIsASCII();
//}

KURL::KURL(const std::string& canonical_string, const url::Parsed& parsed, bool is_valid)
    : is_valid_(is_valid), protocol_is_in_http_family_(false), parsed_(parsed), string_(canonical_string) {
  InitProtocolMetadata();
  InitInnerURL();
  // For URLs with non-ASCII hostnames canonical_string will be in punycode.
  // We can't check has_idna2008_deviation_character_ without decoding punycode.
  // here.
  AssertStringSpecIsASCII();
}

KURL::KURL(const KURL& other)
    : is_valid_(other.is_valid_),
      protocol_is_in_http_family_(other.protocol_is_in_http_family_),
      protocol_(other.protocol_),
      parsed_(other.parsed_),
      string_(other.string_) {
  if (other.inner_url_.get())
    inner_url_ = std::make_unique<KURL>(*other.inner_url_);
}

KURL::~KURL() = default;

KURL& KURL::operator=(const KURL& other) {
  is_valid_ = other.is_valid_;
  protocol_is_in_http_family_ = other.protocol_is_in_http_family_;
  protocol_ = other.protocol_;
  parsed_ = other.parsed_;
  string_ = other.string_;
  if (other.inner_url_)
    inner_url_ = std::make_unique<KURL>(*other.inner_url_);
  else
    inner_url_.reset();
  return *this;
}

bool KURL::IsNull() const {
  return string_.empty();
}

bool KURL::IsEmpty() const {
  return string_.empty();
}

bool KURL::IsValid() const {
  return is_valid_;
}

bool KURL::HasPort() const {
  return HostEnd() < PathStart();
}

bool KURL::ProtocolIsJavaScript() const {
  return ComponentStringView(parsed_.scheme) == url::kJavaScriptScheme;
}

bool KURL::ProtocolIsInHTTPFamily() const {
  return protocol_is_in_http_family_;
}

bool KURL::HasPath() const {
  // Note that http://www.google.com/" has a path, the path is "/". This can
  // return false only for invalid or nonstandard URLs.
  return parsed_.path.is_valid();
}

std::string KURL::LastPathComponent() const {
  if (!is_valid_)
    return StringViewForInvalidComponent();
  DCHECK(!string_.empty());

  // When the output ends in a slash, WebCore has different expectations than
  // the GoogleURL library. For "/foo/bar/" the library will return the empty
  // string, but WebCore wants "bar".
  url::Component path = parsed_.path;
  if (path.is_nonempty() && string_[path.end() - 1] == '/')
    path.len--;

  url::Component file;
  url::ExtractFileName(AsURint8_t8Subtle(string_), path, &file);

  // Bug: https://bugs.webkit.org/show_bug.cgi?id=21015 this function returns
  // a null string when the path is empty, which we duplicate here.
  if (file.is_empty())
    return std::string();
  return ComponentString(file);
}

std::string KURL::Protocol() const {
  DCHECK_EQ(ComponentString(parsed_.scheme), protocol_);
  return protocol_;
}

std::string KURL::Host() const {
  return ComponentString(parsed_.host);
}

std::string KURL::HostView() const {
  return ComponentStringView(parsed_.host);
}

uint16_t KURL::Port() const {
  if (!is_valid_ || parsed_.port.is_empty())
    return 0;
  int port = url::ParsePort(AsURint8_t8Subtle(string_), parsed_.port);
  DCHECK_NE(port, url::PORT_UNSPECIFIED);  // Checked port.len <= 0 already.
  DCHECK_NE(port, url::PORT_INVALID);      // Checked is_valid_ already.

  return static_cast<uint16_t>(port);
}

// TODO(csharrison): Migrate pass() and user() to return a StringView. Most
// consumers just need to know if the string is empty.

std::string KURL::Pass() const {
  // Bug: https://bugs.webkit.org/show_bug.cgi?id=21015 this function returns
  // a null string when the password is empty, which we duplicate here.
  if (parsed_.password.is_empty())
    return std::string();
  return ComponentString(parsed_.password);
}

std::string KURL::User() const {
  return ComponentString(parsed_.username);
}

std::string KURL::FragmentIdentifier() const {
  // Empty but present refs ("foo.com/bar#") should result in the empty
  // string, which componentstd::string will produce. Nonexistent refs
  // should be the null string.
  if (!parsed_.ref.is_valid())
    return std::string();
  return ComponentString(parsed_.ref);
}

bool KURL::HasFragmentIdentifier() const {
  return parsed_.ref.is_valid();
}

std::string KURL::BaseAsString() const {
  // FIXME: There is probably a more efficient way to do this?
  return string_.substr(0, PathAfterLastSlash());
}

std::string KURL::Query() const {
  if (parsed_.query.is_valid())
    return ComponentString(parsed_.query);

  // TODO(tsepez): not reachable?
  // Bug: https://bugs.webkit.org/show_bug.cgi?id=21015 this function returns
  // an empty string when the query is empty rather than a null (not sure
  // which is right).
  // Returns a null if the query is not specified, instead of empty.
  if (parsed_.query.is_valid())
    return std::string();
  return std::string();
}

std::string KURL::GetPath() const {
  return ComponentString(parsed_.path);
}

namespace {

bool IsASCIITabOrNewline(char16_t ch) {
  return ch == '\t' || ch == '\r' || ch == '\n';
}

// See https://url.spec.whatwg.org/#concept-basic-url-parser:
// 3. Remove all ASCII tab or newline from |input|.
//
// Matches url::RemoveURLWhitespace.
std::string RemoveURLWhitespace(const std::string& input) {
  std::string result = input;
  result.erase(std::remove_if(result.begin(), result.end(), IsASCIITabOrNewline), result.end());
  return result;
}

}  // namespace

bool KURL::SetProtocol(const std::string& protocol) {
  // We should remove whitespace from |protocol| according to spec, but Firefox
  // and Safari don't do it.
  // - https://url.spec.whatwg.org/#dom-url-protocol
  // - https://github.com/whatwg/issues/609

  // Firefox and IE remove everything after the first ':'.
  uint32_t separator_position = protocol.find(':');
  std::string new_protocol = protocol.substr(0, separator_position);

  // If KURL is given an invalid scheme, it returns failure without modifying
  // the URL at all. This is in contrast to most other setters which modify
  // the URL and set "m_isValid."
  url::RawCanonOutputT<char> canon_protocol;
  url::Component protocol_component;
  if (!url::CanonicalizeScheme(new_protocol.data(), url::Component(0, new_protocol.size()), &canon_protocol,
                               &protocol_component) ||
      protocol_component.is_empty())
    return false;

  DCHECK_EQ(protocol_component.begin, 0);
  const size_t protocol_length = base::checked_cast<size_t>(protocol_component.len);
  const std::string new_protocol_canon = std::string(canon_protocol.data(), protocol_length);

  if (SchemeRegistry::IsSpecialScheme(Protocol())) {
    // https://url.spec.whatwg.org/#scheme-state
    // 2.1.1 If url’s scheme is a special scheme and buffer is not a special
    //       scheme, then return.
    if (!SchemeRegistry::IsSpecialScheme(new_protocol_canon)) {
      return true;
    }

    // The protocol is lower-cased during canonicalization.
    const bool new_protocol_is_file = new_protocol_canon == url::kFileScheme;
    const bool old_protocol_is_file = ProtocolIs(url::kFileScheme);

    // https://url.spec.whatwg.org/#scheme-state
    // 3. If url includes credentials or has a non-null port, and buffer is
    //    "file", then return.
    if (new_protocol_is_file && !old_protocol_is_file &&
        (HasPort() || parsed_.username.is_nonempty() || parsed_.password.is_nonempty())) {
      // This fails silently, which is weird, but necessary to give the expected
      // behaviour when setting location.protocol. See
      // https://html.spec.whatwg.org/multipage/history.html#dom-location-protocol.
      return true;
    }

    // 4. If url’s scheme is "file" and its host is an empty host, then return.
    if (!new_protocol_is_file && old_protocol_is_file && parsed_.host.is_empty()) {
      // This fails silently as above.
      return true;
    }
  }

  url::Replacements<char> replacements;
  replacements.SetScheme(CharactersOrEmpty(new_protocol), url::Component(0, new_protocol.size()));
  ReplaceComponents(replacements);

  // isValid could be false but we still return true here. This is because
  // WebCore or JS scripts can build up a URL by setting individual
  // components, and a JS exception is based on the return value of this
  // function. We want to throw the exception and stop the script only when
  // its trying to set a bad protocol, and not when it maybe just hasn't
  // finished building up its final scheme.
  return true;
}

namespace {

std::string ParsePortFromStringPosition(const std::string& value, unsigned port_start) {
  // "008080junk" needs to be treated as port "8080" and "000" as "0".
  size_t length = value.length();
  unsigned port_end = port_start;
  while (IsASCIIDigit(value[port_end]) && port_end < length)
    ++port_end;
  while (value[port_start] == '0' && port_start < port_end - 1)
    ++port_start;

  return value.substr(port_start, port_end - port_start);
}

// Align with https://url.spec.whatwg.org/#host-state step 3, and also with the
// IsAuthorityTerminator() function in //third_party/mozilla/url_parse.cc.
bool IsEndOfHost(char ch) {
  return ch == '/' || ch == '?' || ch == '#';
}

bool IsEndOfHostSpecial(char ch) {
  return IsEndOfHost(ch) || ch == '\\';
}

size_t FindHostEnd(const std::string& host, bool is_special) {
  auto it = std::find_if(host.begin(), host.end(), is_special ? IsEndOfHostSpecial : IsEndOfHost);
  if (it == host.end())
    return host.length();
  return std::distance(host.begin(), it);
}

}  // namespace

void KURL::SetHost(const std::string& input) {
  std::string host = RemoveURLWhitespace(input);
  uint32_t value_end = FindHostEnd(host, IsStandard());
  std::string truncated_host = host.substr(0, value_end);
  std::string host_utf8(truncated_host);
  url::Replacements<char> replacements;
  replacements.SetHost(CharactersOrEmpty(host_utf8), url::Component(0, host_utf8.size()));
  ReplaceComponents(replacements);
}

void KURL::SetHostAndPort(const std::string& input) {
  // This method intentionally does very sloppy parsing for backwards
  // compatibility. See https://url.spec.whatwg.org/#host-state for what we
  // theoretically should be doing.

  std::string orig_host_and_port = RemoveURLWhitespace(input);
  uint32_t value_end = FindHostEnd(orig_host_and_port, IsStandard());
  std::string host_and_port = orig_host_and_port.substr(0, value_end);

  // This logic for handling IPv6 addresses is adapted from ParseServerInfo in
  // //third_party/mozilla/url_parse.cc. There's a slight behaviour
  // difference for compatibility with the tests: the first colon after the
  // address is considered to start the port, instead of the last.
  auto it = std::find(host_and_port.rbegin(), host_and_port.rend(), ']');
  uint32_t ipv6_terminator = UINT_MAX;
  if (it == host_and_port.rend()) {
    ipv6_terminator = base::StartsWith(host_and_port, "[") ? host_and_port.length() : 0;
  } else {
    ipv6_terminator = *it;
  }

  uint32_t colon = host_and_port.find(':', ipv6_terminator);

  // Legacy behavior: ignore input if host part is empty
  if (colon == 0)
    return;

  std::string host;
  std::string port;
  if (colon == UINT_MAX) {
    host = host_and_port;
  } else {
    host = host_and_port.substr(0, colon);
    port = ParsePortFromStringPosition(host_and_port, colon + 1);
  }

  // Replace host and port separately in order to maintain the original port if
  // a valid host and invalid port are provided together.

  // Replace host first.
  {
    url::Replacements<char> replacements;
    replacements.SetHost(CharactersOrEmpty(host), url::Component(0, host.size()));
    ReplaceComponents(replacements);
  }

  // Replace port next.
  if (is_valid_ && !port.empty()) {
    url::Replacements<char> replacements;
    replacements.SetPort(CharactersOrEmpty(port), url::Component(0, port.size()));
    ReplaceComponents(replacements, /*preserve_validity=*/true);
  }
}

void KURL::RemovePort() {
  if (!HasPort())
    return;
  url::Replacements<char> replacements;
  replacements.ClearPort();
  ReplaceComponents(replacements);
}

void KURL::SetPort(const std::string& input) {
  std::string port = RemoveURLWhitespace(input);
  std::string parsed_port = ParsePortFromStringPosition(port, 0);
  if (parsed_port.empty()) {
    return;
  }

  unsigned port_value = std::stoul(parsed_port);
  if (port_value > UINT16_MAX) {
    return;
  }
  SetPort(port_value);
}

bool IsDefaultPortForProtocol(uint16_t port, const std::string& protocol) {
  if (protocol.empty())
    return false;

  switch (port) {
    case 80:
      return protocol == "http" || protocol == "ws";
    case 443:
      return protocol == "https" || protocol == "wss";
    case 21:
      return protocol == "ftp";
  }
  return false;
}

void KURL::SetPort(uint16_t port) {
  if (IsDefaultPortForProtocol(port, Protocol())) {
    RemovePort();
    return;
  }

  std::string port_string = std::to_string(port);

  url::Replacements<char> replacements;
  replacements.SetPort(reinterpret_cast<const char*>(port_string.data()), url::Component(0, port_string.length()));
  ReplaceComponents(replacements);
}

void KURL::SetUser(const std::string& user) {
  // This function is commonly called to clear the username, which we
  // normally don't have, so we optimize this case.
  if (user.empty() && !parsed_.username.is_valid())
    return;

  // The canonicalizer will clear any usernames that are empty, so we
  // don't have to explicitly call ClearUsername() here.
  //
  // Unlike other setters, we do not remove whitespace per spec:
  // https://url.spec.whatwg.org/#dom-url-username
  url::Replacements<char> replacements;
  replacements.SetUsername(CharactersOrEmpty(user), url::Component(0, user.size()));
  ReplaceComponents(replacements);
}

void KURL::SetPass(const std::string& pass) {
  // This function is commonly called to clear the password, which we
  // normally don't have, so we optimize this case.
  if (pass.empty() && !parsed_.password.is_valid())
    return;

  // The canonicalizer will clear any passwords that are empty, so we
  // don't have to explicitly call ClearUsername() here.
  //
  // Unlike other setters, we do not remove whitespace per spec:
  // https://url.spec.whatwg.org/#dom-url-password
  url::Replacements<char> replacements;
  replacements.SetPassword(CharactersOrEmpty(pass), url::Component(0, pass.size()));
  ReplaceComponents(replacements);
}

void KURL::SetFragmentIdentifier(const std::string& input) {
  // This function is commonly called to clear the ref, which we
  // normally don't have, so we optimize this case.
  if (input.empty() && !parsed_.ref.is_valid())
    return;

  std::string fragment = RemoveURLWhitespace(input);

  url::Replacements<char> replacements;
  if (fragment.empty()) {
    replacements.ClearRef();
  } else {
    replacements.SetRef(CharactersOrEmpty(fragment), url::Component(0, fragment.size()));
  }
  ReplaceComponents(replacements);
}

void KURL::RemoveFragmentIdentifier() {
  url::Replacements<char> replacements;
  replacements.ClearRef();
  ReplaceComponents(replacements);
}

void KURL::SetQuery(const std::string& input) {
  std::string query = RemoveURLWhitespace(input);
  url::Replacements<char> replacements;
  if (query.empty()) {
    // KURL.cpp sets to null to clear any query.
    replacements.ClearQuery();
  } else if (query.length() > 0 && query[0] == '?') {
    // WebCore expects the query string to begin with a question mark, but
    // GoogleURL doesn't. So we trim off the question mark when setting.
    replacements.SetQuery(CharactersOrEmpty(query), url::Component(1, query.size() - 1));
  } else {
    // When set with the empty string or something that doesn't begin with
    // a question mark, KURL.cpp will add a question mark for you. The only
    // way this isn't compatible is if you call this function with an empty
    // string. KURL.cpp will leave a '?' with nothing following it in the
    // URL, whereas we'll clear it.
    // FIXME We should eliminate this difference.
    replacements.SetQuery(CharactersOrEmpty(query), url::Component(0, query.size()));
  }
  ReplaceComponents(replacements);
}

void KURL::SetPath(const std::string& input) {
  // Empty paths will be canonicalized to "/", so we don't have to worry
  // about calling ClearPath().
  std::string path = RemoveURLWhitespace(input);
  url::Replacements<char> replacements;
  replacements.SetPath(CharactersOrEmpty(path), url::Component(0, path.size()));
  ReplaceComponents(replacements);
}

// std::string DecodeURLEscapeSequences(const std::string& string, DecodeURLMode mode) {
//  url::RawCanonOutputT<char16_t> unescaped;
//  url::DecodeURLEscapeSequences(string, mode, &unescaped);
//  return std::string(unescaped.data());
// }

std::string EncodeWithURLEscapeSequences(const std::string& not_encoded_string) {
  std::string utf8 = not_encoded_string;

  url::RawCanonOutputT<char> buffer;
  size_t input_length = utf8.length();
  if (buffer.capacity() < input_length * 3)
    buffer.Resize(input_length * 3);

  url::EncodeURIComponent(utf8, &buffer);
  std::string escaped(buffer.data(), static_cast<unsigned>(buffer.length()));
  // Unescape '/'; it's safe and much prettier.
  // escaped.Replace("%2F", "/");
  std::string replaced_escaped;
  base::ReplaceChars(escaped, "%2F", "/", &replaced_escaped);
  return replaced_escaped;
}

bool HasInvalidURLEscapeSequences(const std::string& string) {
  return url::HasInvalidURLEscapeSequences(string);
}

bool KURL::CanSetHostOrPort() const {
  return IsHierarchical();
}

bool KURL::CanSetPathname() const {
  return IsHierarchical();
}

bool KURL::CanRemoveHost() const {
  return false;
}

bool KURL::IsHierarchical() const {
  return IsStandard();
}

bool KURL::IsStandard() const {
  if (string_.empty() || parsed_.scheme.is_empty())
    return false;
  return url::IsStandard(AsURint8_t8Subtle(string_), parsed_.scheme);
}

bool EqualIgnoringFragmentIdentifier(const KURL& a, const KURL& b) {
  // Compute the length of each URL without its ref. Note that the reference
  // begin (if it exists) points to the character *after* the '#', so we need
  // to subtract one.
  int a_length = a.string_.length();
  if (a.parsed_.ref.is_valid())
    a_length = a.parsed_.ref.begin - 1;

  int b_length = b.string_.length();
  if (b.parsed_.ref.is_valid())
    b_length = b.parsed_.ref.begin - 1;

  if (a_length != b_length)
    return false;

  const std::string& a_string = a.string_;
  const std::string& b_string = b.string_;
  // FIXME: Abstraction this into a function in WTFString.h.
  for (int i = 0; i < a_length; ++i) {
    if (a_string[i] != b_string[i])
      return false;
  }
  return true;
}

unsigned KURL::HostStart() const {
  return parsed_.CountCharactersBefore(url::Parsed::HOST, false);
}

unsigned KURL::HostEnd() const {
  return parsed_.CountCharactersBefore(url::Parsed::PORT, true);
}

unsigned KURL::PathStart() const {
  return parsed_.CountCharactersBefore(url::Parsed::PATH, false);
}

unsigned KURL::PathEnd() const {
  return parsed_.CountCharactersBefore(url::Parsed::QUERY, true);
}

unsigned KURL::PathAfterLastSlash() const {
  if (string_.empty())
    return 0;
  if (!is_valid_ || !parsed_.path.is_valid())
    return parsed_.CountCharactersBefore(url::Parsed::PATH, false);
  url::Component filename;
  url::ExtractFileName(AsURint8_t8Subtle(string_), parsed_.path, &filename);
  return filename.begin;
}

bool ProtocolIs(const std::string& url, const char* protocol) {
#if DCHECK_IS_ON()
  AssertProtocolIsGood(protocol);
#endif
  if (url.empty())
    return false;
  return url::FindAndCompareScheme(AsURint8_t8Subtle(url), url.length(), protocol, nullptr);
}

void KURL::Init(const KURL& base, const std::string& relative) {
  // As a performance optimization, we do not use the charset converter
  // if encoding is UTF-8 or other Unicode encodings. Note that this is
  // per HTML5 2.5.3 (resolving URL). The URL canonicalizer will be more
  // efficient with no charset converter object because it can do UTF-8
  // internally with no extra copies.
  std::string base_utf8(base.GetString());

  // Clamp to int max to avoid overflow.
  url::RawCanonOutputT<char> output;

  if (!relative.empty()) {
    is_valid_ = url::ResolveRelative(base_utf8.data(), base_utf8.size(), base.parsed_, relative.data(),
                                     ClampTo<int>(relative.size()), &output, &parsed_);
  }

  // Constructing an Atomicstd::string will re-hash the raw output and check the
  // AtomicStringTable (addWithTranslator) for the string. This can be very
  // expensive for large URLs. However, since many URLs are generated from
  // existing AtomicStrings (which already have their hashes computed), the fast
  // path can often avoid this work.
  if (!relative.empty() && std::string(output.data(), static_cast<unsigned>(output.length())) == relative) {
    string_ = relative;
  } else {
    string_ = std::string(output.data());
  }

  if (!relative.empty()) {
    std::string relative_utf8(relative);
    is_valid_ = url::ResolveRelative(base_utf8.data(), base_utf8.size(), base.parsed_, relative_utf8.data(),
                                     ClampTo<int>(relative_utf8.size()), &output, &parsed_);
  }

  InitProtocolMetadata();
  InitInnerURL();
  AssertStringSpecIsASCII();

  // This assertion implicitly assumes that "javascript:" scheme URL is always
  // valid, but that is no longer true when
  // kStandardCompliantNonSpecialSchemeURLParsing feature is enabled. e.g.
  // "javascript://^", which is an invalid URL.
  DCHECK(!::webf::ProtocolIsJavaScript(string_) || ProtocolIsJavaScript());
}

void KURL::InitInnerURL() {
  if (!is_valid_) {
    inner_url_.reset();
    return;
  }
  if (url::Parsed* inner_parsed = parsed_.inner_parsed()) {
    inner_url_ = std::make_unique<KURL>(
        string_.substr(inner_parsed->scheme.begin, inner_parsed->Length() - inner_parsed->scheme.begin));
  } else {
    inner_url_.reset();
  }
}

void KURL::InitProtocolMetadata() {
  if (!is_valid_) {
    protocol_is_in_http_family_ = false;
    protocol_ = ComponentString(parsed_.scheme);
    return;
  }

  std::string protocol = ComponentStringView(parsed_.scheme);
  protocol_is_in_http_family_ = true;
  if (protocol == url::kHttpsScheme) {
    protocol_ = url::kHttpsScheme;
  } else if (protocol == url::kHttpScheme) {
    protocol_ = url::kHttpScheme;
  } else {
    protocol_ = protocol;
    protocol_is_in_http_family_ = false;
  }
  DCHECK_EQ(protocol_, base::ToLowerASCII(protocol_));
}

void KURL::AssertStringSpecIsASCII() {
  // //url canonicalizes to 7-bit ASCII, using punycode and percent-escapes.
  // This means that even though KURL itself might sometimes contain 16-bit
  // strings, it is still safe to reuse the `url::Parsed' object from the
  // canonicalization step: the byte offsets in `url::Parsed` will still be
  // valid for a 16-bit ASCII string, since there is a 1:1 mapping between the
  // UTF-8 indices and UTF-16 indices.
  DCHECK(base::ContainsOnlyASCIIOrEmpty(string_));

  // It is not possible to check that `string_` is 8-bit here. There are some
  // instances where `string_` reuses an already-canonicalized `AtomicString`
  // which only contains ASCII characters but, for some reason or another, uses
  // 16-bit characters.
}

bool KURL::ProtocolIs(const std::string protocol) const {
#if DCHECK_IS_ON()
  AssertProtocolIsGood(protocol);
#endif

  // JavaScript URLs are "valid" and should be executed even if KURL decides
  // they are invalid.  The free function protocolIsJavaScript() should be used
  // instead.
  // FIXME: Chromium code needs to be fixed for this assert to be enabled.
  // DCHECK(strcmp(protocol, "javascript"));
  return protocol_ == protocol;
}

std::string KURL::StringViewForInvalidComponent() const {
  return std::string();
}

std::string KURL::ComponentStringView(const url::Component& component) const {
  if (!is_valid_ || component.is_empty())
    return StringViewForInvalidComponent();

  // begin and len are in terms of bytes which do not match
  // if string() is UTF-16 and input contains non-ASCII characters.
  // However, the only part in urlstd::string that can contain non-ASCII
  // characters is 'ref' at the end of the string. In that case,
  // begin will always match the actual value and len (in terms of
  // byte) will be longer than what's needed by 'mid'. However, mid
  // truncates len to avoid go past the end of a string so that we can
  // get away without doing anything here.
  int max_length = GetString().length() - component.begin;
  return std::string(GetString(), component.begin, component.len > max_length ? max_length : component.len);
}

std::string KURL::ComponentString(const url::Component& component) const {
  return ComponentStringView(component);
}

template <typename CHAR>
void KURL::ReplaceComponents(const url::Replacements<CHAR>& replacements, bool preserve_validity) {
  url::RawCanonOutputT<char> output;
  url::Parsed new_parsed;

  std::string utf8(string_);
  bool replacements_valid =
      url::ReplaceComponents(utf8.data(), utf8.size(), parsed_, replacements, &output, &new_parsed);
  if (replacements_valid || !preserve_validity) {
    is_valid_ = replacements_valid;
    parsed_ = new_parsed;
    string_ = std::string(output.data());
    InitProtocolMetadata();
    AssertStringSpecIsASCII();
  }
}

// void KURL::WriteIntoTrace(perfetto::TracedValue context) const {
//  return perfetto::WriteIntoTracedValue(std::move(context), GetString());
// }
bool operator==(const KURL& a, const KURL& b) {
  return a.GetString() == b.GetString();
}

bool operator==(const KURL& a, const std::string& b) {
  return a.GetString() == b;
}

bool operator==(const std::string& a, const KURL& b) {
  return a == b.GetString();
}

bool operator!=(const KURL& a, const KURL& b) {
  return a.GetString() != b.GetString();
}

bool operator!=(const KURL& a, const std::string& b) {
  return a.GetString() != b;
}

bool operator!=(const std::string& a, const KURL& b) {
  return a != b.GetString();
}

std::ostream& operator<<(std::ostream& os, const KURL& url) {
  return os << url.GetString();
}

// BASE_FEATURE(kAvoidWastefulHostCopies,
//             "AvoidWastefulHostCopies",
//             base::FEATURE_ENABLED_BY_DEFAULT);

}  // namespace webf