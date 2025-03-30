<template>
  <div id="main">
    <webf-listview id="list">
      <!-- Button 组件展示 -->
      <div class="component-section">
        <div class="section-title">Button 按钮</div>
        <div class="component-block">
          <div class="component-item">
            <div class="item-label">默认按钮</div>
            <flutter-cupertino-button>默认按钮123</flutter-cupertino-button>
          </div>
          <div class="component-item">
            <div class="item-label">主要按钮</div>
            <flutter-cupertino-button type="primary">主要按钮</flutter-cupertino-button>
          </div>
          <div class="component-item">
            <div class="item-label">禁用状态</div>
            <flutter-cupertino-button disabled>禁用按钮</flutter-cupertino-button>
          </div>
        </div>
      </div>

      <!-- Input 组件展示 -->
      <div class="component-section">
        <div class="section-title">Input 输入框</div>
        <div class="component-block">
          <div class="component-item">
            <div class="item-label">基础输入框</div>
            <flutter-cupertino-input placeholder="请输入内容" />
          </div>
          <div class="component-item">
            <div class="item-label">带清除按钮</div>
            <flutter-cupertino-input placeholder="请输入内容" clearable />
          </div>
          <div class="component-item">
            <div class="item-label">禁用状态</div>
            <flutter-cupertino-input placeholder="禁用状态" disabled />
          </div>
        </div>
      </div>

      <!-- Switch 组件展示 -->
      <div class="component-section">
        <div class="section-title">Switch 开关</div>
        <div class="component-block">
          <div class="component-item">
            <div class="item-label">基础用法</div>
            <flutter-cupertino-switch />
          </div>
          <div class="component-item">
            <div class="item-label">自定义颜色</div>
            <flutter-cupertino-switch activeColor="#07c160" />
          </div>
          <div class="component-item">
            <div class="item-label">禁用状态</div>
            <flutter-cupertino-switch disabled />
          </div>
        </div>
      </div>

      <!-- Loading 组件展示 -->
      <div class="component-section">
        <div class="section-title">Loading 加载</div>
        <div class="component-block">
          <div class="component-item">
            <div class="item-label">基础用法</div>
            <flutter-cupertino-activity-indicator />
          </div>
          <div class="component-item">
            <div class="item-label">大小设置</div>
            <flutter-cupertino-activity-indicator size="large" />
          </div>
        </div>
      </div>
    </webf-listview>
  </div>
</template>

<script>
export default {
  data: () => {
    return {
      show: true,
      listAmount: 1
    }
  },
  methods: {
    handleScrollAtEnd() {
      this.listAmount++;
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
      margin-bottom: 16px;

      &:last-child {
        margin-bottom: 0;
      }

      .item-label {
        font-size: 14px;
        color: var(--font-color-secondary);
        margin-bottom: 8px;
      }
    }
  }
}
</style>