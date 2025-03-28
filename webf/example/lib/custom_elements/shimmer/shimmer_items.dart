import 'package:webf/webf.dart';
import 'package:flutter/material.dart';


class FlutterShimmerAvatarElement extends WidgetElement {
  FlutterShimmerAvatarElement(BindingContext? context) : super(context);

  @override
  Widget build(BuildContext context, _) {
    final width = renderStyle.width?.value ?? 40.0;
    final height = renderStyle.height?.value ?? 40.0;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.black,
        shape: BoxShape.circle,
      ),
    );
  }
}

class FlutterShimmerTextElement extends WidgetElement {
  FlutterShimmerTextElement(BindingContext? context) : super(context);

  @override
  Widget build(BuildContext context, _) {
    final height = renderStyle.height?.value ?? 16.0;

    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

class FlutterShimmerButtonElement extends WidgetElement {
  FlutterShimmerButtonElement(BindingContext? context) : super(context);

  @override
  Widget build(BuildContext context, _) {
    final width = renderStyle.width?.value ?? 
      double.tryParse(attributes['width'] ?? '') ?? 
      80.0;
    
    final height = renderStyle.height?.value ?? 
      double.tryParse(attributes['height'] ?? '') ?? 
      32.0;
    
    final borderRadius = double.tryParse(attributes['radius'] ?? '') ?? 4.0;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}