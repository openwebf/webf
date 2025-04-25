<template>
  <div id="main">
    <webf-listview id="list">
      <div class="component-section">

        <!-- Common Category -->
        <div class="section-title">Common</div>
        <div class="component-block category-block">
          <!-- Show Case -->
          <div class="component-item" @click="navigateTo('/show_case')">
            <div class="item-content">
              <div class="item-title">Show Case</div>
              <div class="item-desc">Highlight your elements step by step.</div>
            </div>
            <div class="item-arrow">></div>
          </div>
        </div>
      </div> <!-- End of main component-section -->
    </webf-listview>
  </div>
</template>

<script>
export default {
  methods: {
    navigateTo(path) {
      // Assuming window.webf.hybridHistory is the correct way to navigate
      if (window.webf && window.webf.hybridHistory) {
        window.webf.hybridHistory.pushState({}, path);
      } else {
        console.error('Navigation object (window.webf.hybridHistory) not found.');
      }
    }
  }
}
</script>

<style lang="scss" scoped>
#list {
  padding: 10px 0;
  height: 100vh;
  width: 100vw;
  background-color: var(--background-primary);
}

.component-section {
  padding: 16px;
  margin-bottom: 8px;
}

.section-title {
  font-size: 20px; // Keep title size consistent
  font-weight: 600;
  color: var(--font-color-primary);
  margin-bottom: 10px; // Reduced bottom margin for category titles
  margin-top: 20px; // Add top margin to separate categories

  &:first-of-type {
    margin-top: 0; // No top margin for the very first title
  }
}

.component-block {
  background-color: var(--background-secondary);
  border-radius: 12px;
  padding: 0 16px; // Remove vertical padding, handle with item padding
  margin-bottom: 20px; // Add margin below each category block

  .component-item {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 16px 0; // Adjust padding to be vertical only inside item
    cursor: pointer;
    transition: background-color 0.2s;
    // margin: -16px; // Remove negative margin

    &:active {
      // Consider a subtle active state if needed
      // background-color: var(--background-active); 
    }

    &:not(:last-child) {
      border-bottom: 1px solid var(--border-color);
      // margin-bottom: 16px; // Remove extra margin handled by block margin
      // padding-bottom: 16px; // Padding is now symmetrical
    }

    .item-content {
      flex: 1;
      margin-right: 8px; // Add some space before arrow

      .item-title {
        font-size: 16px;
        font-weight: 500;
        color: var(--font-color-primary);
        margin-bottom: 4px;
      }

      .item-desc {
        font-size: 14px;
        color: var(--font-color-secondary);
      }
    }

    .item-arrow {
      color: var(--font-color-secondary);
      font-size: 16px;
    }
  }
}
</style>