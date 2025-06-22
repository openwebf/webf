import 'package:flutter/material.dart';
import 'popup_title.dart';

enum PopupDirection { left, right, top, bottom }

class PopupView extends StatefulWidget {
  final String title;
  final bool showClose;
  final bool showBack;
  final String leftButtonText;
  final String rightButtonText;
  final Widget? content;
  final Function? onLeftButtonPressed;
  final Function? onRightButtonPressed;
  final Function? onClosePressed;
  final PopupDirection direction;
  final bool isCenterTitle;
  final bool isVerticalButton;
  final double? heightFactor;
  final bool? contentScrollable;
  final bool? buttonPressDismiss;
  final String? bgColorToken;
  final double contentHorizontalPadding;
  final bool showDragLine;
  final bool? showDivider;
  final bool leftButtonEnable;
  final bool rightButtonEnable;
  final List<double>? presetFontSizes;

  const PopupView({
    super.key,
    this.title = '',
    this.showClose = true,
    this.showBack = false,
    this.leftButtonText = '',
    this.rightButtonText = '',
    this.content,
    this.onLeftButtonPressed,
    this.onRightButtonPressed,
    this.onClosePressed,
    this.direction = PopupDirection.left,
    this.isCenterTitle = false,
    this.isVerticalButton = false,
    this.heightFactor = 0.72,
    this.contentScrollable = true,
    this.buttonPressDismiss = true,
    this.presetFontSizes,
    this.bgColorToken,
    this.contentHorizontalPadding = 16,
    this.showDragLine = false,
    this.showDivider,
    this.leftButtonEnable = true,
    this.rightButtonEnable = true,
  });

  @override
  State<PopupView> createState() => PopupViewState();
}

class PopupViewState extends State<PopupView> {
  late bool _leftButtonEnable;
  late bool _rightButtonEnable;

  @override
  void initState() {
    super.initState();
    _leftButtonEnable = widget.leftButtonEnable;
    _rightButtonEnable = widget.rightButtonEnable;
  }

  void updateLeftButtonEnable(bool enable) {
    setState(() {
      _leftButtonEnable = enable;
    });
  }

  void updateRightButtonEnable(bool enable) {
    setState(() {
      _rightButtonEnable = enable;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      // color: getColor(context, widget.bgColorToken ?? MexcColorToken.fillElevationHigh),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTitle(context),
          _buildContent(context),
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return PopupTitleWidget(
      title: widget.title,
      isCenterTitle: widget.isCenterTitle,
      showClose: widget.showClose,
      onClose: widget.onClosePressed,
      showBack: widget.showBack,
      showDragLine: widget.showDragLine,
      showDivider: widget.showDivider ?? true,
    );
  }

  Widget _buildContent(BuildContext context) {
    double paddingBottom = 8;
    if (widget.title.isEmpty) {
      paddingBottom = 16;
    }
    switch (widget.direction) {
      case PopupDirection.bottom:
        double screenHeight = MediaQuery.of(context).size.height;
        double bottom = MediaQuery.of(context).padding.bottom;

        Widget contentWidget = widget.content ?? Container();

        return _buildTBContent(contentWidget, paddingBottom, screenHeight - bottom);
      default:
        return Container();
    }
  }

  Widget _buildTBContent(Widget contentWidget, double paddingBottom, double screenHeight) {
    return Container(
      margin: EdgeInsets.only(
        top: 16,
        left: widget.contentHorizontalPadding,
        right: widget.contentHorizontalPadding,
        bottom: paddingBottom,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: screenHeight * (widget.heightFactor ?? 0.72)),
        child: contentWidget,
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    double bottom = MediaQuery.of(context).padding.bottom;
    if (bottom < 24) {
      bottom = 24;
    }

    if (widget.leftButtonText.isEmpty && widget.rightButtonText.isEmpty) {
      return Container();
    }
    if (widget.isVerticalButton) {
      return Container(
        padding: EdgeInsets.only(bottom: bottom, left: 15, right: 15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildButtonTop(context),
            _buildButtonDivider(),
            _buildButtonBottom(context),
          ],
        ),
      );
    } else {
      return Container(
        padding: EdgeInsets.only(bottom: bottom, left: 15, right: 15),
        child: Row(
          children: [
            _buildButtonLeft(context),
            _buildButtonDivider(),
            _buildButtonRight(context),
          ],
        ),
      );
    }
  }

  Widget _buildButtonBottom(BuildContext context) {
    if (widget.leftButtonText.isEmpty) {
      return Container();
    }

    return TextButton(
        onPressed: () {
          if (widget.buttonPressDismiss ?? false) {
            Navigator.of(context).pop();
          }
          widget.onLeftButtonPressed?.call();
        },
        child: Text(widget.leftButtonText));
  }

  Widget _buildButtonTop(BuildContext context) {
    if (widget.rightButtonText.isEmpty) {
      return Container();
    }

    return TextButton(
        onPressed: () {
          if (widget.buttonPressDismiss ?? false) {
            Navigator.of(context).pop();
          }
          widget.onRightButtonPressed?.call();
        },
        child: Text(widget.rightButtonText));

    // return MGButton(
    //   onPressed: () {
    //     if (widget.buttonPressDismiss ?? false) {
    //       Navigator.of(context).pop();
    //     }
    //     widget.onRightButtonPressed?.call();
    //   },
    //   enable: _rightButtonEnable,
    //   text: widget.rightButtonText,
    //   isExpand: true,
    //   presetFontSizes: widget.presetFontSizes,
    // );
  }

  Widget _buildButtonLeft(BuildContext context) {
    if (widget.leftButtonText.isEmpty) {
      return Container();
    }
    return Expanded(
        child: TextButton(
            onPressed: () {
              if (widget.buttonPressDismiss ?? false) {
                Navigator.of(context).pop();
              }
              widget.onLeftButtonPressed?.call();
            },
            child: Text(
              widget.leftButtonText,
            )));
  }

  Widget _buildButtonRight(BuildContext context) {
    if (widget.rightButtonText.isEmpty) {
      return Container();
    }

    return Expanded(
        child: TextButton(
            onPressed: () {
              if (widget.buttonPressDismiss ?? false) {
                Navigator.of(context).pop();
              }
              widget.onRightButtonPressed?.call();
            },
            child: Text(widget.rightButtonText)));
  }

  Widget _buildButtonDivider() {
    if (widget.leftButtonText.isNotEmpty && widget.rightButtonText.isNotEmpty) {
      if (widget.isVerticalButton) {
        return const SizedBox(height: 12);
      } else {
        return const SizedBox(width: 12);
      }
    } else {
      return Container();
    }
  }
}
