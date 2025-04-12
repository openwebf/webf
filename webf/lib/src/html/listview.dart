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

  @override
  ScrollController? get scrollControllerX {
    return scrollDirection == Axis.horizontal ? _scrollController : null;
  }

  ScrollController? get _scrollController {
    return state?.mounted == true ? state!._scrollController : null;
  }

  @override
  ScrollController? get scrollControllerY {
    return scrollDirection == Axis.vertical ? _scrollController : null;
  }

  @override
  bool get isScrollingElement => true;

  @override
  WebFListViewState? get state => super.state as WebFListViewState?;

  @override
  WebFWidgetElementState createState() {
    return WebFListViewState(this);
  }
}

class WebFListViewState extends WebFWidgetElementState {
  WebFListViewState(super.widgetElement);

  // Use a dedicated ScrollController to control scrolling
  final ScrollController? _scrollController = ScrollController();

  @override
  FlutterListViewElement get widgetElement => super.widgetElement as FlutterListViewElement;

  @override
  void dispose() {
    super.dispose();
    _scrollController?.removeListener(_scrollListener);
    _scrollController?.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scrollController?.addListener(_scrollListener);
  }

  // Control the state of load more
  bool _isLoadingMore = false;

  void _scrollListener() {
    if (!mounted || !(_scrollController?.hasClients == true) || (_scrollController?.positions.isEmpty == true)) {
      return;
    }

    try {
      // Handle load more
      final position = _scrollController!.position;
      if (position.extentAfter < 50 && !_isLoadingMore && widgetElement.hasEventListener('loadmore')) {
        _isLoadingMore = true;
        widgetElement.dispatchEvent(dom.Event('loadmore'));
        setState(() {});
        Future.delayed(const Duration(milliseconds: 2000), () {
          if (mounted) {
            _isLoadingMore = false;
            setState(() {});
          }
        });
      }

      widgetElement.handleScroll(position.pixels, position.axisDirection);
    } catch (e) {
      return;
    }
  }

  void completeLoadMore() {
    _isLoadingMore = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isCupertinoPlatform =
        defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS;

    Widget scrollView = CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      scrollDirection: widgetElement.scrollDirection,
      slivers: [
        if (isCupertinoPlatform)
          CupertinoSliverRefreshControl(
            onRefresh: () async {
              if (widgetElement.hasEventListener('refresh')) {
                widgetElement.dispatchEvent(dom.Event('refresh'));
                await Future.delayed(const Duration(seconds: 2));
              }
            },
          ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              if (index == widgetElement.childNodes.length) {
                return widgetElement.hasEventListener('loadmore')
                    ? Container(
                        height: 50,
                        alignment: Alignment.center,
                        child: _isLoadingMore ? const CupertinoActivityIndicator() : const SizedBox.shrink(),
                      )
                    : const SizedBox.shrink();
              }

              Node? node = widgetElement.childNodes.elementAt(index);
              if (node is dom.Element) {
                CSSPositionType positionType = node.renderStyle.position;
                if (positionType == CSSPositionType.absolute || positionType == CSSPositionType.fixed) {
                  return PositionPlaceHolder(node.holderAttachedPositionedElement!, node);
                }

                return LayoutBoxWrapper(ownerElement: node, child: widgetElement.childNodes.elementAt(index).toWidget());
              }
              return node.toWidget();
            },
            childCount: widgetElement.childNodes.length + 1,
          ),
        ),
      ],
    );

    return WebFChildNodeSize(
      ownerElement: widgetElement,
      child: isCupertinoPlatform
          ? scrollView
          : RefreshIndicator(
              onRefresh: () async {
                if (widgetElement.hasEventListener('refresh')) {
                  widgetElement.dispatchEvent(dom.Event('refresh'));
                  await Future.delayed(const Duration(seconds: 2));
                }
              },
              child: scrollView,
            ),
    );
  }
}
