import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class PopupTitleWidget extends StatelessWidget {
  final String title;
  final bool isCenterTitle;
  final bool showClose;
  final bool showBack;

  /// 关闭按钮回调, 若为空, 则默认关闭弹窗, 否则需要调用方关闭弹窗
  Function? onClose;

  /// 返回按钮回调, 若为空, 则默认关闭弹窗, 否则需要调用方关闭弹窗
  Function? onBack;
  bool showDivider = true;
  bool showDragLine = false;

  // ignore: use_key_in_widget_constructors
  PopupTitleWidget(
      {required this.title,
      required this.isCenterTitle,
      required this.showClose,
      this.showDragLine = false,
      this.showBack = false,
      this.onClose,
      this.onBack,
      this.showDivider = true});

  @override
  Widget build(BuildContext context) {
    if (title.isEmpty) {
      return _buildDragLine(context);
    }
    if (showBack) {
      return _buildBackTitle(context);
    }
    if (isCenterTitle) {
      return _buildCenterTitle();
    }
    return _buildNormalTitle(context);
  }

  Widget _buildCenterTitle() {
    if (showClose) {
      return Builder(builder: (context) {
        return Column(
          children: [
            _buildDragLine(context),
            Container(
                height: 56,
                padding: const EdgeInsets.all(15),
                child: Row(
                  children: [
                    Container(
                      color: Colors.transparent,
                      width: 20,
                      height: 20,
                    ),
                    Expanded(
                      child: Center(
                        child: AutoSizeText(
                          minFontSize: 14,
                          maxFontSize: 18,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          title,
                          style: TextStyle(
                            // color: getColor(context, MexcColorToken.contentPrimary),
                            fontSize: 18,
                            // fontWeight: UIDesign.uiBold,
                            // fontFamily: fontFamily()
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (onClose == null) {
                          Navigator.of(context).pop();
                        } else {
                          onClose?.call();
                        }
                      },
                      child: Icon(Icons.close),
                    )
                  ],
                )),
            Visibility(
                visible: showDivider,
                child: Container(
                  // color: getColor(context, MexcColorToken.lineBase),
                  height: 1,
                )),
          ],
        );
      });
    } else {
      return Builder(builder: (context) {
        return Column(
          children: [
            Container(
                height: 56,
                padding: const EdgeInsets.all(15),
                child: AutoSizeText(
                  minFontSize: 14,
                  maxFontSize: 18,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  title,
                  style: TextStyle(
                    // color: getColor(context, MexcColorToken.contentPrimary),
                    fontSize: 18,
                    // fontWeight: UIDesign.uiBold,
                    // fontFamily: fontFamily(),
                  ),
                )),
            Visibility(
                visible: showDivider,
                child: Container(
                  // color: getColor(context, MexcColorToken.lineBase),
                  height: 1,
                )),
          ],
        );
      });
    }
  }

  Widget _buildNormalTitle(BuildContext context) {
    return Column(
      children: [
        _buildDragLine(context),
        Container(
            height: 56,
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: AutoSizeText(
                    minFontSize: 14,
                    maxFontSize: 18,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    title,
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      // color: getColor(context, MexcColorToken.contentPrimary),
                      fontSize: 18,
                      // fontWeight: UIDesign.uiBold,
                      // fontFamily: fontFamily()
                    ),
                  ),
                ),
                Visibility(
                  visible: showClose,
                  child: GestureDetector(
                    onTap: () {
                      if (onClose == null) {
                        Navigator.of(context).pop();
                      } else {
                        onClose?.call();
                      }
                    },
                    child: Icon(Icons.close),
                  ),
                )
              ],
            )),
        Visibility(
            visible: showDivider,
            child: Container(
              // color: getColor(context, MexcColorToken.lineBase),
              height: 1,
            )),
      ],
    );
  }

  Widget _buildBackTitle(BuildContext context) {
    return Column(
      children: [
        _buildDragLine(context),
        Container(
          height: 56,
          padding: const EdgeInsets.only(left: 15, right: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  if (onBack == null) {
                    Navigator.of(context).pop();
                  } else {
                    onBack?.call();
                  }
                },
                child: _transformWidget(
                  Icon(Icons.arrow_back),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: AutoSizeText(
                  minFontSize: 14,
                  maxFontSize: 18,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  title,
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                    // color: getColor(context, MexcColorToken.contentPrimary),
                    fontSize: 18,
                    // fontWeight: UIDesign.uiBold,
                    // fontFamily: fontFamily(),
                  ),
                ),
              ),
              Visibility(
                visible: showClose,
                child: GestureDetector(
                  onTap: () {
                    if (onClose == null) {
                      Navigator.of(context).pop();
                    } else {
                      onClose?.call();
                    }
                  },
                  child: Icon(Icons.close),
                ),
              )
            ],
          ),
        ),
        Visibility(
            visible: showDivider,
            child: Container(
              // color: getColor(context, MexcColorToken.lineBase),
              height: 1,
            )),
      ],
    );
  }

  Widget _transformWidget(Widget widget) {
    return widget;
  }

  Widget _buildDragLine(BuildContext context) {
    if (showDragLine) {
      return Container(
        width: 36,
        height: 4,
        margin: const EdgeInsets.only(top: 8, bottom: 8),
        decoration: BoxDecoration(
          // color: getColor(context, MexcColorToken.lineStrong),
          borderRadius: const BorderRadius.all(Radius.circular(2)),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
