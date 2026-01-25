/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:webf/webf.dart';

import 'icon_button_bindings_generated.dart';

/// Common Lucide icons mapping from string names to IconData.
/// This allows JavaScript to specify icons by name.
IconData? _getLucideIcon(String? name) {
  if (name == null) return null;

  // Map common icon names to LucideIcons
  switch (name.toLowerCase()) {
    // Navigation & arrows
    case 'chevron-right': return LucideIcons.chevronRight;
    case 'chevron-left': return LucideIcons.chevronLeft;
    case 'chevron-up': return LucideIcons.chevronUp;
    case 'chevron-down': return LucideIcons.chevronDown;
    case 'arrow-right': return LucideIcons.arrowRight;
    case 'arrow-left': return LucideIcons.arrowLeft;
    case 'arrow-up': return LucideIcons.arrowUp;
    case 'arrow-down': return LucideIcons.arrowDown;

    // Actions
    case 'plus': return LucideIcons.plus;
    case 'minus': return LucideIcons.minus;
    case 'x': case 'close': return LucideIcons.x;
    case 'check': return LucideIcons.check;
    case 'search': return LucideIcons.search;
    case 'settings': return LucideIcons.settings;
    case 'edit': case 'pencil': return LucideIcons.pencil;
    case 'trash': case 'delete': return LucideIcons.trash;
    case 'copy': return LucideIcons.copy;
    case 'share': return LucideIcons.share;
    case 'download': return LucideIcons.download;
    case 'upload': return LucideIcons.upload;
    case 'refresh': case 'refresh-cw': return LucideIcons.refreshCw;
    case 'save': return LucideIcons.save;
    case 'send': return LucideIcons.send;
    case 'play': return LucideIcons.play;
    case 'pause': return LucideIcons.pause;
    case 'stop': return LucideIcons.square;

    // Objects
    case 'rocket': return LucideIcons.rocket;
    case 'heart': return LucideIcons.heart;
    case 'star': return LucideIcons.star;
    case 'home': return LucideIcons.house;
    case 'user': return LucideIcons.user;
    case 'users': return LucideIcons.users;
    case 'mail': case 'email': return LucideIcons.mail;
    case 'phone': return LucideIcons.phone;
    case 'calendar': return LucideIcons.calendar;
    case 'clock': return LucideIcons.clock;
    case 'file': return LucideIcons.file;
    case 'folder': return LucideIcons.folder;
    case 'image': return LucideIcons.image;
    case 'camera': return LucideIcons.camera;
    case 'video': return LucideIcons.video;
    case 'music': return LucideIcons.music;
    case 'mic': case 'microphone': return LucideIcons.mic;
    case 'bell': return LucideIcons.bell;
    case 'bookmark': return LucideIcons.bookmark;
    case 'tag': return LucideIcons.tag;
    case 'link': return LucideIcons.link;
    case 'globe': return LucideIcons.globe;
    case 'map': return LucideIcons.map;
    case 'pin': case 'map-pin': return LucideIcons.mapPin;
    case 'lock': return LucideIcons.lock;
    case 'unlock': return LucideIcons.lockOpen;
    case 'key': return LucideIcons.key;
    case 'shield': return LucideIcons.shield;
    case 'eye': return LucideIcons.eye;
    case 'eye-off': return LucideIcons.eyeOff;
    case 'sun': return LucideIcons.sun;
    case 'moon': return LucideIcons.moon;
    case 'cloud': return LucideIcons.cloud;

    // UI elements
    case 'menu': return LucideIcons.menu;
    case 'more-horizontal': case 'ellipsis': return LucideIcons.ellipsis;
    case 'more-vertical': return LucideIcons.ellipsisVertical;
    case 'grid': return LucideIcons.layoutGrid;
    case 'list': return LucideIcons.list;
    case 'filter': return LucideIcons.funnel;
    case 'sort': case 'sort-asc': return LucideIcons.arrowUpDown;
    case 'maximize': return LucideIcons.maximize;
    case 'minimize': return LucideIcons.minimize;
    case 'external-link': return LucideIcons.externalLink;

    // Status & feedback
    case 'info': return LucideIcons.info;
    case 'alert-circle': case 'warning': return LucideIcons.circleAlert;
    case 'alert-triangle': return LucideIcons.triangleAlert;
    case 'help-circle': case 'help': return LucideIcons.circleQuestionMark;
    case 'check-circle': return LucideIcons.circleCheck;
    case 'x-circle': return LucideIcons.circleX;

    // Social & brand
    case 'github': return LucideIcons.github;
    case 'twitter': return LucideIcons.twitter;
    case 'facebook': return LucideIcons.facebook;
    case 'instagram': return LucideIcons.instagram;
    case 'linkedin': return LucideIcons.linkedin;
    case 'youtube': return LucideIcons.youtube;

    // Formatting
    case 'bold': return LucideIcons.bold;
    case 'italic': return LucideIcons.italic;
    case 'underline': return LucideIcons.underline;
    case 'align-left': return LucideIcons.textAlignStart;
    case 'align-center': return LucideIcons.textAlignCenter;
    case 'align-right': return LucideIcons.textAlignEnd;

    // Shopping
    case 'shopping-cart': case 'cart': return LucideIcons.shoppingCart;
    case 'shopping-bag': case 'bag': return LucideIcons.shoppingBag;
    case 'credit-card': return LucideIcons.creditCard;

    // Communication
    case 'message-circle': case 'chat': return LucideIcons.messageCircle;
    case 'message-square': return LucideIcons.messageSquare;
    case 'at-sign': return LucideIcons.atSign;

    // Misc
    case 'loader': case 'loading': case 'loader-2': return LucideIcons.loader;
    case 'zap': return LucideIcons.zap;
    case 'activity': return LucideIcons.activity;
    case 'terminal': return LucideIcons.terminal;
    case 'code': return LucideIcons.code;
    case 'database': return LucideIcons.database;
    case 'server': return LucideIcons.server;
    case 'wifi': return LucideIcons.wifi;
    case 'bluetooth': return LucideIcons.bluetooth;
    case 'battery': return LucideIcons.battery;
    case 'power': return LucideIcons.power;
    case 'cpu': return LucideIcons.cpu;
    case 'hard-drive': return LucideIcons.hardDrive;
    case 'printer': return LucideIcons.printer;
    case 'qr-code': return LucideIcons.qrCode;
    case 'barcode': return LucideIcons.barcode;
    case 'scan': return LucideIcons.scan;
    case 'scan-face': return LucideIcons.scanFace;

    default: return null;
  }
}

/// WebF custom element that wraps shadcn_ui [ShadIconButton].
///
/// Exposed as `<flutter-shadcn-icon-button>` in the DOM.
class FlutterShadcnIconButton extends FlutterShadcnIconButtonBindings {
  FlutterShadcnIconButton(super.context);

  String _variant = 'primary';
  String? _icon;
  double? _iconSize;
  bool _disabled = false;
  bool _loading = false;

  @override
  String get variant => _variant;

  @override
  get disableBoxModelPaint => true;

  @override
  set variant(value) {
    final newValue = value?.toString() ?? 'primary';
    if (newValue != _variant) {
      _variant = newValue;
      state?.requestUpdateState(() {});
    }
  }

  @override
  String? get icon => _icon;

  @override
  set icon(value) {
    final newValue = value?.toString();
    if (newValue != _icon) {
      _icon = newValue;
      state?.requestUpdateState(() {});
    }
  }

  @override
  double? get iconSize => _iconSize;

  @override
  set iconSize(value) {
    final newValue = value as double?;
    if (newValue != _iconSize) {
      _iconSize = newValue;
      state?.requestUpdateState(() {});
    }
  }

  @override
  bool get disabled => _disabled;

  @override
  set disabled(value) {
    final newValue = value == true;
    if (newValue != _disabled) {
      _disabled = newValue;
      state?.requestUpdateState(() {});
    }
  }

  @override
  bool get loading => _loading;

  @override
  set loading(value) {
    final newValue = value == true;
    if (newValue != _loading) {
      _loading = newValue;
      state?.requestUpdateState(() {});
    }
  }

  ShadButtonVariant get buttonVariant {
    switch (_variant.toLowerCase()) {
      case 'secondary':
        return ShadButtonVariant.secondary;
      case 'destructive':
        return ShadButtonVariant.destructive;
      case 'outline':
        return ShadButtonVariant.outline;
      case 'ghost':
        return ShadButtonVariant.ghost;
      default:
        return ShadButtonVariant.primary;
    }
  }

  @override
  WebFWidgetElementState createState() => FlutterShadcnIconButtonState(this);
}

class FlutterShadcnIconButtonState extends WebFWidgetElementState {
  FlutterShadcnIconButtonState(super.widgetElement);

  @override
  FlutterShadcnIconButton get widgetElement =>
      super.widgetElement as FlutterShadcnIconButton;

  /// Get the foreground color for the button based on its variant.
  Color? _getForegroundColor(BuildContext context) {
    final theme = ShadTheme.of(context);
    final ShadButtonTheme buttonTheme;

    switch (widgetElement.buttonVariant) {
      case ShadButtonVariant.primary:
        buttonTheme = theme.primaryButtonTheme;
        break;
      case ShadButtonVariant.secondary:
        buttonTheme = theme.secondaryButtonTheme;
        break;
      case ShadButtonVariant.destructive:
        buttonTheme = theme.destructiveButtonTheme;
        break;
      case ShadButtonVariant.outline:
        buttonTheme = theme.outlineButtonTheme;
        break;
      case ShadButtonVariant.ghost:
        buttonTheme = theme.ghostButtonTheme;
        break;
      case ShadButtonVariant.link:
        buttonTheme = theme.linkButtonTheme;
        break;
    }

    return buttonTheme.foregroundColor;
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = widgetElement.loading;
    final isDisabled = widgetElement.disabled;
    final isClickable = !isDisabled && !isLoading;

    // Get the foreground color from the button theme
    final foregroundColor = _getForegroundColor(context);

    // Get gradient from CSS background-image: linear-gradient(...)
    final cssGradient = widgetElement.renderStyle.backgroundImage?.gradient;

    // Get shadows from CSS box-shadow
    final cssShadows = widgetElement.renderStyle.shadows;

    // Determine icon size
    final effectiveIconSize = widgetElement.iconSize ?? 16.0;

    // Build the icon widget
    Widget iconWidget;
    if (isLoading) {
      // Show loading spinner
      iconWidget = SizedBox.square(
        dimension: effectiveIconSize,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: foregroundColor ?? Colors.white,
        ),
      );
    } else {
      // Get the icon from the icon name
      final iconData = _getLucideIcon(widgetElement.icon);
      if (iconData != null) {
        iconWidget = Icon(iconData, size: effectiveIconSize);
      } else {
        // Default to a placeholder icon if no valid icon name
        iconWidget = Icon(LucideIcons.circle, size: effectiveIconSize);
      }
    }

    return ShadIconButton.raw(
      variant: widgetElement.buttonVariant,
      iconSize: effectiveIconSize,
      enabled: !isDisabled,
      gradient: cssGradient,
      shadows: cssShadows,
      onPressed: isClickable
          ? () {
              widgetElement.dispatchEvent(Event('click'));
            }
          : null,
      onLongPress: isClickable
          ? () {
              widgetElement.dispatchEvent(Event('longpress'));
            }
          : null,
      icon: iconWidget,
    );
  }
}
