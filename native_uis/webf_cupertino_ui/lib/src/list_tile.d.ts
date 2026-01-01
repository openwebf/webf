/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

/**
 * Properties for <flutter-cupertino-list-tile>
 * iOS-style list row used inside <flutter-cupertino-list-section>.
 */
interface FlutterCupertinoListTileProperties {
  /**
   * Whether to render the iOS-style chevron indicator on the trailing edge.
   * When true and no custom trailing slot is provided, a default chevron is shown.
   * Default: false.
   */
  'show-chevron'?: boolean;

  /**
   * Whether to use the "notched" visual style for this tile.
   * Default: false.
   */
  notched?: boolean;
}

interface FlutterCupertinoListTileEvents {
  /**
   * Fired when the tile is tapped.
   */
  click: Event;
}

/**
 * Properties for <flutter-cupertino-list-tile-leading>
 * Slot container for the leading widget (icon, avatar, etc.).
 */
interface FlutterCupertinoListTileLeadingProperties {}

interface FlutterCupertinoListTileLeadingEvents {}

/**
 * Properties for <flutter-cupertino-list-tile-subtitle>
 * Slot container for the subtitle widget shown under the title.
 */
interface FlutterCupertinoListTileSubtitleProperties {}

interface FlutterCupertinoListTileSubtitleEvents {}

/**
 * Properties for <flutter-cupertino-list-tile-additional-info>
 * Slot container for right-aligned secondary label text.
 */
interface FlutterCupertinoListTileAdditionalInfoProperties {}

interface FlutterCupertinoListTileAdditionalInfoEvents {}

/**
 * Properties for <flutter-cupertino-list-tile-trailing>
 * Slot container for a custom trailing widget (switch, badge, etc.).
 * When present, it replaces the default chevron.
 */
interface FlutterCupertinoListTileTrailingProperties {}

interface FlutterCupertinoListTileTrailingEvents {}
