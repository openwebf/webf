import React, { useState } from 'react';
import { createComponent } from '../utils/CreateComponent';
import styles from './ListviewPage.module.css';

const WebFListView = createComponent({
  tagName: 'webf-listview',
  displayName: 'WebFListView',
  events: {
    onRefresh: 'refresh',
    onLoadmore: 'loadmore'
  }
});

const WebFListViewCupertino = createComponent({
  tagName: 'webf-listview-cupertino',
  displayName: 'WebFListViewCupertino',
  events: {
    onRefresh: 'refresh'
  }
});

const WebFListViewMaterial = createComponent({
  tagName: 'webf-listview-material',
  displayName: 'WebFListViewMaterial',
  events: {
    onRefresh: 'refresh'
  }
});

const FlutterCupertinoListSection = createComponent({
  tagName: 'flutter-cupertino-list-section',
  displayName: 'FlutterCupertinoListSection'
});

export const ListviewPage: React.FC = () => {
  const [items] = useState(Array.from({ length: 20 }, (_, i) => i + 1)); // Initial items for standard lists
  const [customItems, setCustomItems] = useState(Array.from({ length: 15 }, (_, i) => i + 1)); // Initial items for custom list
  const [loadMoreCounter, setLoadMoreCounter] = useState(0);

  const handleRefresh = (listType: string) => {
    console.log(`Refresh triggered for ${listType} list!`);
    // Simulate data fetching
    setTimeout(() => {
      console.log(`Refresh complete for ${listType} list.`);
      // Note: The indicator hides automatically after the onRefresh future completes (currently 2s delay in Dart)
      // You might want to update data here
    }, 1500);
  };

  const handleLoadMore = () => {
    console.log('Load more triggered!');
    // Simulate loading more data
    const newCounter = loadMoreCounter + 1;
    setLoadMoreCounter(newCounter);
    const newItems = Array.from({ length: 10 }, (_, i) => customItems.length + i + 1);
    // Append new items after a delay
    setTimeout(() => {
      setCustomItems([...customItems, ...newItems]);
      console.log('Loaded more items.');
      // The loading state in Dart resets after 2s, so no explicit action needed here usually.
    }, 1000);
  };

  return (
    <div className={styles.pageContainer}>
      <WebFListView>
        <h2>Custom ListView Examples</h2>

        {/* Example 1: Custom Refresh and Load More Style */}
        <FlutterCupertinoListSection title="Custom Refresh and Load More Style">
          <p className={styles.description}>Uses a custom element for the refresh and load more indicator.</p>
          <WebFListView
            className={styles.listviewContainer}
            refresh-style="customCupertino"
            onRefresh={() => handleRefresh('custom')}
            onLoadmore={handleLoadMore}
          >
            {/* List items */}
            {customItems.map(item => (
              <div key={item} className={styles.listItem}>Custom Item {item}</div>
            ))}
          </WebFListView>
          <p className={styles.description}>Scroll down to load more items.</p>
        </FlutterCupertinoListSection>

        {/* Example 2: Cupertino Refresh Style */}
        <FlutterCupertinoListSection title="Cupertino Refresh Style">
          <p className={styles.description}>Forced Cupertino style.</p>
          <WebFListViewCupertino className={styles.listviewContainer} onRefresh={() => handleRefresh('cupertino')}>
            {items.map(item => (
              <div key={item} className={styles.listItem}>Item {item}</div>
            ))}
          </WebFListViewCupertino>
        </FlutterCupertinoListSection>

        {/* Example 3: Material Refresh Style */}
        <FlutterCupertinoListSection title="Material Refresh Style">
          <p className={styles.description}>Forced Material style.</p>
          <WebFListViewMaterial className={styles.listviewContainer} onRefresh={() => handleRefresh('material')}>
            {items.map(item => (
              <div key={item} className={styles.listItem}>Item {item}</div>
            ))}
          </WebFListViewMaterial>
        </FlutterCupertinoListSection>
      </WebFListView>
    </div>
  );
};