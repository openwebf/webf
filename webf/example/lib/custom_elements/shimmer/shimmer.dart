/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU AGPL with Enterprise exception.
 */
import 'package:flutter/material.dart';
import 'package:webf/webf.dart';
import 'shimmer_widget.dart';
import 'shimmer_loading.dart';

class FlutterShimmerElement extends WidgetElement {
  FlutterShimmerElement(BindingContext? context) : super(context);

  @override
  WebFWidgetElementState createState() {
    return FlutterShimerElementState(this);
  }
}

class FlutterShimerElementState extends WebFWidgetElementState {
  FlutterShimerElementState(super.widgetElement);

  // 定义渐变色，可以通过属性配置
  final LinearGradient _shimmerGradient = LinearGradient(
    colors: [
      Color(0xFFEBEBF4),
      Color(0xFFF4F4F4),
      Color(0xFFEBEBF4),
    ],
    stops: [0.1, 0.3, 0.4],
    begin: Alignment(-1.0, -0.3),
    end: Alignment(1.0, 0.3),
    tileMode: TileMode.clamp,
  );

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      linearGradient: _shimmerGradient,
      child: ShimmerLoading(
        isLoading: true, // 这里可以通过属性控制
        child: widgetElement.childNodes.isEmpty ? const SizedBox() : widgetElement.childNodes.first.toWidget(),
      ),
    );
  }
}
