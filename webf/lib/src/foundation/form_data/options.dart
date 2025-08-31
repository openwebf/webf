// MIT License
//
// Copyright (c) 2018 Wen Du (wendux)
// Copyright (c) 2022 The CFUG Team

/// {@template dio.options.ProgressCallback}
/// The type of a progress listening callback when sending or receiving data.
///
/// [count] is the length of the bytes have been sent/received.
///
/// [total] is the content length of the response/request body.
/// 1. When sending data, [total] is the request body length.
/// 2. When receiving data, [total] will be -1 if the size of the response body,
///    typically with no `content-length` header.
/// {@endtemplate}
typedef ProgressCallback = void Function(int count, int total);

/// {@template dio.options.ListFormat}
/// Specifies the array format (a single parameter with multiple parameter
/// or multiple parameters with the same name).
/// and the separator for array items.
/// {@endtemplate}
enum ListFormat {
  /// Comma-separated values.
  /// e.g. (foo,bar,baz)
  csv,

  /// Space-separated values.
  /// e.g. (foo bar baz)
  ssv,

  /// Tab-separated values.
  /// e.g. (foo\tbar\tbaz)
  tsv,

  /// Pipe-separated values.
  /// e.g. (foo|bar|baz)
  pipes,

  /// Multiple parameter instances rather than multiple values.
  /// e.g. (foo=value&foo=another_value)
  multi,

  /// Forward compatibility.
  /// e.g. (foo[]=value&foo[]=another_value)
  multiCompatible,
}

/// {@template dio.options.FileAccessMode}
/// The file access mode when downloading a file, corresponds to a subset of
/// dart:io::[FileMode].
/// {@endtemplate}
enum FileAccessMode {
  /// Mode for opening a file for reading and writing. The file is overwritten
  /// if it already exists. The file is created if it does not already exist.
  write,

  /// Mode for opening a file for reading and writing to the end of it.
  /// The file is created if it does not already exist.
  append,
}
