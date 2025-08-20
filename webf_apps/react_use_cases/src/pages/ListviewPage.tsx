import React, { useState } from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import { FlutterCupertinoListSection, FlutterCupertinoListSectionHeader } from '@openwebf/react-cupertino-ui';
import { WebFListviewCupertino, WebFListviewMaterial } from '@openwebf/react-ui-kit';
import styles from './ListviewPage.module.css';



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
        <FlutterCupertinoListSection>
          <FlutterCupertinoListSectionHeader>
            Custom Refresh and Load More Style
          </FlutterCupertinoListSectionHeader>
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
        </FlutterCupertinoListSection>
        {/* Example 2: Cupertino Refresh Style */}
        <FlutterCupertinoListSection className={styles.listSection}>
          <FlutterCupertinoListSectionHeader>
            Cupertino Refresh Style
            <p className={styles.description}>Forced Cupertino style.</p>
          </FlutterCupertinoListSectionHeader>
          <WebFListviewCupertino className={styles.listviewContainer} onRefresh={() => handleRefresh('cupertino')}>
            {items.map(item => (
              <div key={item} className={styles.listItem}>Item {item}</div>
            ))}
          </WebFListviewCupertino>
        </FlutterCupertinoListSection>

        {/* Example 3: Material Refresh Style */}
        <FlutterCupertinoListSection>
          <FlutterCupertinoListSectionHeader>
            Material Refresh Style
            <p className={styles.description}>Forced Material style.</p>
          </FlutterCupertinoListSectionHeader>
          <WebFListviewMaterial className={styles.listviewContainer} onRefresh={() => handleRefresh('material')}>
            {items.map(item => (
              <div key={item} className={styles.listItem}>Item {item}</div>
            ))}
          </WebFListviewMaterial>
        </FlutterCupertinoListSection>
      </WebFListView>
    </div>
  );
};