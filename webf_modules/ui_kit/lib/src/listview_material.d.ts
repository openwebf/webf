interface WebFListviewMaterialProperties {
  // Inherits from WebFListView properties
  'shrink-wrap'?: boolean;
}

interface WebFListviewMaterialMethods {
  finishRefresh(result: 'success' | 'fail' | 'noMore'): void;
  finishLoadMore(result: 'success' | 'fail' | 'noMore'): void;
}

interface WebFListviewMaterialEvents {
  refresh: Event;
  loadmore: Event;
}