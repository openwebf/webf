<template>
  <div id="main">
    <!-- Instantiate the non-visual action sheet component -->
    <flutter-cupertino-action-sheet ref="actionSheet" @share="handleShare" @delete="handleDelete"
      @archive="handleArchive" @cancel="handleCancel" />

    <webf-listview id="list">
      <div class="component-section">
        <div class="section-title">Action Sheet</div>
        <div class="component-block">

          <!-- Basic Action Sheet -->
          <div class="component-item">
            <div class="item-label">Basic Action Sheet</div>
            <flutter-cupertino-button @click="showBasicActionSheet">
              Show Basic Sheet
            </flutter-cupertino-button>
          </div>

          <!-- With Title and Message -->
          <div class="component-item">
            <div class="item-label">With Title and Message</div>
            <flutter-cupertino-button @click="showTitleMessageActionSheet">
              Show Sheet with Title/Message
            </flutter-cupertino-button>
          </div>

          <!-- With Destructive and Cancel -->
          <div class="component-item">
            <div class="item-label">With Destructive and Cancel Button</div>
            <flutter-cupertino-button @click="showDestructiveCancelActionSheet">
              Show Sheet with Destructive/Cancel
            </flutter-cupertino-button>
          </div>

          <!-- With Default Action -->
          <div class="component-item">
            <div class="item-label">With Default Action</div>
            <flutter-cupertino-button @click="showDefaultActionSheet">
              Show Sheet with Default Action
            </flutter-cupertino-button>
          </div>

        </div>
      </div>
    </webf-listview>
  </div>
</template>

<script>
export default {
  methods: {
    showActionSheet(config) {
      if (this.$refs.actionSheet) {
        this.$refs.actionSheet.show(config);
      } else {
        console.error('Action Sheet component ref not found');
      }
    },
    showBasicActionSheet() {
      this.showActionSheet({
        actions: [
          { text: 'Share File', event: 'share' },
          { text: 'Archive File', event: 'archive' },
        ]
      });
    },
    showTitleMessageActionSheet() {
      this.showActionSheet({
        title: 'File Options',
        message: 'Choose an action for the selected file.',
        actions: [
          { text: 'Share File', event: 'share' },
          { text: 'Archive File', event: 'archive' },
        ],
        // Example with explicit cancel button config
        cancelButton: { text: 'Cancel', event: 'cancel' }
      });
    },
    showDestructiveCancelActionSheet() {
      this.showActionSheet({
        actions: [
          { text: 'Share File', event: 'share' },
          { text: 'Archive File', event: 'archive' },
          { text: 'Delete File', event: 'delete', isDestructive: true },
        ],
        cancelButton: { text: 'Cancel', event: 'cancel' } // isDestructive defaults to false
      });
    },
    showDefaultActionSheet() {
      this.showActionSheet({
        title: 'Confirm Action',
        actions: [
          { text: 'Proceed', event: 'proceed', isDefault: true },
          { text: 'Review', event: 'review' },
        ],
        cancelButton: { text: 'Cancel', event: 'cancel' }
      });
    },

    // Event Handlers
    handleShare(event) {
      console.log('Action Sheet Event: share', event.detail);
    },
    handleDelete(event) {
      console.log('Action Sheet Event: delete', event.detail);
    },
    handleArchive(event) {
      console.log('Action Sheet Event: archive', event.detail);
    },
    handleCancel(event) {
      console.log('Action Sheet Event: cancel', event.detail);
    },
    // Add handlers for other events like proceed, review if needed
  }
};
</script>

<style lang="scss" scoped>
#main {
  // The action sheet component itself is not visual, so only list styles needed
}

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

      // Center the button
      flutter-cupertino-button {
        display: block;
        margin: 0 auto;
      }
    }
  }
}
</style>