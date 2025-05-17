/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:webf/dom.dart';
import 'package:webf/dom.dart' as dom;
import 'package:webf/rendering.dart';
import 'package:webf/svg.dart';

class GestureDispatcher {
  dom.Element target;

  GestureDispatcher(this.target) {
    _gestureRecognizers = {
      EVENT_CLICK: TapGestureRecognizer()..onTapUp = _onClick
    };
  }

  late Map<String, GestureRecognizer> _gestureRecognizers;

  void _handlePointerDown(PointerDownEvent event) {
    // Add pointer to gestures then register the gesture recognizer to the arena.
    _gestureRecognizers.forEach((eventName, gesture) {
      gesture.addPointer(event);
    });
  }

  void _handlePointerPanZoomStart(PointerPanZoomStartEvent event) {
    // Add pointer to gestures then register the gesture recognizer to the arena.
    _gestureRecognizers.forEach((eventName, gesture) {
      gesture.addPointerPanZoom(event);
    });
  }

  void handlePointerEvent(PointerEvent event) {
    if (event is PointerDownEvent) {
      _handlePointerDown(event);
    }

    if (event is PointerPanZoomStartEvent) {
      _handlePointerPanZoomStart(event);
    }
  }

  void _onClick(TapUpDetails details) {
    _handleMouseEvent(EVENT_CLICK, localPosition: details.localPosition, globalPosition: details.globalPosition);
  }

  EventTarget getCurrentEventTarget() {
    EventTarget currentTarget = target;

    if (currentTarget is SVGElement && currentTarget.hostingImageElement != null) {
      currentTarget = currentTarget.hostingImageElement!;
    }

    return currentTarget;
  }

  void _handleMouseEvent(String type, {Offset localPosition = Offset.zero, Offset globalPosition = Offset.zero}) {
    RenderBox? root = (this.target as Node).ownerDocument.attachedRenderer;

    if (root == null) {
      return;
    }

    EventTarget target = this.target;

    if (target is dom.Element) {
      BoxHitTestResult boxHitTestResult = BoxHitTestResult();
      Offset offset = Offset(localPosition.dx, localPosition.dy);
      bool isHit = target.attachedRenderer!.hitTest(boxHitTestResult, position: offset);
      if(!isHit) {
        return;
      }

      // Find the first top RenderBoxModel
      RenderBoxModel? targetBoxModel;
      if (boxHitTestResult.path.isNotEmpty) {
        boxHitTestResult.path.firstWhere((entry) {
          if (entry.target is RenderBoxModel) {
            targetBoxModel = entry.target as RenderBoxModel;
            return true;
          }
          return false;
        });
      }

      if (targetBoxModel != null) {
        target = targetBoxModel?.renderStyle.target as EventTarget;
      }
    }

    Offset globalOffset = root.globalToLocal(Offset(globalPosition.dx, globalPosition.dy));
    double clientX = globalOffset.dx;
    double clientY = globalOffset.dy;

    Event event = MouseEvent(type,
        clientX: clientX,
        clientY: clientY,
        offsetX: localPosition.dx,
        offsetY: localPosition.dy,
        view: (target as Node).ownerDocument.defaultView);
    target.dispatchEvent(event);
  }
}
