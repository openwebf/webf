import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:webf/webf.dart';
import 'package:flutter/material.dart';

class FlutterCupertinoSearchInput extends WidgetElement {
  FlutterCupertinoSearchInput(super.context);

  @override
  Widget build(BuildContext context, ChildNodeList childNodes) {
    final placeholder = getAttribute('placeholder') ?? 'Search';
    final value = getAttribute('value') ?? '';
    final TextEditingController controller = TextEditingController(text: value);
    
    // Get theme colors
    final theme = CupertinoTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return CupertinoSearchTextField(
      controller: controller,
      placeholder: placeholder,
      onChanged: (value) {
        // Dispatch input event when text changes
        dispatchEvent(CustomEvent('input', detail: value));
      },
      onSubmitted: (value) {
        // Dispatch search event when user submits
        dispatchEvent(CustomEvent('search', detail: value));
      },
      // Use system background color based on theme
      backgroundColor: isDark ? CupertinoColors.systemGrey6.darkColor : CupertinoColors.systemGrey6,
      // Add rounded corners
      borderRadius: BorderRadius.circular(8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      // Style for input text
      style: TextStyle(
        color: isDark ? CupertinoColors.white : CupertinoColors.black,
      ),
      // Style for placeholder text
      placeholderStyle: TextStyle(
        color: isDark ? CupertinoColors.systemGrey : CupertinoColors.systemGrey,
      ),
    );
  }

  @override 
  void initializeMethods(Map<String, BindingObjectMethod> methods) {
    super.initializeMethods(methods);

    // Add getValue method
    methods['getValue'] = BindingObjectMethodSync(call: (args) {
      return getAttribute('value') ?? '';
    });

    // Add setValue method
    methods['setValue'] = BindingObjectMethodSync(call: (args) {
      if (args.isEmpty) return;
      setAttribute('value', args[0].toString());
    });

    // Add focus method
    methods['focus'] = BindingObjectMethodSync(call: (args) {
      // TODO: Implement focus functionality
    });

    // Add blur method  
    methods['blur'] = BindingObjectMethodSync(call: (args) {
      // TODO: Implement blur functionality
    });
  }
}