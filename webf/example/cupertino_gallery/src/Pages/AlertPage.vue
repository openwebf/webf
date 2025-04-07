<template>
  <div id="main">
    <webf-listview id="list">
      <div class="component-section">
        <div class="section-title">Alert</div>
        <div class="component-block">
          <!-- 基础用法 -->
          <div class="component-item">
            <div class="item-label">基础用法</div>
            <flutter-cupertino-button @click="showBasicAlert">
              显示基础弹窗
            </flutter-cupertino-button>
          </div>

          <!-- 带标题和按钮 -->
          <div class="component-item">
            <div class="item-label">带标题和按钮</div>
            <flutter-cupertino-button @click="showConfirmAlert">
              显示确认弹窗
            </flutter-cupertino-button>
          </div>

          <!-- 带标题和消息 -->
          <div class="component-item">
            <div class="item-label">带标题和消息</div>
            <flutter-cupertino-button @click="showCustomAlert">
              显示标题和消息
            </flutter-cupertino-button>
          </div>

          <!-- 危险操作 -->
          <div class="component-item">
            <div class="item-label">危险操作</div>
            <flutter-cupertino-button @click="showDestructiveAlert">
              显示危险操作弹窗
            </flutter-cupertino-button>
          </div>

          <!-- 默认按钮 -->
          <div class="component-item">
            <div class="item-label">默认按钮</div>
            <flutter-cupertino-button @click="showDefaultButtonAlert">
              显示默认按钮弹窗
            </flutter-cupertino-button>
          </div>
        </div>
      </div>
    </webf-listview>

    <!-- Alert Components -->
    <flutter-cupertino-alert
      ref="basicAlert"
      title="这是一个基础弹窗"
      confirm-text="我知道了"
    />

    <flutter-cupertino-alert 
      ref="confirmAlert"
      title="确认要执行此操作吗？"
      cancel-text="取消"
      confirm-text="确认"
      @cancel="onCancel"
      @confirm="onConfirm"
    />

    <flutter-cupertino-alert 
      ref="customAlert"
      title="操作提示"
      message="这是一条重要的提示信息，请仔细阅读"
      confirm-text="我知道了"
    />

    <flutter-cupertino-alert
      ref="destructiveAlert"
      title="删除确认"
      message="删除后数据将无法恢复，是否继续？"
      cancel-text="取消"
      confirm-text="删除"
      confirm-destructive="true"
      @cancel="onCancel"
      @confirm="onDelete"
    />

    <flutter-cupertino-alert
      ref="defaultButtonAlert"
      title="选择操作"
      message="请选择要执行的操作"
      cancel-text="稍后再说"
      confirm-text="立即更新"
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
      console.log('操作已取消');
    },
    onConfirm() {
      console.log('操作已确认');
    },
    onDelete() {
      console.log('执行删除操作');
    },
    onLater() {
      console.log('稍后再说');
    },
    onUpdate() {
      console.log('执行更新操作');
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