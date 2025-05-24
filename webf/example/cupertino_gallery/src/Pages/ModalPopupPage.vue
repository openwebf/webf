<template>
  <div id="main">
    <webf-listview id="list">
      <div class="component-section">
        <div class="section-title">Modal Popup</div>
        <div class="component-block">
          <!-- 基础用法 -->
          <div class="component-item">
            <div class="item-label">Basic Usage</div>
            <flutter-cupertino-button variant="filled"  @click="showBasicPopup">
              Show Basic Popup
            </flutter-cupertino-button>
          </div>

          <!-- 自定义内容 -->
          <div class="component-item">
            <div class="item-label">Custom Content</div>
            <flutter-cupertino-button variant="filled"  @click="showCustomPopup">
              Show Custom Popup
            </flutter-cupertino-button>
          </div>

          <!-- 自定义高度 -->
          <div class="component-item">
            <div class="item-label">Custom Height</div>
            <flutter-cupertino-button variant="filled"  @click="showHeightPopup">
              Show 400px Height Popup
            </flutter-cupertino-button>
          </div>

          <!-- 禁用点击遮罩关闭 -->
          <div class="component-item">
            <div class="item-label">Disable Mask Close</div>
            <flutter-cupertino-button variant="filled"  @click="showNoMaskClosePopup">
              Show Non-maskClosable Popup
            </flutter-cupertino-button>
          </div>

          <!-- 自定义样式 -->
          <div class="component-item">
            <div class="item-label">Custom Style</div>
            <flutter-cupertino-button variant="filled" @click="showCustomStylePopup">
              Show Custom Style Popup
            </flutter-cupertino-button>
          </div>
        </div>
      </div>

      <!-- Basic Popup -->
      <flutter-cupertino-modal-popup
        ref="basicPopup"
        height="200"
        @close="onPopupClose"
      >
        <div class="popup-content">
          <div class="popup-title">Basic Popup</div>
          <div class="popup-text">This is a basic popup example</div>
        </div>
      </flutter-cupertino-modal-popup>

      <!-- Custom Popup -->
      <flutter-cupertino-modal-popup
        ref="customPopup"
        height="300"
        @close="onPopupClose"
      >
        <div class="popup-content">
          <div class="popup-title">Share to</div>
          <div class="share-grid">
            <div class="share-item" v-for="item in shareItems" :key="item.icon">
              <div class="share-label">{{ item.label }}</div>
            </div>
          </div>
        </div>
      </flutter-cupertino-modal-popup>

      <!-- Height Popup -->
      <flutter-cupertino-modal-popup
        ref="heightPopup"
        height="400"
        @close="onPopupClose"
      >
        <div class="popup-content">
          <div class="popup-title">Custom Height</div>
          <div class="popup-text">This popup has a height of 400px</div>
        </div>
      </flutter-cupertino-modal-popup>

      <!-- No Mask Close Popup -->
      <flutter-cupertino-modal-popup
        ref="noMaskClosePopup"
        height="250"
        mask-closable="false"
        background-opacity="0.6"
        @close="onPopupClose"
      >
        <div class="popup-content">
          <div class="popup-title">Disable Mask Close</div>
          <div class="popup-text">
            This popup has disabled mask close functionality, can only be closed by other means
          </div>
          <div class="popup-footer">
            <flutter-cupertino-button variant="filled" @click="hideNoMaskClosePopup">
              Close
            </flutter-cupertino-button>
          </div>
        </div>
      </flutter-cupertino-modal-popup>

      <!-- Custom Style Popup -->
      <flutter-cupertino-modal-popup
        ref="customStylePopup"
        height="250"
        surface-painted="false"
        background-opacity="0.2"
        @close="onPopupClose"
      >
        <div class="popup-content custom-style">
          <div class="popup-title">Custom Style</div>
          <div class="popup-text">
            This is a custom styled popup example with disabled background and semi-transparent mask
          </div>
        </div>
      </flutter-cupertino-modal-popup>
    </webf-listview>
  </div>
</template>

<script>
export default {
  data() {
    return {
      shareItems: [
        { icon: 'pencil', label: 'Message' },
        { icon: 'mail_fill', label: 'Email' },
        { icon: 'link', label: 'Copy Link' },
        { icon: 'share', label: 'More' },
      ],
    }
  },
  methods: {
    showBasicPopup() {
      this.$refs.basicPopup.show();
    },
    showCustomPopup() {
      this.$refs.customPopup.show();
    },
    showHeightPopup() {
      this.$refs.heightPopup.show();
    },
    showNoMaskClosePopup() {
      this.$refs.noMaskClosePopup.show();
    },
    hideNoMaskClosePopup() {
      this.$refs.noMaskClosePopup.hide();
    },
    showCustomStylePopup() {
      this.$refs.customStylePopup.show();
    },
    onPopupClose() {
      console.log('Popup closed');
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

.popup-content {
  padding: 20px;

  .popup-title {
    font-size: 18px;
    font-weight: 600;
    color: var(--font-color-primary);
    margin-bottom: 16px;
    text-align: center;
  }

  .popup-text {
    font-size: 16px;
    color: var(--font-color-secondary);
    text-align: center;
  }
}

.share-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 20px;
  padding: 20px 0;

  .share-item {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 8px;

    .share-label {
      font-size: 12px;
      color: var(--font-color-secondary);
    }
  }
}

.popup-footer {
  margin-top: 20px;
  display: flex;
  justify-content: center;
}

.custom-style {
  background-color: rgba(255, 255, 255, 0.9);
  border-radius: 12px;
  margin: 0 16px;
}
</style>
