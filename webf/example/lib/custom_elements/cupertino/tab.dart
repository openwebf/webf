import 'package:flutter/cupertino.dart';
import 'package:webf/webf.dart';
import 'package:webf/dom.dart' as dom;

class FlutterCupertinoTab extends WidgetElement {
  FlutterCupertinoTab(super.context);
  
  int _currentIndex = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context, ChildNodeList childNodes) {
    final items = childNodes.whereType<dom.Element>().toList(growable: false);
    
    return Column(
      children: [
        SizedBox(
          height: 44,
          child: SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            child: Row(
              children: items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return GestureDetector(
                  onTap: () {
                    _currentIndex = index;
                    dispatchEvent(CustomEvent('change', detail: index));
                    setState(() {});
                  },
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: _currentIndex == index 
                        ? FontWeight.w600 
                        : FontWeight.w400,
                      color: _currentIndex == index 
                        ? CupertinoTheme.of(context).primaryColor
                        : CupertinoColors.label.resolveFrom(context).withAlpha(128),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      alignment: Alignment.center,
                      child: Text(item.getAttribute('title') ?? ''),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        Expanded(
          child: items.isEmpty 
            ? const SizedBox() 
            : items[_currentIndex].toWidget(),
        ),
      ],
    );
  }

  @override
  void initializeMethods(Map<String, BindingObjectMethod> methods) {
    super.initializeMethods(methods);

    methods['switchTab'] = BindingObjectMethodSync(call: (args) {
      if (args.isEmpty) return;
      final index = int.tryParse(args[0].toString());
      if (index != null) {
        _currentIndex = index;
        setState(() {});
        dispatchEvent(CustomEvent('change', detail: index));
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

class FlutterCupertinoTabItem extends WidgetElement {
  FlutterCupertinoTabItem(super.context);

  @override
  Widget build(BuildContext context, ChildNodeList childNodes) {
    return WebFHTMLElement(
      tagName: 'DIV',
      parentElement: this,
      controller: ownerDocument.controller,
      children: childNodes.toWidgetList(),
    );
  }
}