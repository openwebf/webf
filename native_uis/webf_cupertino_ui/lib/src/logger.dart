/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:logger/logger.dart';

/// Global logger instance for WebF Cupertino UI
final Logger logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 0,
    lineLength: 80,
    colors: true,
    printEmojis: true,
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    noBoxingByDefault: true,
  ),
  level: Level.debug,
);

/// Logger specifically for development/debugging
final Logger devLogger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 0,
    lineLength: 120,
    colors: true,
    printEmojis: true,
    dateTimeFormat: DateTimeFormat.dateAndTime,
    noBoxingByDefault: true,
  ),
  level: Level.trace,
);
