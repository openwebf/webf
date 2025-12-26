/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */


import 'package:flutter/material.dart' as flutter;
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:webf/dom.dart';
import 'package:webf/css.dart';
import 'package:webf/html.dart';
import 'package:webf/rendering.dart';
import 'package:webf/foundation.dart';
import 'package:webf/widget.dart';

// Enable verbose logging for DOM → widget building and anonymous block wrapping.
bool debugLogDomAdapterEnabled = false;

enum ScreenEventType { onScreen, offScreen }

class ScreenEvent {
  final ScreenEventType type;
  final OnScreenEvent? onScreenEvent;
  final OffScreenEvent? offScreenEvent;
  final DateTime timestamp;

  ScreenEvent.onScreen(this.onScreenEvent)
      : type = ScreenEventType.onScreen,
        offScreenEvent = null,
        timestamp = DateTime.now();

  ScreenEvent.offScreen(this.offScreenEvent)
      : type = ScreenEventType.offScreen,
        onScreenEvent = null,
        timestamp = DateTime.now();
}

/// Piece type used when flattening an inline element that contains block-level children.
class _InlineOrBlockPiece {
  final List<flutter.Widget>? inlineChildren;
  final flutter.Widget? blockWidget;
  final bool isInline;
  _InlineOrBlockPiece.inline(this.inlineChildren)
      : blockWidget = null,
        isInline = true;
  _InlineOrBlockPiece.block(this.blockWidget)
      : inlineChildren = null,
        isInline = false;
}

mixin ElementAdapterMixin on ElementBase {
  // Holds out-of-flow positioned descendants (absolute, sticky, fixed)
  final List<Element> _outOfFlowPositionedElements = [];

  // Track the screen state and event queue
  final List<ScreenEvent> _screenEventQueue = [];
  bool _isProcessingQueue = false;

  List<Element> get outOfFlowPositionedElements => _outOfFlowPositionedElements;

  void addOutOfFlowPositionedElement(Element newElement) {
    assert(() {
      if (_outOfFlowPositionedElements.contains(newElement)) {
        throw FlutterError('Found repeat element in $_outOfFlowPositionedElements for $newElement');
      }

      return true;
    }());
    _outOfFlowPositionedElements.add(newElement);
  }

  Element? getOutOfFlowPositionedElementByIndex(int index) {
    return (index >= 0 && index < _outOfFlowPositionedElements.length ? _outOfFlowPositionedElements[index] : null);
  }

  void removeOutOfFlowPositionedElement(Element element) {
    _outOfFlowPositionedElements.remove(element);
  }

  void clearOutOfFlowPositionedElements() {
    _outOfFlowPositionedElements.clear();
  }

  // Rendering this element as an RenderPositionHolder
  Element? holderAttachedPositionedElement;
  Element? holderAttachedContainingBlockElement;

  flutter.ScrollController? _scrollControllerX;

  flutter.ScrollController? get scrollControllerX => _scrollControllerX;

  flutter.ScrollController? _scrollControllerY;

  flutter.ScrollController? get scrollControllerY => _scrollControllerY;

  final Set<flutter.RenderObjectElement> positionHolderElements = {};

  bool hasEvent = false;
  bool hasScroll = false;

  void enqueueScreenEvent(ScreenEvent event) {
    // If we're enqueuing an onScreen event, remove any pending offScreen events
    if (event.type == ScreenEventType.onScreen) {
      _screenEventQueue.removeWhere((e) => e.type == ScreenEventType.offScreen);
    }

    _screenEventQueue.add(event);
    _processEventQueue();
  }

  void _processEventQueue() {
    if (_isProcessingQueue || _screenEventQueue.isEmpty) return;

    _isProcessingQueue = true;
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      while (_screenEventQueue.isNotEmpty) {
        final event = _screenEventQueue.removeAt(0);

        // Process events based on current state and event type
        if (event.type == ScreenEventType.offScreen) {
          await (this as Element).dispatchEvent(event.offScreenEvent!);
        } else if (event.type == ScreenEventType.onScreen) {
          // Only dispatch onScreen if we're not already on screen
          await (this as Element).dispatchEventUtilAdded(event.onScreenEvent!);
        }
      }
      _isProcessingQueue = false;
    });
    SchedulerBinding.instance.scheduleFrame();
  }

  @override
  flutter.Widget toWidget({Key? key}) {
    return WebFElementWidget(this as Element, key: key ?? (this as Element).key);
  }
}

class WebFElementWidget extends flutter.StatefulWidget {
  final Element webFElement;

  const WebFElementWidget(this.webFElement, {super.key}) : super();

  @override
  flutter.State<flutter.StatefulWidget> createState() {
    return WebFElementWidgetState();
  }

  @override
  String toStringShort() {
    String attributes = '';
    if (webFElement.id != null) {
      attributes += 'id="${webFElement.id!}"';
    }
    if (webFElement.className.isNotEmpty) {
      attributes += 'class="${webFElement.className}"';
    }

    return '<${webFElement.tagName.toLowerCase()}#$hashCode $attributes>';
  }
}

class WebFElementWidgetState extends flutter.State<WebFElementWidget> with flutter.AutomaticKeepAliveClientMixin {
  late final Element webFElement;

  @override
  void initState() {
    super.initState();
    webFElement = widget.webFElement;
    webFElement.addState(this);
  }

  void requestForChildNodeUpdate(AdapterUpdateReason reason) {
    if (!mounted) return;
    final phase = SchedulerBinding.instance.schedulerPhase;
    // Avoid setState during build; defer to next frame.
    if (phase == SchedulerPhase.persistentCallbacks || phase == SchedulerPhase.midFrameMicrotasks) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
      SchedulerBinding.instance.scheduleFrame();
    } else {
      setState(() {});
    }
  }

  @override
  flutter.Widget build(flutter.BuildContext context) {
    super.build(context);

    WebFState? webFState;
    WebFRouterViewState? routerViewState;

    if (this is WidgetElement || webFElement.renderStyle.display == CSSDisplay.none) {
      return flutter.SizedBox.shrink();
    }

    List<flutter.Widget> children = [];
    if (webFElement.childNodes.isEmpty) {
      children = [];
    } else {
      // Check if we need to create anonymous block boxes for inline content
      // Case 2: Inline content needs to be wrapped to maintain proper formatting context
      final shouldWrap = _shouldWrapInlineContentInAnonymousBlocks();
      if (debugLogDomAdapterEnabled) {
        domLogger.fine('[DOMAdapter] build <${webFElement.tagName}> wrapInline=$shouldWrap '
            'display=${webFElement.renderStyle.display} childCount=${webFElement.childNodes.length}');
      }
      if (shouldWrap) {
        children = _wrapInlineContentInAnonymousBlocks(webFElement.childNodes);
      } else {
        for (var node in webFElement.childNodes) {
          if (debugLogDomAdapterEnabled) {
            domLogger.finer('[DOMAdapter] child node=${node.runtimeType}');
          }
          if (node is Element &&
              (node.renderStyle.position == CSSPositionType.absolute ||
                  node.renderStyle.position == CSSPositionType.sticky)) {
            // Keep the placeholder in normal flow to capture the original layout offset
            // but do NOT add the actual positioned element here. It will be attached
            // directly under its containing block during that element's build.
            if (node.holderAttachedPositionedElement != null) {
              children.add(PositionPlaceHolder(node.holderAttachedPositionedElement!, node));
            }
            continue;
          } else if (node is Element && node.renderStyle.position == CSSPositionType.fixed) {
            children.add(PositionPlaceHolder(node.holderAttachedPositionedElement!, node));
          } else if (node is RouterLinkElement) {
            webFState ??= context.findAncestorStateOfType<WebFState>();
            String routerPath = node.path;
            if (webFState != null && (webFState.widget.controller.initialRoute ?? '/') == routerPath) {
              children.add(node.toWidget());
              continue;
            }

            routerViewState ??= context.findAncestorStateOfType<WebFRouterViewState>();
            if (routerViewState != null) {
              children.add(node.toWidget());
              continue;
            }

            children.add(flutter.SizedBox.shrink());
            continue;
          } else if (node is TextNode) {
            if (node.data.trim().isNotEmpty) {
              if (debugLogDomAdapterEnabled) {
                final t = node.data;
                domLogger.fine('[DOMAdapter] add TextNode "${t.length > 24 ? '${t.substring(0,24)}…' : t}"');
              }
              children.add(node.toWidget());
            } else {
              if (debugLogDomAdapterEnabled) {
                domLogger.finer('[DOMAdapter] skip empty TextNode');
              }
            }
          } else if (node is Comment) {
            // Skip comments entirely
            if (debugLogDomAdapterEnabled) {
              domLogger.finer('[DOMAdapter] skip Comment');
            }
          } else {
            // Fallback: render regular elements
            if (debugLogDomAdapterEnabled) {
              domLogger.fine('[DOMAdapter] add element ${node.runtimeType} via toWidget()');
            }
            children.add(node.toWidget());
          }
        }
      }
      for (final positionedElement in webFElement.outOfFlowPositionedElements) {
        try {
          PositionedLayoutLog.log(
            impl: PositionedImpl.build,
            feature: PositionedFeature.wiring,
            message: () => 'build positioned <${positionedElement.tagName.toLowerCase()}>'
                ' under containing block <${webFElement.tagName.toLowerCase()}>',
          );
        } catch (_) {}
        children.add(positionedElement.toWidget());
      }
    }

    flutter.Widget widget;

    if (webFElement.hasScroll) {
      // Use effective overflow values so that when one axis is 'visible'
      // and the other is non-visible, the 'visible' side computes to 'auto'
      // per CSS Overflow spec. This ensures correct bi-axis scrollability.
      CSSOverflowType overflowX = webFElement.renderStyle.effectiveOverflowX;
      CSSOverflowType overflowY = webFElement.renderStyle.effectiveOverflowY;

      flutter.Widget? scrollableX;
      if (overflowX == CSSOverflowType.scroll ||
          overflowX == CSSOverflowType.auto ||
          overflowX == CSSOverflowType.hidden) {
        webFElement._scrollControllerX ??= flutter.ScrollController();
        final bool xScrollable = overflowX != CSSOverflowType.hidden;
        final bool isRTL = webFElement.renderStyle.direction == TextDirection.rtl;
        scrollableX = LayoutBoxWrapper(
            ownerElement: webFElement,
            child: NestedScrollCoordinator(
                axis: flutter.Axis.horizontal,
                controller: webFElement.scrollControllerX!,
                enabled: xScrollable,
                child: flutter.Scrollable(
                    controller: webFElement.scrollControllerX,
                    axisDirection: isRTL ? AxisDirection.left : AxisDirection.right,
                    // WebF provides custom overflow scroll semantics from the
                    // render tree (see RenderOverflowMixin.describeOverflowSemantics).
                    // Disable Flutter's Scrollable semantics here to avoid
                    // duplicate/competing scroll semantics nodes.
                    excludeFromSemantics: true,
                    physics: xScrollable ? flutter.ClampingScrollPhysics() : const flutter.NeverScrollableScrollPhysics(),
                    viewportBuilder: (flutter.BuildContext context, ViewportOffset position) {
                      flutter.Widget adapter = WebFRenderLayoutWidgetAdaptor(
                        webFElement: webFElement,
                        key: webFElement.key,
                        scrollListener: webFElement.handleScroll,
                        positionX: position,
                        children: children,
                      );

                      return adapter;
                    })));
      }

      if (overflowY == CSSOverflowType.scroll ||
          overflowY == CSSOverflowType.auto ||
          overflowY == CSSOverflowType.hidden) {
        webFElement._scrollControllerY ??= flutter.ScrollController();
        final bool yScrollable = overflowY != CSSOverflowType.hidden;
        final bool xScrollable = overflowX != CSSOverflowType.hidden;
        widget = LayoutBoxWrapper(
            ownerElement: webFElement,
            child: NestedScrollCoordinator(
                axis: flutter.Axis.vertical,
                controller: webFElement.scrollControllerY!,
                enabled: yScrollable,
                child: flutter.Scrollable(
                    axisDirection: AxisDirection.down,
                    physics: yScrollable ? const flutter.ClampingScrollPhysics() : const flutter.NeverScrollableScrollPhysics(),
                    controller: webFElement.scrollControllerY,
                    // See note above for overflow scroll semantics ownership.
                    excludeFromSemantics: true,
                    viewportBuilder: (flutter.BuildContext context, ViewportOffset positionY) {
                      if (scrollableX != null) {
                        final bool isRTL = webFElement.renderStyle.direction == TextDirection.rtl;
                        return NestedScrollCoordinator(
                            axis: flutter.Axis.horizontal,
                            controller: webFElement.scrollControllerX!,
                            // Base on effective overflow to honor visible->auto conversion
                            enabled: (webFElement.renderStyle.effectiveOverflowX != CSSOverflowType.hidden),
                            child: flutter.Scrollable(
                                controller: webFElement.scrollControllerX,
                                axisDirection: isRTL ? AxisDirection.left : AxisDirection.right,
                                excludeFromSemantics: true,
                                physics: xScrollable ? const flutter.ClampingScrollPhysics() : const flutter.NeverScrollableScrollPhysics(),
                                viewportBuilder: (flutter.BuildContext context, ViewportOffset positionX) {
                                  flutter.Widget adapter = WebFRenderLayoutWidgetAdaptor(
                                    webFElement: webFElement,
                                    key: webFElement.key,
                                    scrollListener: webFElement.handleScroll,
                                    positionX: positionX,
                                    positionY: positionY,
                                    children: children,
                                  );
                                  return adapter;
                                }));
                      }

                      return WebFRenderLayoutWidgetAdaptor(
                        webFElement: webFElement,
                        key: webFElement.key,
                        scrollListener: webFElement.handleScroll,
                        positionY: positionY,
                        children: children,
                      );
                    })));
      } else {
        widget = scrollableX ??
            WebFRenderLayoutWidgetAdaptor(webFElement: webFElement, key: webFElement.key, children: children);
      }
    } else {
      widget = WebFRenderLayoutWidgetAdaptor(webFElement: webFElement, key: webFElement.key, children: children);
    }

    // Expose this element's scroll controllers to descendants to enable nested scrolling.
    final wrapped = NestedScrollForwarder(
      verticalController: webFElement.scrollControllerY,
      horizontalController: webFElement.scrollControllerX,
      child: widget,
    );

    return WebFEventListener(
        ownerElement: webFElement,
        hasEvent: webFElement.hasEvent,
        enableTouchEvent: webFElement is WebFTouchAreaElement,
        child: wrapped);
  }

  @override
  void deactivate() {
    super.deactivate();
    webFElement._scrollControllerY?.dispose();
    webFElement._scrollControllerY = null;
    webFElement._scrollControllerX?.dispose();
    webFElement._scrollControllerX = null;
    webFElement.removeState(this);
  }

  @override
  void activate() {
    super.activate();
    webFElement.addState(this);
  }

  @override
  void dispose() {
    webFElement.removeState(this);
    webFElement._scrollControllerY?.dispose();
    webFElement._scrollControllerY = null;
    webFElement._scrollControllerX?.dispose();
    webFElement._scrollControllerX = null;
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  /// Check if this element needs to wrap inline content in anonymous blocks
  /// Case 2: When a block container has mixed inline and block-level children
  /// Case 3: When a flex container has text nodes or inline content as direct children
  /// Case 4: When an inline child contains block-level children (block-in-inline splitting)
  bool _shouldWrapInlineContentInAnonymousBlocks() {
    final display = webFElement.renderStyle.display;

    // Flex containers need to wrap text nodes in anonymous flex items
    if (display == CSSDisplay.flex || display == CSSDisplay.inlineFlex) {
      // Check if there's any text content that needs wrapping
      for (var node in webFElement.childNodes) {
        if (node is TextNode && node.data.trim().isNotEmpty) {
          return true;
        }
      }
      return false;
    }

    // Block-like containers (block and inline-block) can create anonymous block
    // boxes for mixed content. Inline containers are handled by their parent via
    // Case 4 detection below.
    if (display != CSSDisplay.block && display != CSSDisplay.inlineBlock) {
      return false;
    }

    bool hasInlineContent = false;
    bool hasBlockContent = false;
    bool hasInlineWithBlockDescendant = false;

    for (var node in webFElement.childNodes) {
      if (node is TextNode && node.data.trim().isNotEmpty) {
        hasInlineContent = true;
      } else if (node is Element) {
        final childDisplay = node.renderStyle.display;
        final position = node.renderStyle.position;

        // Skip positioned elements as they're out of flow
        if (position == CSSPositionType.absolute || position == CSSPositionType.fixed) {
          continue;
        }

        if (childDisplay == CSSDisplay.block || childDisplay == CSSDisplay.flex) {
          hasBlockContent = true;
        } else if (childDisplay == CSSDisplay.inline ||
            childDisplay == CSSDisplay.inlineBlock ||
            childDisplay == CSSDisplay.inlineFlex) {
          // Treat inline-flex as inline-level for anonymous block grouping per spec.
          hasInlineContent = true;
          // Case 4: inline child that itself contains block-level children
          // Detect using renderStyle helper to avoid deep scanning here
          try {
            if (node.renderStyle.shouldCreateAnonymousBlockBoxForInlineElements()) {
              hasInlineWithBlockDescendant = true;
            }
          } catch (_) {}
        }
      }

      // If we have both, we need anonymous blocks
      if (hasInlineContent && hasBlockContent) {
        return true;
      }
    }

    // If any inline child contains block children, we need wrapping at this level
    if (hasInlineWithBlockDescendant) return true;

    return false;
  }

  /// Wrap inline content in anonymous block boxes
  /// This maintains proper block formatting context when mixing inline and block content
  /// For flex containers, creates anonymous flex items
  List<flutter.Widget> _wrapInlineContentInAnonymousBlocks(NodeList nodes) {
    List<flutter.Widget> result = [];
    List<flutter.Widget> currentInlineGroup = [];

    final isFlexContainer = webFElement.renderStyle.display == CSSDisplay.flex ||
                           webFElement.renderStyle.display == CSSDisplay.inlineFlex;

    void flushInlineGroup() {
      if (currentInlineGroup.isNotEmpty) {
        // For flex containers, create anonymous flex items
        // For block containers, create anonymous block boxes
        final anonymousDisplay = isFlexContainer ? 'block' : 'block';

        // Create anonymous box for inline content group
        final anonymousBlock = WebFHTMLElement(
          tagName: 'Anonymous',
          controller: webFElement.ownerDocument.controller,
          parentElement: webFElement,
          inlineStyle: {
            'display': anonymousDisplay,
            // Anonymous boxes should not have any other styles
          },
          children: currentInlineGroup, // Pass the collected widgets as children
        );
        if (debugLogDomAdapterEnabled) {
          domLogger.fine('[DOMAdapter] flushInlineGroup count=${currentInlineGroup.length} → Anonymous');
        }
        result.add(anonymousBlock);
        currentInlineGroup = [];
      }
    }

    for (var node in nodes) {
      if (debugLogDomAdapterEnabled) {
        domLogger.finer('[DOMAdapter] wrap pass node=${node.runtimeType}');
      }
      if (node is Element) {
        final display = node.renderStyle.display;
        final position = node.renderStyle.position;

        // Handle positioned elements specially
        if (position == CSSPositionType.absolute || position == CSSPositionType.sticky) {
          if (node.holderAttachedPositionedElement != null) {
            // For flex containers, positioned elements are not flex items
            // Add them directly without wrapping
            if (isFlexContainer) {
              flushInlineGroup();
              result.add(PositionPlaceHolder(node.holderAttachedPositionedElement!, node));
            } else {
              currentInlineGroup.add(PositionPlaceHolder(node.holderAttachedPositionedElement!, node));
            }
          } else {
            // For flex containers, absolutely positioned elements don't participate in flex layout
            if (isFlexContainer) {
              flushInlineGroup();
              // The actual positioned renderObject is attached to the containing block; skip here.
            } else {
              // The actual positioned renderObject is attached to the containing block; skip here.
            }
          }
          continue;
        } else if (position == CSSPositionType.fixed) {
          // Fixed positioned elements are always out of flow
          if (isFlexContainer) {
            flushInlineGroup();
            result.add(PositionPlaceHolder(node.holderAttachedPositionedElement!, node));
          } else {
            currentInlineGroup.add(PositionPlaceHolder(node.holderAttachedPositionedElement!, node));
          }
          continue;
        }

        // For flex containers, all non-positioned children become flex items
        if (isFlexContainer) {
          // In flex containers, ALL elements (inline, inline-block, block) become direct flex items
          // Only text nodes need to be wrapped in anonymous flex items
          flushInlineGroup();
          if (node is RouterLinkElement) {
            final widget = _handleRouterLinkElement(node);
            if (widget != null) {
              result.add(widget);
            }
          } else {
            result.add(node.toWidget());
          }
        } else {
          // For block containers, handle mixed content
          // Case 4: If an inline child contains block-level children, split it at this level
          if (display == CSSDisplay.inline && _inlineElementHasBlockChildren(node)) {
            // Flatten into ordered pieces (inline segments and block children).
            final pieces = _flattenInlineElementWithBlocksPieces(node);
            if (debugLogDomAdapterEnabled) {
              domLogger.fine('[DOMAdapter] flattened inline-with-blocks into ${pieces.length} pieces');
            }
            for (final piece in pieces) {
              if (piece.isInline) {
                // Accumulate inline pieces into the current inline group so
                // they can join with preceding/succeeding inline siblings.
                currentInlineGroup.addAll(piece.inlineChildren!);
              } else {
                // Encountering a block piece: flush current inline group first,
                // then add the block widget as a sibling.
                flushInlineGroup();
                result.add(piece.blockWidget!);
              }
            }
          } else if (display == CSSDisplay.block || display == CSSDisplay.flex) {
            // Flush any pending inline content before adding block
            flushInlineGroup();

            // Add block element directly (not in anonymous block)
            if (node is RouterLinkElement) {
              final widget = _handleRouterLinkElement(node);
              if (widget != null) {
                result.add(widget);
              }
            } else {
              result.add(node.toWidget());
            }
          } else {
            // Inline or inline-block element
            if (node is RouterLinkElement) {
              final widget = _handleRouterLinkElement(node);
              if (widget != null) {
                currentInlineGroup.add(widget);
              }
            } else {
              currentInlineGroup.add(node.toWidget());
            }
          }
        }
      } else {
        // Text nodes are always inline content
        if (node is TextNode && node.data.trim().isNotEmpty) {
          if (debugLogDomAdapterEnabled) {
            final t = node.data;
            domLogger.fine('[DOMAdapter] add TextNode to inlineGroup "${t.length > 24 ? '${t.substring(0,24)}…' : t}"');
          }
          currentInlineGroup.add(node.toWidget());
        } else if (node is Comment) {
          if (debugLogDomAdapterEnabled) {
            domLogger.finer('[DOMAdapter] skip Comment in wrap pass');
          }
          // Do not flush on comment; it should not break inline grouping
        } else {
          if (debugLogDomAdapterEnabled) {
            domLogger.finer('[DOMAdapter] skip non-rendered node type=${node.runtimeType} in wrap pass');
          }
        }
      }
    }

    // Flush any remaining inline content
    flushInlineGroup();

    return result;
  }

  /// Detect whether an inline element has any non-positioned block-level direct children.
  bool _inlineElementHasBlockChildren(Element inlineEl) {
    if (inlineEl.renderStyle.display != CSSDisplay.inline) return false;
    for (final child in inlineEl.childNodes) {
      if (child is Element) {
        final disp = child.renderStyle.display;
        final pos = child.renderStyle.position;
        if (pos == CSSPositionType.absolute || pos == CSSPositionType.fixed) continue;
        if (disp == CSSDisplay.block || disp == CSSDisplay.flex) return true;
      }
    }
    return false;
  }

  /// Flatten an inline element that contains block-level children according to CSS block-in-inline rules.
  /// Returns an ordered list of pieces. Inline pieces contain raw children (not anonymously wrapped)
  /// so the caller can merge them with adjacent inline siblings. Block pieces are individual widgets.
  List<_InlineOrBlockPiece> _flattenInlineElementWithBlocksPieces(Element inlineEl) {
    assert(inlineEl.renderStyle.display == CSSDisplay.inline);

    List<_InlineOrBlockPiece> flattened = [];
    List<flutter.Widget> pendingInlineGroup = [];

    void flushPendingInline() {
      if (pendingInlineGroup.isEmpty) return;
      flattened.add(_InlineOrBlockPiece.inline(List<flutter.Widget>.from(pendingInlineGroup)));
      pendingInlineGroup = [];
    }

    for (final child in inlineEl.childNodes) {
      if (child is Element) {
        final disp = child.renderStyle.display;
        final pos = child.renderStyle.position;

        // Positioned elements don't participate in flow; preserve placeholders in inline stream
        if (pos == CSSPositionType.absolute || pos == CSSPositionType.sticky) {
          if (child.holderAttachedPositionedElement != null) {
            pendingInlineGroup.add(PositionPlaceHolder(child.holderAttachedPositionedElement!, child));
          }
          continue;
        } else if (pos == CSSPositionType.fixed) {
          pendingInlineGroup.add(PositionPlaceHolder(child.holderAttachedPositionedElement!, child));
          continue;
        }

        if (disp == CSSDisplay.block || disp == CSSDisplay.flex) {
          flushPendingInline();
          flattened.add(_InlineOrBlockPiece.block(child.toWidget()));
        } else if (disp == CSSDisplay.inline || disp == CSSDisplay.inlineBlock || disp == CSSDisplay.inlineFlex) {
          pendingInlineGroup.add(child.toWidget());
        } else {
          pendingInlineGroup.add(child.toWidget());
        }
      } else if (child is TextNode) {
        if (child.data.trim().isNotEmpty) {
          pendingInlineGroup.add(child.toWidget());
        }
      }
    }

    flushPendingInline();
    return flattened;
  }

  /// Handle RouterLinkElement rendering logic
  flutter.Widget? _handleRouterLinkElement(RouterLinkElement node) {
    final webFState = context.findAncestorStateOfType<WebFState>();
    String routerPath = node.path;
    if (webFState != null && (webFState.widget.controller.initialRoute ?? '/') == routerPath) {
      return node.toWidget();
    }

    final routerViewState = context.findAncestorStateOfType<WebFRouterViewState>();
    if (routerViewState != null) {
      return node.toWidget();
    }

    return flutter.SizedBox.shrink();
  }
}

class WebFReplacedElementWidget extends flutter.StatefulWidget {
  const WebFReplacedElementWidget({required this.webFElement, required this.child, super.key});

  final Element webFElement;
  final flutter.Widget child;

  @override
  flutter.State<flutter.StatefulWidget> createState() {
    return WebFReplacedElementWidgetState();
  }
}

class WebFReplacedElementWidgetState extends flutter.State<WebFReplacedElementWidget>
    with flutter.AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    webFElement.addState(this);
  }

  Element get webFElement => widget.webFElement;

  void requestForChildNodeUpdate(AdapterUpdateReason reason) {
    if (reason is UpdateChildNodeUpdateReason) return;
    if (!mounted) return;
    final phase = SchedulerBinding.instance.schedulerPhase;
    if (phase == SchedulerPhase.persistentCallbacks || phase == SchedulerPhase.midFrameMicrotasks) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
      SchedulerBinding.instance.scheduleFrame();
    } else {
      setState(() {});
    }
  }

  @override
  flutter.Widget build(flutter.BuildContext context) {
    super.build(context);

    if (webFElement.renderStyle.display == CSSDisplay.none) {
      return flutter.SizedBox.shrink();
    }

    flutter.Widget child = WebFEventListener(
      ownerElement: webFElement,
      hasEvent: true,
      child: WebFRenderReplacedRenderObjectWidget(webFElement: webFElement, key: webFElement.key, child: widget.child),
    );

    return child;
  }

  @override
  void deactivate() {
    super.deactivate();
    webFElement.removeState(this);
  }

  @override
  void activate() {
    super.activate();
    webFElement.addState(this);
  }

  @override
  void dispose() {
    super.dispose();
    webFElement.removeState(this);
  }
}

class WebFRenderReplacedRenderObjectWidget extends flutter.SingleChildRenderObjectWidget {
  final Element webFElement;

  const WebFRenderReplacedRenderObjectWidget({required this.webFElement, super.key, super.child});

  @override
  RenderObject createRenderObject(flutter.BuildContext context) {
    // Prefer an existing paired render object; fall back to creating one if missing.
    RenderBoxModel renderBoxModel =  webFElement.renderStyle.getWidgetPairedRenderBoxModel(context as flutter.RenderObjectElement) ??
        (webFElement.createRenderer(context) as RenderBoxModel);

    // Attach position holder to apply offsets based on original layout.
    for (final positionHolder in webFElement.positionHolderElements) {
      if (positionHolder.mounted) {
        renderBoxModel.renderPositionPlaceholder = positionHolder.renderObject as RenderPositionPlaceholder;
        (positionHolder.renderObject as RenderPositionPlaceholder).positioned = renderBoxModel;
        try {
          PositionedLayoutLog.log(
            impl: PositionedImpl.build,
            feature: PositionedFeature.wiring,
            message: () => 'attach placeholder -> <${renderBoxModel.renderStyle.target.tagName.toLowerCase()}>'
                ' under <${webFElement.tagName.toLowerCase()}>',
          );
        } catch (_) {}
      }
    }

    return renderBoxModel;
  }

  @override
  flutter.SingleChildRenderObjectElement createElement() {
    return WebFRenderReplacedRenderObjectElement(this);
  }

  @override
  String toStringShort() {
    return webFElement.attachedRenderer?.toStringShort() ?? '';
  }
}

class WebFRenderReplacedRenderObjectElement extends flutter.SingleChildRenderObjectElement {
  WebFRenderReplacedRenderObjectElement(super.widget);


  @override
  WebFRenderReplacedRenderObjectWidget get widget => super.widget as WebFRenderReplacedRenderObjectWidget;

  // The renderObjects held by this adapter needs to be upgrade, from the requirements of the DOM tree style changes.
  void requestForBuild(AdapterUpdateReason reason) {
    if (reason is UpdateChildNodeUpdateReason) return;

    widget.webFElement.forEachState((state) {
      (state as WebFReplacedElementWidgetState).requestForChildNodeUpdate(reason);
    });
  }

  flutter.RouteSettings? _currentRouteSettings;

  @override
  void mount(flutter.Element? parent, Object? newSlot) {
    Element webFElement = widget.webFElement;
    webFElement.willAttachRenderer(this);

    super.mount(parent, newSlot);
    webFElement.didAttachRenderer();

    webFElement.style.flushPendingProperties();

    flutter.ModalRoute? route = flutter.ModalRoute.of(this);

    _currentRouteSettings = route?.settings;

    // Queue the onscreen event
    OnScreenEvent event =
        OnScreenEvent(state: _currentRouteSettings?.arguments, path: _currentRouteSettings?.name ?? '');
    webFElement.enqueueScreenEvent(ScreenEvent.onScreen(event));

    if (webFElement is ImageElement && webFElement.shouldLazyLoading) {
      (renderObject as RenderReplaced)
        ..intersectPadding = Rect.fromLTRB(0, 0, webFElement.ownerDocument.viewport!.viewportSize.width,
            webFElement.ownerDocument.viewport!.viewportSize.height)
        ..addIntersectionChangeListener(webFElement.handleIntersectionChange);
    }
  }

  @override
  void unmount() {
    // Flutter element unmount call dispose of _renderObject, so we should not call dispose in unmountRenderObject.
    Element element = widget.webFElement;

    // Queue the offscreen event
    OffScreenEvent event =
        OffScreenEvent(state: _currentRouteSettings?.arguments, path: _currentRouteSettings?.name ?? '');
    element.enqueueScreenEvent(ScreenEvent.offScreen(event));

    _currentRouteSettings = null;
    element.willDetachRenderer(this);
    super.unmount();
    element.didDetachRenderer(this);
  }
}

class WebFRenderLayoutWidgetAdaptor extends flutter.MultiChildRenderObjectWidget {
  const WebFRenderLayoutWidgetAdaptor(
      {this.webFElement,
      this.positionX,
      this.positionY,
      this.scrollListener,
      required super.children,
      super.key});

  final Element? webFElement;
  final ViewportOffset? positionX;
  final ViewportOffset? positionY;
  final ScrollListener? scrollListener;

  @override
  WebRenderLayoutRenderObjectElement createElement() {
    WebRenderLayoutRenderObjectElement element = ExternalWebRenderLayoutWidgetElement(webFElement!, this);
    return element;
  }

  @override
  flutter.RenderObject createRenderObject(flutter.BuildContext context) {
    // Prefer an existing paired render object; fall back to creating one if missing.
    RenderBoxModel? renderBoxModel =
        webFElement!.renderStyle.getWidgetPairedRenderBoxModel(context as flutter.RenderObjectElement);
    renderBoxModel ??= webFElement!.createRenderer(context) as RenderBoxModel;

    try {
      final phCount = webFElement!.positionHolderElements.length;
      final posCount = webFElement!.outOfFlowPositionedElements.length;
      PositionedLayoutLog.log(
        impl: PositionedImpl.build,
        feature: PositionedFeature.wiring,
        message: () => 'createRenderObject for <${webFElement!.tagName.toLowerCase()}>'
            ' placeholders=$phCount positionedChildren=$posCount',
      );
    } catch (_) {}

    // Attach position holder to apply offsets based on original layout.
    for (final positionHolder in webFElement!.positionHolderElements) {
      if (positionHolder.mounted) {
        renderBoxModel.renderPositionPlaceholder = positionHolder.renderObject as RenderPositionPlaceholder;
        (positionHolder.renderObject as RenderPositionPlaceholder).positioned = renderBoxModel;
      }
    }

    if (scrollListener != null) {
      renderBoxModel.scrollOffsetX = positionX;
      renderBoxModel.scrollOffsetY = positionY;
      renderBoxModel.scrollListener = scrollListener;
    }

    return renderBoxModel;
  }

  @override
  void updateRenderObject(flutter.BuildContext context, RenderBoxModel renderObject) {
    if (scrollListener != null) {
      renderObject.scrollOffsetX = positionX;
      renderObject.scrollOffsetY = positionY;
      renderObject.scrollListener = scrollListener;
    }
  }

  @override
  String toStringShort() {
    return webFElement?.attachedRenderer?.toStringShort() ?? '';
  }
}

abstract class WebRenderLayoutRenderObjectElement extends flutter.MultiChildRenderObjectElement {
  WebRenderLayoutRenderObjectElement(super.widget) : super();

  @override
  WebFRenderLayoutWidgetAdaptor get widget => super.widget as WebFRenderLayoutWidgetAdaptor;

  Element get webFElement;

  // The renderObjects held by this adapter needs to be upgrade, from the requirements of the DOM tree style changes.
  void requestForBuild(AdapterUpdateReason reason) {
    webFElement.forEachState((state) {
      (state as WebFElementWidgetState).requestForChildNodeUpdate(reason);
    });
  }

  @override
  void mount(flutter.Element? parent, Object? newSlot) {
    webFElement.willAttachRenderer(this);
    super.mount(parent, newSlot);
    webFElement.didAttachRenderer();

    webFElement.style.flushPendingProperties();
  }

  @override
  void unmount() {
    // Flutter element unmount call dispose of _renderObject, so we should not call dispose in unmountRenderObject.
    Element element = webFElement;
    element.willDetachRenderer(this);

    super.unmount();
    element.didDetachRenderer(this);
  }
}

class ExternalWebRenderLayoutWidgetElement extends WebRenderLayoutRenderObjectElement {
  final Element _webfElement;

  ExternalWebRenderLayoutWidgetElement(this._webfElement, WebFRenderLayoutWidgetAdaptor widget) : super(widget);

  flutter.RouteSettings? _currentRouteSettings;

  @override
  void mount(flutter.Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);

    flutter.ModalRoute? route = flutter.ModalRoute.of(this);

    _currentRouteSettings = route?.settings;

    // Queue the onscreen event
    OnScreenEvent event =
        OnScreenEvent(state: _currentRouteSettings?.arguments, path: _currentRouteSettings?.name ?? '');
    webFElement.enqueueScreenEvent(ScreenEvent.onScreen(event));
  }

  @override
  void unmount() {
    Element element = webFElement;

    // Queue the offscreen event
    OffScreenEvent event =
        OffScreenEvent(state: _currentRouteSettings?.arguments, path: _currentRouteSettings?.name ?? '');
    element.enqueueScreenEvent(ScreenEvent.offScreen(event));

    _currentRouteSettings = null;

    super.unmount();
  }

  @override
  Element get webFElement => _webfElement;
}

class PositionPlaceHolder extends flutter.SingleChildRenderObjectWidget {
  final Element positionedElement;
  final Element selfElement;

  const PositionPlaceHolder(this.positionedElement, this.selfElement, {super.key}) : super();

  @override
  RenderObject createRenderObject(flutter.BuildContext context) {
    return RenderPositionPlaceholder(preferredSize: Size.zero);
  }

  @override
  flutter.SingleChildRenderObjectElement createElement() {
    return _PositionedPlaceHolderElement(this);
  }
}

class _PositionedPlaceHolderElement extends flutter.SingleChildRenderObjectElement {
  _PositionedPlaceHolderElement(super.widget);

  @override
  PositionPlaceHolder get widget => super.widget as PositionPlaceHolder;

  @override
  void mount(flutter.Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
    widget.selfElement.positionHolderElements.add(this);
    // If the positioned element's renderObject is already mounted (e.g., attached
    // under its containing block earlier in this frame), connect the placeholder now.
    final RenderBoxModel? rbm = widget.positionedElement.renderStyle.attachedRenderBoxModel;
    if (rbm != null) {
      rbm.renderPositionPlaceholder = renderObject as RenderPositionPlaceholder;
      (renderObject as RenderPositionPlaceholder).positioned = rbm;
      try {
        PositionedLayoutLog.log(
          impl: PositionedImpl.build,
          feature: PositionedFeature.wiring,
          message: () => 'mount placeholder for <${widget.positionedElement.tagName.toLowerCase()}>'
              ' in <${widget.selfElement.tagName.toLowerCase()}>',
        );
      } catch (_) {}
    }
  }

  @override
  void unmount() {
    widget.selfElement.positionHolderElements.remove(this);

    // Remove the reference for this in paired render box model.
    RenderBoxModel? pairedRenderBoxModel = widget.positionedElement.renderStyle.attachedRenderBoxModel;
    if (pairedRenderBoxModel?.renderPositionPlaceholder == renderObject) {
      pairedRenderBoxModel?.renderPositionPlaceholder = null;
    }
    try {
      PositionedLayoutLog.log(
        impl: PositionedImpl.build,
        feature: PositionedFeature.wiring,
        message: () => 'unmount placeholder for <${widget.positionedElement.tagName.toLowerCase()}>'
            ' from <${widget.selfElement.tagName.toLowerCase()}>',
      );
    } catch (_) {}

    super.unmount();
  }
}
