<template>
  <div id="main">
    <webf-listview id="list">
      <div class="component-section">
        <div class="section-title">Input 输入框</div>
        <div class="component-block">
          <!-- 基础用法 -->
          <div class="component-item">
            <div class="item-label">基础用法</div>
            <flutter-cupertino-input placeholder="请输入内容" />
          </div>

          <!-- 双向绑定 -->
          <div class="component-item">
            <div class="item-label">双向绑定</div>
            <flutter-cupertino-input 
              :val="inputText"
              placeholder="请输入内容"
              @input="onInputChange"
            />
            <div class="event-output">
              当前输入内容：{{ inputText }}
            </div>
          </div>

          <!-- 输入框类型 -->
          <div class="component-item">
            <div class="item-label">输入框类型</div>
            <div class="input-row">
              <flutter-cupertino-input type="text" placeholder="文本输入框" />
              <flutter-cupertino-input type="password" placeholder="密码输入框" />
              <flutter-cupertino-input type="number" placeholder="数字输入框" />
              <flutter-cupertino-input type="tel" placeholder="电话输入框" />
              <flutter-cupertino-input type="email" placeholder="邮箱输入框" />
              <flutter-cupertino-input type="url" placeholder="URL 输入框" />
            </div>
          </div>

          <!-- 清除按钮 -->
          <div class="component-item">
            <div class="item-label">清除按钮</div>
            <flutter-cupertino-input placeholder="输入文字显示清除按钮" clearable />
          </div>

          <!-- 最大长度 -->
          <div class="component-item">
            <div class="item-label">最大长度</div>
            <flutter-cupertino-input placeholder="最多输入10个字符" maxlength="10" />
          </div>

          <!-- 禁用状态 -->
          <div class="component-item">
            <div class="item-label">禁用状态</div>
            <div class="input-row">
              <flutter-cupertino-input val="这里是禁用的" disabled />
              <flutter-cupertino-input val="这里是只读的" readonly />
            </div>
          </div>

          <!-- 自定义样式 -->
          <div class="component-item">
            <div class="item-label">自定义样式</div>
            <div class="input-row">
              <flutter-cupertino-input 
                placeholder="自定义高度" 
                class="custom-height" 
              />
              <flutter-cupertino-input 
                placeholder="自定义圆角" 
                class="custom-radius" 
              />
              <flutter-cupertino-input 
                placeholder="自定义内边距" 
                class="custom-padding" 
              />
              <flutter-cupertino-input 
                placeholder="文字右对齐" 
                class="text-right"
              />
            </div>
          </div>

          <!-- 前缀和后缀 -->
          <div class="component-item">
            <div class="item-label">前缀和后缀</div>
            <flutter-cupertino-input placeholder="带有前缀的输入框">
              <span slotName="prefix">￥</span>
            </flutter-cupertino-input>
            <flutter-cupertino-input placeholder="带有后缀的输入框" style="margin-top: 12px;">
              <span slotName="suffix">.com</span>
            </flutter-cupertino-input>
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
      inputText: '初始输入内容'
    }
  },
  methods: {
    onInputChange(e) {
      this.inputText = e.detail;
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

.input-row {
  display: flex;
  flex-wrap: wrap;

  :deep(flutter-cupertino-input) {
    flex: 1;
    min-width: 200px;
    margin-right: 12px;
    margin-bottom: 12px;

    &.text-left {
      text-align: left;
    }

    &.text-center {
      text-align: center;
    }

    &.text-right {
      text-align: right;
    }

    &.custom-height {
      height: 56px;
    }

    &.custom-radius {
      border-radius: 20px;
    }

    &.custom-padding {
      padding: 0 20px;
    }
  }
}

.event-output {
  margin-top: 8px;
  font-size: 14px;
  color: var(--font-color-secondary);
}
</style>
