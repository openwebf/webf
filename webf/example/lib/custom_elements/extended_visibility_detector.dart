// ignore_for_file: use_super_parameters, always_put_required_named_parameters_first

import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

///
class ExtendedVisibilityDetector extends StatefulWidget {
  const ExtendedVisibilityDetector({
    Key? key,
    required this.child,
    required this.uniqueKey,
  }) : super(key: key);

  final Widget child;
  final Key uniqueKey;
  @override
  State<ExtendedVisibilityDetector> createState() =>
      _ExtendedVisibilityDetectorState();

  static VisibilityInfo? of(BuildContext context) {
    return context
        .findAncestorStateOfType<_ExtendedVisibilityDetectorState>()
        ?._visibilityInfo;
  }
}

class _ExtendedVisibilityDetectorState
    extends State<ExtendedVisibilityDetector> {
  VisibilityInfo? _visibilityInfo;
  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: widget.uniqueKey,
      child: widget.child,
      onVisibilityChanged: (VisibilityInfo visibilityInfo) {
        _visibilityInfo = visibilityInfo;
      },
    );
  }
}
