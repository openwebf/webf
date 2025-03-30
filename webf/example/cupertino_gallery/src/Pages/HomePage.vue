<template>
  <div id="main">
    <webf-listview id="list">
      <div class="component-section">
        <div class="section-title">Cupertino 组件</div>
        <div class="component-block">
          <!-- 按钮 -->
          <div class="component-item" @click="navigateTo('/button')">
            <div class="item-content">
              <div class="item-title">Button 按钮</div>
              <div class="item-desc">用于触发操作的按钮组件</div>
            </div>
            <div class="item-arrow">></div>
          </div>

          <!-- 输入框 -->
          <div class="component-item" @click="navigateTo('/input')">
            <div class="item-content">
              <div class="item-title">Input 输入框</div>
              <div class="item-desc">用于输入内容的表单组件</div>
            </div>
            <div class="item-arrow">></div>
          </div>

          <!-- 开关 -->
          <div class="component-item" @click="navigateTo('/switch')">
            <div class="item-content">
              <div class="item-title">Switch 开关</div>
              <div class="item-desc">用于切换状态的开关组件</div>
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