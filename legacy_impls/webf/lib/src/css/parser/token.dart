/*
Copyright 2013, the Dart project authors. 

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above
      copyright notice, this list of conditions and the following
      disclaimer in the documentation and/or other materials provided
      with the distribution.
    * Neither the name of Google LLC nor the names of its
      contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

part of 'parser.dart';

/// A single token in the Dart language.
class Token {
  /// A member of [TokenKind] specifying what kind of token this is.
  final int kind;

  /// The location where this token was parsed from.
  final FileSpan span;

  /// The start offset of this token.
  int get start => span.start.offset;

  /// The end offset of this token.
  int get end => span.end.offset;

  /// Returns the source text corresponding to this [Token].
  String get text => span.text;

  Token(this.kind, this.span);

  /// Returns a pretty representation of this token for error messages.
  @override
  String toString() {
    var kindText = TokenKind.kindToString(kind);
    var actualText = text.trim();
    if (kindText != actualText) {
      if (actualText.length > 10) {
        actualText = '${actualText.substring(0, 8)}...';
      }
      return '$kindText($actualText)';
    } else {
      return kindText;
    }
  }
}

/// A token containing a parsed literal value.
class LiteralToken extends Token {
  dynamic value;
  LiteralToken(int kind, FileSpan span, this.value) : super(kind, span);
}

/// A token containing error information.
class ErrorToken extends Token {
  String? message;
  ErrorToken(int kind, FileSpan span, this.message) : super(kind, span);
}

/// CSS ident-token.
///
/// See <http://dev.w3.org/csswg/css-syntax/#typedef-ident-token> and
/// <http://dev.w3.org/csswg/css-syntax/#ident-token-diagram>.
class IdentifierToken extends Token {
  @override
  final String text;

  IdentifierToken(this.text, int kind, FileSpan span) : super(kind, span);
}
