import 'package:flutter/material.dart';
import 'package:test_popup/popup_view.dart';

///从下到上弹窗
Future<T?> showBottom<T>(
  BuildContext context, {
  String title = "",
  bool showClose = true,
  bool showBack = false,
  Widget? content,
  String leftButtonText = "",
  String rightButtonText = "",
  Function? onLeftButtonPressed,
  Function? onRightButtonPressed,
  Function? onClosePressed,
  Function? onDismiss,
  Function(BuildContext context)? popupContext,
  bool isCenterTitle = false,
  bool isVerticalButton = false,
  double? heightFactor,
  bool contentScrollable = true,
  bool buttonPressDismiss = false,
  bool leftButtonEnable = true,
  bool rightButtonEnable = true,
  bool isDismissible = true,
  bool enableDrag = true,
  bool showDragLine = false,
  bool? showDivider,
  String? bgColorToken,
  List<double>? presetFontSizes,
  double contentHorizontalPadding = 16,
  double radius = 10,
  bool? isScrollControlled,
  Key? popupKey,
}) {
  return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: isScrollControlled ?? true,
      useSafeArea: true,
      // barrierColor: getColor(context, MexcColorToken.bgScrim),
      builder: (context) {
        popupContext?.call(context);
        return SingleChildScrollView(
          child: AnimatedPadding(
            padding: MediaQuery.of(context).viewInsets,
            duration: const Duration(milliseconds: 100),
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(radius),
                topLeft: Radius.circular(radius),
              ),
              child: PopupView(
                key: popupKey,
                title: title,
                showClose: showClose,
                showBack: showBack,
                content: content,
                bgColorToken: bgColorToken,
                leftButtonText: leftButtonText,
                rightButtonText: rightButtonText,
                onLeftButtonPressed: onLeftButtonPressed,
                onRightButtonPressed: onRightButtonPressed,
                direction: PopupDirection.bottom,
                isCenterTitle: isCenterTitle,
                isVerticalButton: isVerticalButton,
                heightFactor: heightFactor,
                onClosePressed: onClosePressed,
                contentScrollable: contentScrollable,
                buttonPressDismiss: buttonPressDismiss,
                presetFontSizes: presetFontSizes,
                contentHorizontalPadding: contentHorizontalPadding,
                showDragLine: showDragLine,
                showDivider: showDivider,
                leftButtonEnable: leftButtonEnable,
                rightButtonEnable: rightButtonEnable,
              ),
            ),
          ),
        );
      }).then((value) {
    onDismiss?.call();
    return value;
  });
}
