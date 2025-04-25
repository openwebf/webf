<template>
  <div class="page-container">
    <webf-listview>
    <h2>ListView Examples</h2>

    <!-- Example 4: Custom Cupertino Refresh Style -->
    <flutter-cupertino-list-section title="Custom Cupertino Refresh Style">
      <p class="description">Uses a custom element for the refresh indicator (Cupertino only).</p>
      <webf-listview
        class="listview-container"
        refresh-style="customCupertino"
        @refresh="handleRefresh('custom')"
        @loadmore="handleLoadMore"
      >
        <!-- Custom refresh indicator element (hidden by default) -->
        <div slotName="refresh-indicator" class="custom-refresh-indicator">
          <img src="https://img.icons8.com/ios-glyphs/30/000000/refresh--v1.png" width="20" height="20" alt="loading" />
          <span>Refreshing data...</span>
        </div>

        <!-- List items -->
        <div v-for="item in customItems" :key="item" class="list-item">Custom Item {{ item }}</div>
      </webf-listview>
      <p class="description">Scroll down to load more items.</p>
    </flutter-cupertino-list-section>

    <!-- Example 1: Default Refresh Style -->
    <flutter-cupertino-list-section title="Default Refresh Style">
      <p class="description">Default behavior (Cupertino on iOS/macOS, Material on others).</p>
      <webf-listview class="listview-container" @refresh="handleRefresh('default')">
        <div v-for="item in items" :key="item" class="list-item">Item {{ item }}</div>
      </webf-listview>
    </flutter-cupertino-list-section>

    <!-- Example 2: Cupertino Refresh Style -->
    <flutter-cupertino-list-section title="Cupertino Refresh Style">
      <p class="description">Forced Cupertino style.</p>
      <webf-listview class="listview-container" refresh-style="cupertino" @refresh="handleRefresh('cupertino')">
        <div v-for="item in items" :key="item" class="list-item">Item {{ item }}</div>
      </webf-listview>
    </flutter-cupertino-list-section>

    <!-- Example 3: Material Refresh Style -->
    <flutter-cupertino-list-section title="Material Refresh Style">
      <p class="description">Forced Material style.</p>
      <webf-listview class="listview-container" refresh-style="material" @refresh="handleRefresh('material')">
        <div v-for="item in items" :key="item" class="list-item">Item {{ item }}</div>
      </webf-listview>
    </flutter-cupertino-list-section>
    </webf-listview>
  </div>
</template>

<script>

export default {
  name: 'ListViewPage',
  data() {
    return {
      items: Array.from({ length: 20 }, (_, i) => i + 1), // Initial items for standard lists
      customItems: Array.from({ length: 15 }, (_, i) => i + 1), // Initial items for custom list
      loadMoreCounter: 0,
    };
  },
  methods: {
    handleRefresh(listType) {
      console.log(`Refresh triggered for ${listType} list!`);
      // Simulate data fetching
      setTimeout(() => {
        console.log(`Refresh complete for ${listType} list.`);
        // Note: The indicator hides automatically after the onRefresh future completes (currently 2s delay in Dart)
        // You might want to update data here
      }, 1500);
    },
    handleLoadMore() {
      console.log('Load more triggered!');
      // Simulate loading more data
      this.loadMoreCounter++;
      const newItems = Array.from({ length: 10 }, (_, i) => this.customItems.length + i + 1);
      // Append new items after a delay
      setTimeout(() => {
        this.customItems = [...this.customItems, ...newItems];
        console.log('Loaded more items.');
        // The loading state in Dart resets after 2s, so no explicit action needed here usually.
      }, 1000);
    },
  },
};
</script>

<style scoped>
.page-container {
  padding: 16px;
}

h2 {
  margin-bottom: 20px;
  text-align: center;
}

.listview-container {
  height: 200px; /* Fixed height for demonstration */
  border: 1px solid #ccc;
  margin-top: 10px;
  margin-bottom: 20px;
  background-color: #f9f9f9;
}

.list-item {
  padding: 15px;
  border-bottom: 1px solid #eee;
  background-color: white;
}

.list-item:last-child {
  border-bottom: none;
}

.description {
  font-size: 0.9em;
  color: #555;
  margin-top: 5px;
  margin-bottom: 5px;
}

.custom-refresh-indicator {
  /* Style for the custom indicator element */
  display: none; /* Important: Hide it initially */
  align-items: center;
  justify-content: center;
  padding: 10px;
  color: #007aff; /* Cupertino blue */
  font-size: 0.9em;
}

.custom-refresh-indicator img {
  margin-right: 8px;
  /* Basic animation - consider a smoother spinner gif/css */
  animation: spin 1s linear infinite;
}

@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

/* Override display when controlled by CupertinoSliverRefreshControl */
webf-listview[refresh-style="customCupertino"] > [slotName="refresh-indicator"] {
   display: flex; /* Make it visible when used by the refresh control */
}

</style>
