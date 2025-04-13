import 'package:flutter/cupertino.dart';
import 'package:webf/dom.dart' as dom;
import 'package:webf/webf.dart';
import 'package:collection/collection.dart';

// Element class
class FlutterCupertinoListTile extends WidgetElement {
  FlutterCupertinoListTile(super.context);

  bool _notched = false;
  bool _showChevron = false;

  @override
  void initializeAttributes(Map<String, ElementAttributeProperty> attributes) {
    super.initializeAttributes(attributes);
    attributes['notched'] = ElementAttributeProperty(
      getter: () => _notched.toString(),
      setter: (value) {
        _notched = value == 'true';
        state?.setState(() {}); 
      }
    );
    attributes['show-chevron'] = ElementAttributeProperty(
      getter: () => _showChevron.toString(),
      setter: (value) {
        _showChevron = value == 'true';
        state?.setState(() {});
      }
    );
    // Note: padding, background colors, leading size/spacing handled by Flutter defaults for now.
  }

  bool get isNotched => _notched;
  bool get shouldShowChevron => _showChevron;

  @override
  FlutterCupertinoListTileState createState() => FlutterCupertinoListTileState(this);

  @override
  FlutterCupertinoListTileState? get state => super.state as FlutterCupertinoListTileState?;
}

// State class
class FlutterCupertinoListTileState extends WebFWidgetElementState {
  FlutterCupertinoListTileState(super.widgetElement);

  @override
  FlutterCupertinoListTile get widgetElement => super.widgetElement as FlutterCupertinoListTile;

  // --- Slot Helper --- 
  Widget? _getChildBySlotName(String name) {
    final slotNode = widgetElement.childNodes.firstWhereOrNull((node) {
      if (node is dom.Element) {
        return node.getAttribute('slotName') == name;
      }
      return false;
    });
    return slotNode?.toWidget();
  }

  // Title is the default slot (first element without slotName)
  Widget? _getDefaultChild() {
    final defaultSlotNode = widgetElement.childNodes.firstWhereOrNull((node) {
       if (node is dom.Element) {
        return node.getAttribute('slotName') == null;
      }
      // Allow simple text as title
      if (node is dom.TextNode && node.data.trim().isNotEmpty) {
        return true;
      }
      return false;
    });
    // Wrap TextNode in a Text widget if found
     if (defaultSlotNode is dom.TextNode) {
       return Text(defaultSlotNode.data);
     }
    return defaultSlotNode?.toWidget();
  }
  // --- End Slot Helper ---

  // --- Event Handling --- 
  bool _isTapped = false;

  void _handleTap() {
    setState(() {
      _isTapped = true;
    });
    // Dispatch standard 'click' event
    widgetElement.dispatchEvent(Event(EVENT_CLICK));
    
    // Simulate tap animation (reset after a short delay)
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) { // Check if the widget is still in the tree
        setState(() {
          _isTapped = false;
        });
      }
    });
  }
  // --- End Event Handling ---

  @override
  Widget build(BuildContext context) {
    Widget? leadingWidget = _getChildBySlotName('leading');
    Widget? titleWidget = _getDefaultChild(); // Required
    Widget? subtitleWidget = _getChildBySlotName('subtitle');
    Widget? additionalInfoWidget = _getChildBySlotName('additionalInfo');
    Widget? trailingWidget = _getChildBySlotName('trailing');

    // Default to showing chevron if attribute is set and no trailing slot is provided
    if (trailingWidget == null && widgetElement.shouldShowChevron) {
      trailingWidget = const CupertinoListTileChevron();
    }

    // Build the actual list tile widget
    Widget listTileWidget;
    if (widgetElement.isNotched) {
      listTileWidget = CupertinoListTile.notched(
        key: ObjectKey(widgetElement),
        title: titleWidget ?? const SizedBox(),
        subtitle: subtitleWidget,
        additionalInfo: additionalInfoWidget,
        leading: leadingWidget,
        trailing: trailingWidget,
        onTap: _handleTap,
      );
    } else {
      listTileWidget = CupertinoListTile(
        key: ObjectKey(widgetElement),
        title: titleWidget ?? const SizedBox(),
        subtitle: subtitleWidget,
        additionalInfo: additionalInfoWidget,
        leading: leadingWidget,
        trailing: trailingWidget,
        onTap: _handleTap,
      );
    }

    // *** Wrap in Column with MainAxisSize.min to constrain height ***
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [listTileWidget],
    );
    // *************************************************************
  }
}
