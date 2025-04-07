<template>
  <div id="main">
    <webf-listview id="list">
      <div class="component-section">
        <div class="section-title">Alert</div>
        <div class="component-block">
          <!-- Basic Usage -->
          <div class="component-item">
            <div class="item-label">Basic Usage</div>
            <flutter-cupertino-button @click="showBasicAlert">
              Show Basic Alert
            </flutter-cupertino-button>
          </div>

          <!-- With Title and Buttons -->
          <div class="component-item">
            <div class="item-label">With Title and Buttons</div>
            <flutter-cupertino-button @click="showConfirmAlert">
              Show Confirm Alert
            </flutter-cupertino-button>
          </div>

          <!-- With Title and Message -->
          <div class="component-item">
            <div class="item-label">With Title and Message</div>
            <flutter-cupertino-button @click="showCustomAlert">
              Show Title and Message
            </flutter-cupertino-button>
          </div>

          <!-- Destructive Action -->
          <div class="component-item">
            <div class="item-label">Destructive Action</div>
            <flutter-cupertino-button @click="showDestructiveAlert">
              Show Destructive Alert
            </flutter-cupertino-button>
          </div>

          <!-- Default Button -->
          <div class="component-item">
            <div class="item-label">Default Button</div>
            <flutter-cupertino-button @click="showDefaultButtonAlert">
              Show Default Button Alert
            </flutter-cupertino-button>
          </div>
        </div>
      </div>
    </webf-listview>

    <!-- Alert Components -->
    <flutter-cupertino-alert
      ref="basicAlert"
      title="This is a Basic Alert"
      confirm-text="Got it"
    />

    <flutter-cupertino-alert 
      ref="confirmAlert"
      title="Are you sure you want to proceed?"
      cancel-text="Cancel"
      confirm-text="Confirm"
      @cancel="onCancel"
      @confirm="onConfirm"
    />

    <flutter-cupertino-alert 
      ref="customAlert"
      title="Operation Notice"
      message="This is an important notice, please read carefully"
      confirm-text="Got it"
    />

    <flutter-cupertino-alert
      ref="destructiveAlert"
      title="Delete Confirmation"
      message="Data cannot be recovered after deletion. Do you want to continue?"
      cancel-text="Cancel"
      confirm-text="Delete"
      confirm-destructive="true"
      @cancel="onCancel"
      @confirm="onDelete"
    />

    <flutter-cupertino-alert
      ref="defaultButtonAlert"
      title="Choose Action"
      message="Please select the action to perform"
      cancel-text="Later"
      confirm-text="Update Now"
      cancel-default="true"
      @cancel="onLater"
      @confirm="onUpdate"
    />
  </div>
</template>

<script>
export default {
  methods: {
    showBasicAlert() {
      this.$refs.basicAlert.show();
    },
    showConfirmAlert() {
      this.$refs.confirmAlert.show();
    },
    showCustomAlert() {
      this.$refs.customAlert.show();
    },
    showDestructiveAlert() {
      this.$refs.destructiveAlert.show();
    },
    showDefaultButtonAlert() {
      this.$refs.defaultButtonAlert.show();
    },
    onCancel() {
      console.log('Operation cancelled');
    },
    onConfirm() {
      console.log('Operation confirmed');
    },
    onDelete() {
      console.log('Executing delete operation');
    },
    onLater() {
      console.log('Postponed');
    },
    onUpdate() {
      console.log('Executing update operation');
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
</style> 