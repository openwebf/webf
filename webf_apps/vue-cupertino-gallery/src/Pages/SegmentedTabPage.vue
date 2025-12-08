<template>
  <div id="main">
    <webf-listview id="list">
      <div class="component-section">
        <div class="section-title">Segmented Tab</div>
        <div class="component-block">
          <!-- 基础用法 -->
          <div class="component-item">
            <div class="item-label">基础用法</div>
            <flutter-cupertino-segmented-tab>
              <flutter-cupertino-segmented-tab-item title="选项一">
                <div class="tab-content">选项一的内容</div>
              </flutter-cupertino-segmented-tab-item>
              <flutter-cupertino-segmented-tab-item title="选项二">
                <div class="tab-content">选项二的内容</div>
              </flutter-cupertino-segmented-tab-item>
              <flutter-cupertino-segmented-tab-item title="选项三">
                <div class="tab-content">选项三的内容</div>
              </flutter-cupertino-segmented-tab-item>
            </flutter-cupertino-segmented-tab>
          </div>

          <!-- 自定义样式 -->
          <div class="component-item">
            <div class="item-label">自定义样式</div>
            <flutter-cupertino-segmented-tab class="custom-tab">
              <flutter-cupertino-segmented-tab-item title="每日">
                <div class="tab-content">
                  <div class="custom-content">
                    每日推荐内容
                  </div>
                </div>
              </flutter-cupertino-segmented-tab-item>
              <flutter-cupertino-segmented-tab-item title="热门">
                <div class="tab-content">
                  <div class="custom-content">
                    热门推荐内容
                  </div>
                </div>
              </flutter-cupertino-segmented-tab-item>
            </flutter-cupertino-segmented-tab>
          </div>

          <!-- 事件监听 -->
          <div class="component-item">
            <div class="item-label">事件监听</div>
            <flutter-cupertino-segmented-tab @change="onTabChange">
              <flutter-cupertino-segmented-tab-item title="标签1">
                <div class="tab-content">标签1内容</div>
              </flutter-cupertino-segmented-tab-item>
              <flutter-cupertino-segmented-tab-item title="标签2">
                <div class="tab-content">标签2内容</div>
              </flutter-cupertino-segmented-tab-item>
            </flutter-cupertino-segmented-tab>
            <div class="event-output">
              当前选中: 标签{{ currentTab + 1 }}
            </div>
          </div>
        </div>
      </div>
    </webf-listview>
  </div>
</template>

<script>
export default {
  data() {
    return {
      currentTab: 0
    }
  },
  methods: {
    onTabChange(e) {
      this.currentTab = e.detail;
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

.tab-content {
  padding: 20px 0;
  height: 20px;
  text-align: center;
  color: var(--font-color-primary);
}

.custom-content {
  background-color: var(--background-primary);
  padding: 20px;
  border-radius: 8px;
  margin: 10px 0;
}

.event-output {
  margin-top: 12px;
  font-size: 14px;
  color: var(--font-color-secondary);
  text-align: center;
}

:deep(.custom-tab) {
  padding: 4px;
  background-color: var(--background-primary);
  border-radius: 8px;
}
</style> 