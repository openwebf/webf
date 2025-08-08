interface WebFListviewCupertinoProperties {
  // Inherits from WebFListView properties
  'shrink-wrap'?: boolean;
}

interface WebFListviewCupertinoMethods {
  finishRefresh(result: 'success' | 'fail' | 'noMore'): void;
  finishLoadMore(result: 'success' | 'fail' | 'noMore'): void;
}

interface WebFListviewCupertinoEvents {
  refresh: Event;
  loadmore: Event;
}