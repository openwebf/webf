import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show RefreshIndicator;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:webf/src/css/position.dart';
import 'package:webf/webf.dart';
import 'package:webf/rendering.dart';
import 'package:webf/dom.dart' as dom;

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

  @override
  set scrollControllerX(ScrollController? value) {
    if (scrollDirection == Axis.horizontal) {
      _scrollController = null;
    }
  }

  @override
  ScrollController? get scrollControllerY {
    return scrollDirection == Axis.vertical ? _scrollController : null;
  }
  @override
  set scrollControllerY(ScrollController? value) {
    if (scrollDirection == Axis.vertical) {
      _scrollController = value;
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
      if (position.extentAfter < 50 && !_isLoadingMore && hasEventListener('loadmore')) {
        _isLoadingMore = true;
        dispatchEvent(dom.Event('loadmore'));
        setState(() {}); 
        Future.delayed(const Duration(milliseconds: 2000), () {
          if (mounted) {
            _isLoadingMore = false;
            setState(() {});
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
    _scrollController?.dispose();
    _scrollController = null;
    super.stateDispose();
  }

  @override
  Widget build(BuildContext context, ChildNodeList childNodes) {
    final isCupertinoPlatform = defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS;
    
    Widget scrollView = CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      scrollDirection: scrollDirection,
      slivers: [
        if (isCupertinoPlatform)
          CupertinoSliverRefreshControl(
            onRefresh: () async {
              if (hasEventListener('refresh')) {
                dispatchEvent(dom.Event('refresh'));
                await Future.delayed(const Duration(seconds: 2));
              }
            },
          ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              if (index == childNodes.length) {
                return hasEventListener('loadmore') ? Container(
                  height: 50,
                  alignment: Alignment.center,
                  child: _isLoadingMore ? const CupertinoActivityIndicator() : const SizedBox.shrink(),
                ) : const SizedBox.shrink();
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
    );

    return WebFChildNodeSize(
      ownerElement: this,
      child: isCupertinoPlatform 
        ? scrollView 
        : RefreshIndicator(
            onRefresh: () async {
              if (hasEventListener('refresh')) {
                dispatchEvent(dom.Event('refresh'));
                await Future.delayed(const Duration(seconds: 2));
              }
            },
            child: scrollView,
          ),
    );
  }

  void completeLoadMore() {
    _isLoadingMore = false;
    setState(() {});
  }
}
