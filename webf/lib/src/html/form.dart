import 'package:flutter/material.dart';
import 'package:webf/webf.dart';

const INPUT = 'INPUT';
const FORM = 'FORM';

class FlutterFormElementContext extends InheritedWidget {
  FlutterFormElementContext({required Widget child}) : super(child: child);

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return true;
  }
}

class FlutterFormElement extends WidgetElement {
  FlutterFormElement(BindingContext? context) : super(context);

  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a `GlobalKey<FormState>`,
  // not a GlobalKey<MyCustomFormState>.
  // final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, List<Widget> children) {
    return Form(
        child: FlutterFormElementContext(
      child: WebFHTMLElement(tagName: 'DIV', children: children),
    ));
  }
}
