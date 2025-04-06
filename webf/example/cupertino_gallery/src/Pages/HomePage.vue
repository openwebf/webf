<template>
  <div id="main">
    <webf-listview id="list">
      <div class="component-section">
        <div class="section-title">Cupertino Components</div>
        <div class="component-block">
          <!-- Button -->
          <div class="component-item" @click="navigateTo('/button')">
            <div class="item-content">
              <div class="item-title">Button</div>
              <div class="item-desc">A button component for triggering actions</div>
            </div>
            <div class="item-arrow">></div>
          </div>

          <!-- Input -->
          <div class="component-item" @click="navigateTo('/input')">
            <div class="item-content">
              <div class="item-title">Input</div>
              <div class="item-desc">A form component for text input</div>
            </div>
            <div class="item-arrow">></div>
          </div>

          <!-- Switch -->
          <div class="component-item" @click="navigateTo('/switch')">
            <div class="item-content">
              <div class="item-title">Switch</div>
              <div class="item-desc">A toggle component for switching states</div>
            </div>
            <div class="item-arrow">></div>
          </div>

          <!-- Icon -->
          <div class="component-item" @click="navigateTo('/icon')">
            <div class="item-content">
              <div class="item-title">Icon</div>
              <div class="item-desc">iOS-style icon component</div>
            </div>
            <div class="item-arrow">></div>
          </div>

          <!-- Search Input -->
          <div class="component-item" @click="navigateTo('/search_input')">
            <div class="item-content">
              <div class="item-title">Search Input</div>
              <div class="item-desc">A search input component for content searching</div>
            </div>
            <div class="item-arrow">></div>
          </div>

          <!-- Textarea -->
          <div class="component-item" @click="navigateTo('/textarea')">
            <div class="item-content">
              <div class="item-title">Textarea</div>
              <div class="item-desc">A textarea component for multi-line text input</div>
            </div>
            <div class="item-arrow">></div>
          </div>
        </div>
      </div>
    </webf-listview>
  </div>
</template>

<script>
export default {
  methods: {
    navigateTo(path) {
      window.webf.hybridHistory.pushState({}, path);
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

  .section-title {
    font-size: 20px;
    font-weight: 600;
    color: var(--font-color-primary);
    margin-bottom: 16px;
  }

  .component-block {
    background-color: var(--background-secondary);
    border-radius: 12px;
    padding: 16px;

    .component-item {
      display: flex;
      align-items: center;
      justify-content: space-between;
      padding: 16px;
      margin: -16px;
      cursor: pointer;
      transition: background-color 0.2s;

      &:active {
        background-color: var(--background-active);
      }

      &:not(:last-child) {
        border-bottom: 1px solid var(--border-color);
        margin-bottom: 16px;
        padding-bottom: 16px;
      }

      .item-content {
        flex: 1;

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
        margin-left: 8px;
        color: var(--font-color-secondary);
        font-size: 16px;
      }
    }
  }
}
</style>