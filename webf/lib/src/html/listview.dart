import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:webf/src/css/position.dart';
import 'package:webf/webf.dart';
import 'package:webf/rendering.dart';
import 'package:webf/dom.dart' as dom;
import 'dart:async';

const LISTVIEW = 'LISTVIEW';
const WEBF_LISTVIEW = 'WEBF-LISTVIEW';

class FlutterListViewElement extends WidgetElement {
  FlutterListViewElement(BindingContext? context) : super(context);

  Axis scrollDirection = Axis.vertical;

  // Control the state of load more
  bool _isLoadingMore = false;


  // Use a dedicated ScrollController to control scrolling
  ScrollController? _scrollController = ScrollController();

  @override
  ScrollController? get scrollControllerX {
    return scrollDirection == Axis.horizontal ? _scrollController : null;
  }

  set scrollControllerX(ScrollController? value) {
    if (scrollDirection == Axis.horizontal) {
      _scrollController = null;
    }
  }

  @override
  ScrollController? get scrollControllerY {
    return scrollDirection == Axis.vertical ? _scrollController : null;
  }
  set scrollControllerY(ScrollController? value) {
    if (scrollDirection == Axis.vertical) {
      _scrollController = null;
    }
  }

  @override
  bool get isScrollingElement => true;

  void _scrollListener() {
    if (!mounted || !(_scrollController?.hasClients == true) || (_scrollController?.positions.isEmpty == true)) {
      return;
    }

    try {
      // Handle load more
      final position = _scrollController!.position;
      if (position.extentAfter < 50 && !_isLoadingMore) {
        _isLoadingMore = true;
        dispatchEvent(dom.Event('loadmore'));

        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) {
            _isLoadingMore = false;
          }
        });
      }

      handleScroll(position.pixels, position.axisDirection);
    } catch (e) {
      return;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scrollController?.addListener(_scrollListener);
  }

  @override
  void stateDispose() {
    _scrollController?.removeListener(_scrollListener);
    super.stateDispose();
  }

  @override
  Widget build(BuildContext context, ChildNodeList childNodes) {
    return WebFChildNodeSize(
      ownerElement: this,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        scrollDirection: scrollDirection,
        slivers: [
          CupertinoSliverRefreshControl(
            onRefresh: () async {
              // Trigger the refresh event
              dispatchEvent(dom.Event('refresh'));

              // Wait for 2 seconds to complete the refresh
              await Future.delayed(const Duration(seconds: 2));
            },
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                if (index == childNodes.length) {
                  return Container(
                    height: 50,
                    alignment: Alignment.center,
                    child: _isLoadingMore
                      ? const CupertinoActivityIndicator()
                      : const SizedBox.shrink(),
                  );
                }

                Node? node = childNodes.elementAt(index);
                if (node is dom.Element) {
                  CSSPositionType positionType = node.renderStyle.position;
                  if (positionType == CSSPositionType.absolute || positionType == CSSPositionType.fixed) {
                    return PositionPlaceHolder(node.holderAttachedPositionedElement!, node);
                  }

                  return LayoutBoxWrapper(ownerElement: node, child: childNodes.elementAt(index).toWidget());
                }
                return node.toWidget();
              },
              childCount: childNodes.length + 1,
            ),
          ),
        ],
      ),
    );
  }

  void completeLoadMore() {
    _isLoadingMore = false;
    setState(() {});
  }
}
