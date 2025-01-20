import 'package:flutter/material.dart';
import 'package:webf/webf.dart';

class FlutterSearch extends WidgetElement {
  FlutterSearch(super.context);

  final TextEditingController _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _hasText = _controller.text.isNotEmpty;
      });
    });
  }

  @override
  Widget build(BuildContext context, ChildNodeList childNodes) {
    return Container(
      child: TextField(
        maxLines: 1,
        controller: _controller,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          suffixIcon: _hasText
              ? IconButton(
            icon: Icon(Icons.clear, color: Colors.grey),
            onPressed: () {
              _controller.clear(); // Clear the input
            },
          )
              : null,
          // Search icon
          hintText: '搜索币种',
          // Placeholder text
          hintStyle: TextStyle(color: Colors.grey, fontSize: 12),
          // Placeholder text color
          border: OutlineInputBorder(
            borderRadius: renderStyle.borderRadius != null
                ? BorderRadius.only(
                topLeft: renderStyle.borderRadius![0],
                topRight: renderStyle.borderRadius![1],
                bottomRight: renderStyle.borderRadius![2],
              bottomLeft: renderStyle.borderRadius![3]
            ) : BorderRadius.zero,
            borderSide: BorderSide.none, // No default border
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: renderStyle.borderRadius != null
                ? BorderRadius.only(
                topLeft: renderStyle.borderRadius![0],
                topRight: renderStyle.borderRadius![1],
                bottomRight: renderStyle.borderRadius![2],
                bottomLeft: renderStyle.borderRadius![3]
            ) : BorderRadius.zero, // Rounded corners
            borderSide: BorderSide(color: Colors.blue, width: 1.0), // Outline when focused
          ),
          // No underline or border
          contentPadding: EdgeInsets.symmetric(vertical: 12.0), // Vertical padding
        ),
        style: TextStyle(
            overflow: TextOverflow.visible,
            fontSize: renderStyle.fontSize.computedValue), // Handles text overflow gracefully
      ),
    );
  }
}
