import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:webf/webf.dart';

class FlutterCupertinoTextArea extends WidgetElement {
  FlutterCupertinoTextArea(super.context) {
    _controller.addListener(_handleTextChange);
  }
  
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initializeAttributes(Map<String, ElementAttributeProperty> attributes) {
    super.initializeAttributes(attributes);
    
    attributes['val'] = ElementAttributeProperty(
      getter: () => _controller.text,
      setter: (value) {
        if (value != _controller.text) {
          _controller.text = value;
          setState(() {});
        }
      }
    );

    attributes['placeholder'] = ElementAttributeProperty(
      getter: () => _placeholder,
      setter: (value) {
        _placeholder = value;
        setState(() {});
      }
    );

    attributes['disabled'] = ElementAttributeProperty(
      getter: () => _disabled.toString(),
      setter: (value) {
        _disabled = value == 'true';
        setState(() {});
      }
    );

    attributes['readonly'] = ElementAttributeProperty(
      getter: () => _readOnly.toString(),
      setter: (value) {
        _readOnly = value == 'true';
        setState(() {});
      }
    );

    attributes['maxLength'] = ElementAttributeProperty(
      getter: () => _maxLength?.toString() ?? '',
      setter: (value) {
        _maxLength = int.tryParse(value);
        setState(() {});
      }
    );

    attributes['rows'] = ElementAttributeProperty(
      getter: () => _rows.toString(),
      setter: (value) {
        _rows = int.tryParse(value) ?? 2;
        setState(() {});
      }
    );

    attributes['showCount'] = ElementAttributeProperty(
      getter: () => _showCount.toString(),
      setter: (value) {
        _showCount = value == 'true';
        setState(() {});
      }
    );

    attributes['autoSize'] = ElementAttributeProperty(
      getter: () => _autoSize.toString(),
      setter: (value) {
        _autoSize = value == 'true';
        setState(() {});
      }
    );
  }

  String _placeholder = '';
  bool _disabled = false;
  bool _readOnly = false;
  int? _maxLength;
  int _rows = 2;
  bool _showCount = false;
  bool _autoSize = false;

  void _handleTextChange() {
    if (_showCount && _maxLength != null) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context, ChildNodeList childNodes) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: 0,
        maxHeight: _autoSize ? double.infinity : (_rows * 24.0 + 16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CupertinoTextField(
            controller: _controller,
            focusNode: _focusNode,
            enabled: !_disabled,
            readOnly: _readOnly,
            maxLines: _autoSize ? null : _rows,
            minLines: _rows,
            maxLength: _showCount ? null : _maxLength,
            keyboardType: TextInputType.multiline,
            textAlign: renderStyle.textAlign,
            textAlignVertical: TextAlignVertical.top,
            style: TextStyle(
              color: renderStyle.color.value,
              fontSize: renderStyle.fontSize.value,
              fontWeight: renderStyle.fontWeight,
              height: 1.2,
            ),
            placeholder: _placeholder,
            placeholderStyle: TextStyle(
              color: CupertinoColors.placeholderText,
              fontSize: renderStyle.fontSize.value,
              height: 1.2,
            ),
            decoration: BoxDecoration(
              color: _disabled 
                  ? CupertinoColors.systemGrey6 
                  : CupertinoColors.white,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            onChanged: (value) {
              dispatchEvent(CustomEvent('input', detail: value));
            },
            onEditingComplete: () {
              dispatchEvent(Event('complete'));
            },
          ),
          if (_showCount && _maxLength != null)
            Padding(
              padding: const EdgeInsets.only(top: 4, right: 12),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${_controller.text.length}/$_maxLength',
                  style: TextStyle(
                    color: CupertinoColors.systemGrey,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void initializeMethods(Map<String, BindingObjectMethod> methods) {
    super.initializeMethods(methods);

    methods['focus'] = BindingObjectMethodSync(call: (args) {
      _focusNode.requestFocus();
    });

    methods['blur'] = BindingObjectMethodSync(call: (args) {
      _focusNode.unfocus();
    });

    methods['clear'] = BindingObjectMethodSync(call: (args) {
      _controller.clear();
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_handleTextChange);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}