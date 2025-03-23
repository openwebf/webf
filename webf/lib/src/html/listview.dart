import 'package:flutter/material.dart';
import 'package:webf/src/css/position.dart';
import 'package:webf/webf.dart';
import 'package:webf/rendering.dart';
import 'package:webf/dom.dart' as dom;

const LISTVIEW = 'LISTVIEW';
const WEBF_LISTVIEW = 'WEBF-LISTVIEW';

class FlutterListViewElement extends WidgetElement {
  FlutterListViewElement(BindingContext? context) : super(context);

  Axis scrollDirection = Axis.vertical;

  // Control the state of pull-to-refresh
  bool _isRefreshing = false;
  
  // Control the state of load more
  bool _isLoadingMore = false;
  
  // The threshold of pull-to-refresh
  final double _refreshTriggerPullDistance = 100.0;

  @override
  ScrollController? get scrollControllerX {
    return context != null && scrollDirection == Axis.horizontal ? PrimaryScrollController.maybeOf(context!) : null;
  }

  @override
  ScrollController? get scrollControllerY {
    return context != null && scrollDirection == Axis.vertical ? PrimaryScrollController.maybeOf(context!) : null;
  }

  @override
  bool get isScrollingElement => true;

  void _scrollListener() {
    ScrollController? scrollController = context != null ? PrimaryScrollController.maybeOf(context!) : null;
    if (scrollController != null) {
      // Handle load more
      if (scrollController.position.extentAfter < 50 && !_isLoadingMore) {
        _isLoadingMore = true;
        // Trigger load more event
        dispatchEvent(dom.Event('loadmore'));
        
        // Reset state after 200ms to avoid multiple triggers in a short time
        Future.delayed(const Duration(milliseconds: 200), () {
          _isLoadingMore = false;
        });
      }
      
      // Handle pull-to-refresh
      if (scrollController.position.pixels < 0) {
          // 这里可以根据拖动距离来更新下拉指示器状态
          // 比如当拖动距离超过阈值时，可以更新指示器颜色或文本
      }
      
      handleScroll(scrollController.position.pixels, scrollController.position.axisDirection);
    }
  }
  
  // Handle the operation when scrolling ends
  void _handleScrollEnd() {
    ScrollController? scrollController = context != null ? PrimaryScrollController.maybeOf(context!) : null;
    if (scrollController != null) {
      // If the scrolling ends at the top and there is a pull-to-refresh distance, trigger refresh
      if (scrollController.position.pixels < 0 && 
          scrollController.position.pixels.abs() > _refreshTriggerPullDistance && 
          !_isRefreshing) {
        _isRefreshing = true;
        // Trigger refresh event
        dispatchEvent(dom.Event('refresh'));
        
        // Reset state after 2 seconds, actually it should be reset by user code after refreshing
        Future.delayed(const Duration(seconds: 2), () {
          _isRefreshing = false;
        });
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ScrollController? scrollController = PrimaryScrollController.maybeOf(context!);
    scrollController?.addListener(_scrollListener);
    
    // Listen to scroll notifications, for handling pull-to-refresh
    // This part needs to be implemented in the build method using NotificationListener
  }

  @override
  void stateDispose() {
    if (context == null) return;
    ScrollController? scrollController = PrimaryScrollController.maybeOf(context!);
    scrollController?.removeListener(_scrollListener);
    super.stateDispose();
  }

  @override
  Widget build(BuildContext context, ChildNodeList childNodes) {
    return WebFChildNodeSize(
        ownerElement: this,
        child: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification notification) {
            // Listen to scroll end event
            if (notification is ScrollEndNotification) {
              _handleScrollEnd();
            }
            return false;
          },
          child: RefreshIndicator(
            onRefresh: () async {
              if (!_isRefreshing) {
                _isRefreshing = true;
                // Trigger refresh event
                dispatchEvent(dom.Event('refresh'));
                
                // Wait for refresh to complete
                // Here create a delayed Future, actually it should be marked as completed by user code
                await Future.delayed(const Duration(seconds: 2));
                _isRefreshing = false;
              }
            },
            child: ListView.builder(
              scrollDirection: scrollDirection,
              itemCount: childNodes.length + 1, // Add one item for loading more
              itemBuilder: (context, index) {
                // If it is the last element, add a loading more indicator
                if (index == childNodes.length) {
                  return Container(
                    height: 50,
                    alignment: Alignment.center,
                    child: _isLoadingMore 
                      ? const CircularProgressIndicator(strokeWidth: 2)
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
              primary: true,
              padding: const EdgeInsets.all(0),
              physics: const AlwaysScrollableScrollPhysics(),
            ),
          ),
        ));
  }
  
  // Provide a public method for JS to call, representing refresh completion
  void completeRefresh() {
    _isRefreshing = false;
  }
  
  // Provide a public method for JS to call, representing load more completion
  void completeLoadMore() {
    _isLoadingMore = false;
  }
}
