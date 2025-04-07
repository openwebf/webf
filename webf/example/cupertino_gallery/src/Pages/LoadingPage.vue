<template>
  <div id="main">
    <webf-listview id="list">
      <div class="component-section">
        <div class="section-title">Loading</div>
        <div class="component-block">
          <!-- Basic Usage -->
          <div class="component-item">
            <div class="item-label">Basic Usage</div>
            <flutter-cupertino-button @click="showBasicLoading">
              Show Loading
            </flutter-cupertino-button>
          </div>

          <!-- With Text -->
          <div class="component-item">
            <div class="item-label">With Text</div>
            <flutter-cupertino-button @click="showLoadingWithText">
              Show Loading
            </flutter-cupertino-button>
          </div>

          <!-- Auto Hide -->
          <div class="component-item">
            <div class="item-label">Auto Hide</div>
            <flutter-cupertino-button @click="showAutoHideLoading">
              Show Loading (Auto hide in 2s)
            </flutter-cupertino-button>
          </div>

          <!-- Mask Closable -->
          <div class="component-item">
            <div class="item-label">Mask Closable</div>
            <flutter-cupertino-button @click="showMaskClosableLoading">
              Show Loading (Click mask to close)
            </flutter-cupertino-button>
          </div>
        </div>
      </div>

      <!-- Loading Components -->
      <flutter-cupertino-loading ref="basicLoading" />
      <flutter-cupertino-loading ref="textLoading" />
      <flutter-cupertino-loading ref="autoHideLoading" />
      <flutter-cupertino-loading ref="maskClosableLoading" maskClosable />
    </webf-listview>
  </div>
</template>

<script>
export default {
  methods: {
    showBasicLoading() {
      this.$refs.basicLoading.show();
      setTimeout(() => {
        this.$refs.basicLoading.hide();
      }, 1000);
    },
    showLoadingWithText() {
      this.$refs.textLoading.show({
        text: 'Loading...'
      });
      setTimeout(() => {
        this.$refs.textLoading.hide();
      }, 1000);
    },
    showAutoHideLoading() {
      this.$refs.autoHideLoading.show({
        text: 'Processing...'
      });
      setTimeout(() => {
        this.$refs.autoHideLoading.hide();
      }, 2000);
    },
    showMaskClosableLoading() {
      this.$refs.maskClosableLoading.show({
        text: 'Click mask to close'
      });
    },
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
      margin-bottom: 24px;

      &:last-child {
        margin-bottom: 0;
      }

      .item-label {
        font-size: 14px;
        color: var(--font-color-secondary);
        margin-bottom: 12px;
      }
    }
  }
}

.button-group {
  display: flex;
  gap: 12px;

  :deep(flutter-cupertino-button) {
    flex: 1;
  }
}
</style> 