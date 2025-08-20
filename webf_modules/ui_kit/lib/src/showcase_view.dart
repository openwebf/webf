/*
 * Copyright (C) 2024 The OpenWebF(Cayman) Company . All rights reserved.
 */

import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:webf/webf.dart';
import 'package:webf/dom.dart' as dom;
import 'package:collection/collection.dart';

/// ShowCaseView component with on/off control and custom description slot
class FlutterShowCaseView extends WidgetElement {
  FlutterShowCaseView(super.context);

  final GlobalKey _one = GlobalKey();
  bool _isShowing = false; // Control whether the showcase is being displayed
  bool _disableBarrierInteraction = false; // Whether to disable background click interaction
  String _tooltipPosition = ''; // Tooltip position

  void startShowcase() {
    if (_isShowing) return;
    _isShowing = true;
    // Request State to start displaying
    state?.requestStartShowcase(); 
  }

  void dismissShowcase() {
    if (!_isShowing) return;
    _isShowing = false;
    // Directly trigger State rebuild, remove ShowCaseWidget
    state?.requestUpdateState(); 
  }
  
  @override
  void initializeAttributes(Map<String, ElementAttributeProperty> attributes) {
    super.initializeAttributes(attributes);
    
    // Set whether to disable background click interaction
    attributes['disableBarrierInteraction'] = ElementAttributeProperty(
      getter: () => _disableBarrierInteraction.toString(),
      setter: (value) {
        _disableBarrierInteraction = value != 'false';
      }
    );
    
    // Set tooltip position
    attributes['tooltipPosition'] = ElementAttributeProperty(
      getter: () => _tooltipPosition,
      setter: (value) {
        _tooltipPosition = value;
      }
    );
  }
  
  // Define static method mapping for frontend calls
  static StaticDefinedSyncBindingObjectMethodMap showcaseSyncMethods = {
    'start': StaticDefinedSyncBindingObjectMethod(
      call: (element, args) {
        final showcaseView = castToType<FlutterShowCaseView>(element);
        showcaseView.startShowcase();
        return null; // Synchronous methods typically return null or simple types
      },
    ),
    'dismiss': StaticDefinedSyncBindingObjectMethod(
      call: (element, args) {
        final showcaseView = castToType<FlutterShowCaseView>(element);
        showcaseView.dismissShowcase();
        return null;
      },
    ),
  };

  @override
  List<StaticDefinedSyncBindingObjectMethodMap> get methods => [
        ...super.methods,
        showcaseSyncMethods,
      ];

  @override
  FlutterShowCaseViewState? get state => super.state as FlutterShowCaseViewState?;
  
  @override
  WebFWidgetElementState createState() {
    return FlutterShowCaseViewState(this);
  }

  // Handle tooltipPosition parameter
  dynamic getTooltipPosition(BuildContext context, GlobalKey targetKey) {
    // If user explicitly sets a position, prioritize user settings
    if (_tooltipPosition.isNotEmpty) {
      switch (_tooltipPosition.toLowerCase()) {
        case 'top':
          return TooltipPosition.top;
        case 'bottom':
          return TooltipPosition.bottom;
        default:
          // Not a valid position, use automatic judgment
          break;
      }
    }

    // Automatically determine the best position
    // Get the position information of the target element
    final RenderBox? renderBox = targetKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return null; // Target not yet rendered, return null to let ShowcaseView use default position

    // Get screen size
    final Size screenSize = MediaQuery.of(context).size;
    
    // Get the position of the target element on the screen
    final Offset targetPosition = renderBox.localToGlobal(Offset.zero);
    final Size targetSize = renderBox.size;
    
    // Calculate the Y coordinate of the center point of the target element
    final double targetCenterY = targetPosition.dy + targetSize.height / 2;
    
    // Calculate the Y coordinate of the center point of the screen
    final double screenCenterY = screenSize.height / 2;
    
    // If the target is in the upper half of the screen, the tooltip is displayed below; if in the lower half, displayed above
    if (targetCenterY < screenCenterY) {
      return TooltipPosition.bottom;
    } else {
      return TooltipPosition.top;
    }
  }
}

class FlutterShowCaseViewState extends WebFWidgetElementState {
  FlutterShowCaseViewState(super.widgetElement);
  
  bool _startRequested = false; // Mark whether to start showcase

  void requestStartShowcase() {
    _startRequested = true;
    requestUpdateState();
  }

  @override
  FlutterShowCaseView get widgetElement => super.widgetElement as FlutterShowCaseView;

  // Get the first child element without slotName as the highlight target
  Widget _getTargetChildWidget() {
    final targetNode = widgetElement.childNodes.firstWhereOrNull((node) {
      if (node is dom.Element) {
        return node.getAttribute('slotName') == null;
      }
      return true; // Allow non-Element nodes such as TextNode as targets
    });
    return targetNode?.toWidget() ?? const SizedBox(); // If not found, return an empty box
  }


  // Get child elements of type FlutterShowCaseDescription
  dom.Element? _getShowCaseDescriptionNode() {
    final descriptionNode = widgetElement.childNodes.firstWhereOrNull((node) {
      if (node is FlutterShowCaseDescription) {
        return true;
      }
      return false;
    });
    return descriptionNode as dom.Element?;
  }


  @override
  Widget build(BuildContext context) {
    Widget targetChildWidget = _getTargetChildWidget();

    // Only build ShowCaseWidget when _isShowing is true
    if (!widgetElement._isShowing) {
      _startRequested = false; // Reset request state
      // Return the target child element, but do not wrap ShowCaseWidget
      return targetChildWidget;
    }

    // Use ShowCaseWidget to wrap content
    return ShowCaseWidget(
      // onFinish callback, update state when showcase is completed
      onFinish: () {
        if (widgetElement._isShowing) { 
          widgetElement._isShowing = false;
          widgetElement.dispatchEvent(Event('finish'));
          requestUpdateState(); 
        }
      },
      disableBarrierInteraction: widgetElement._disableBarrierInteraction, // Use user-set value

      builder: (context) { // This context is the downstream context of ShowCaseWidget
        if (_startRequested) {
           WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) { 
              ShowCaseWidget.of(context).startShowCase([widgetElement._one]);
              WidgetsBinding.instance.addPostFrameCallback((_) { 
                  if(mounted) { 
                      _startRequested = false;
                  }
              });
            }
          });
        }

        // Get custom description slot
        dom.Element? showCaseDescriptionNode = _getShowCaseDescriptionNode();
        Widget? descriptionWidget = showCaseDescriptionNode?.toWidget();

        // Get the best tooltip position
        dynamic tooltipPosition = widgetElement.getTooltipPosition(context, widgetElement._one);

        // If there is a custom description, use Showcase.withWidget
        if (descriptionWidget != null) {
          // Get current screen width
          final screenWidth = MediaQuery.of(context).size.width;
            
          return Showcase.withWidget(
            disableBarrierInteraction: widgetElement._disableBarrierInteraction, // Use user-set value
            key: widgetElement._one,
            height: 0,
            width: screenWidth * 0.9, // Screen width minus some margin
            container: descriptionWidget,
            child: targetChildWidget, // Highlight target
            disableDefaultTargetGestures: false,
            disposeOnTap: false,
            tooltipPosition: tooltipPosition, // Set tooltip position
          );
        } else {
          return Showcase(
            key: widgetElement._one,
            disableBarrierInteraction: widgetElement._disableBarrierInteraction, // Use user-set value
            description: '',
            child: targetChildWidget,
            tooltipPosition: tooltipPosition, // Set tooltip position
          );
        }
      },
      blurValue: 0.5,
    );
  }
}

class FlutterShowCaseItem extends WidgetElement {
  FlutterShowCaseItem(super.context);

  @override
  FlutterShowCaseItemState createState() {
    return FlutterShowCaseItemState(this);
  }
}

class FlutterShowCaseItemState extends WebFWidgetElementState {
  FlutterShowCaseItemState(super.widgetElement);

  @override
  FlutterShowCaseItem get widgetElement => super.widgetElement as FlutterShowCaseItem;

  @override
  Widget build(BuildContext context) {
    return widgetElement.childNodes.first.toWidget();
  }
}


class FlutterShowCaseDescription extends WidgetElement {
  FlutterShowCaseDescription(super.context);

  @override
  FlutterShowCaseDescriptionState createState() {
    return FlutterShowCaseDescriptionState(this);
  }
}

class FlutterShowCaseDescriptionState extends WebFWidgetElementState {
  FlutterShowCaseDescriptionState(super.widgetElement);

  @override
  FlutterShowCaseDescription get widgetElement => super.widgetElement as FlutterShowCaseDescription;

  @override
  Widget build(BuildContext context) {
    return widgetElement.childNodes.first.toWidget();
  }
}