<template>
  <div id="main">
    <webf-listview id="list">
      <div class="component-section">
        <div class="section-title">SearchInput 搜索框</div>
        <div class="component-block">
          <!-- 基础用法 -->
          <div class="component-item">
            <div class="item-label">基础用法</div>
            <flutter-cupertino-search-input placeholder="请输入搜索内容" />
          </div>

          <!-- 默认值 -->
          <div class="component-item">
            <div class="item-label">默认值</div>
            <flutter-cupertino-search-input 
              val="默认搜索内容" 
              placeholder="请输入搜索内容" 
            />
          </div>

          <!-- 双向绑定 -->
          <div class="component-item">
            <div class="item-label">双向绑定</div>
            <flutter-cupertino-search-input 
              :val="searchText"
              placeholder="请输入搜索内容"
              @input="onSearchInput"
            />
            <div class="event-output">
              当前输入内容：{{ searchText }}
            </div>
          </div>

          <!-- 禁用状态 -->
          <div class="component-item">
            <div class="item-label">禁用状态</div>
            <flutter-cupertino-search-input 
              placeholder="禁用状态的搜索框" 
              disabled
            />
          </div>

          <!-- 输入类型 -->
          <div class="component-item">
            <div class="item-label">输入类型</div>
            <div class="search-row">
              <flutter-cupertino-search-input 
                type="number"
                placeholder="数字输入" 
              />
              <flutter-cupertino-search-input 
                type="tel"
                placeholder="电话号码" 
              />
              <flutter-cupertino-search-input 
                type="url"
                placeholder="网址" 
              />
            </div>
          </div>

          <!-- 自定义图标 -->
          <div class="component-item">
            <div class="item-label">自定义图标</div>
            <div class="search-row">
              <flutter-cupertino-search-input 
                prefix-icon="search"
                suffix-icon="xmark_circle_fill"
                placeholder="默认图标" 
              />
              <flutter-cupertino-search-input 
                item-color="#007AFF"
                item-size="24"
                placeholder="自定义图标颜色和大小" 
              />
            </div>
          </div>

          <!-- 清除按钮显示模式 -->
          <div class="component-item">
            <div class="item-label">清除按钮显示模式</div>
            <div class="search-row">
              <flutter-cupertino-search-input 
                suffix-mode="never"
                placeholder="从不显示清除按钮" 
              />
              <flutter-cupertino-search-input 
                suffix-mode="always"
                placeholder="始终显示清除按钮" 
              />
              <flutter-cupertino-search-input 
                suffix-mode="editing"
                placeholder="编辑时显示清除按钮" 
              />
            </div>
          </div>

          <!-- 自定义样式 -->
          <div class="component-item">
            <div class="item-label">自定义样式</div>
            <div class="search-row">
              <flutter-cupertino-search-input 
                placeholder="自定义圆角" 
                class="custom-radius" 
              />
              <flutter-cupertino-search-input 
                placeholder="自定义内边距" 
                class="custom-padding" 
              />
            </div>
          </div>

          <!-- 事件监听 -->
          <div class="component-item">
            <div class="item-label">事件监听</div>
            <flutter-cupertino-search-input 
              placeholder="输入内容触发事件" 
              @input="onInput"
              @search="onSearch"
              @clear="onClear"
            />
            <div class="event-output" v-if="inputValue">
              输入的内容: {{ inputValue }}
            </div>
            <div class="event-output" v-if="searchValue">
              搜索的内容: {{ searchValue }}
            </div>
            <div class="event-output" v-if="isCleared">
              搜索框已清空
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
      inputValue: '',
      searchValue: '',
      isCleared: false,
      searchText: '初始搜索内容'
    }
  },
  methods: {
    onInput(e) {
      this.inputValue = e.detail;
      this.isCleared = false;
    },
    onSearch(e) {
      this.searchValue = e.detail;
    },
    onClear() {
      this.isCleared = true;
      this.inputValue = '';
      this.searchValue = '';
    },
    onSearchInput(e) {
      this.searchText = e.detail;
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

      .event-output {
        margin-top: 8px;
        font-size: 14px;
        color: var(--font-color-secondary);
      }
    }
  }
}

.search-row {
  display: flex;
  flex-direction: column;

  :deep(flutter-cupertino-search-input) {
    margin-bottom: 12px;

    &:last-child {
      margin-bottom: 0;
    }

    &.custom-radius {
      border-radius: 20px;
    }

    &.custom-padding {
      padding: 12px 16px;
    }
  }
}
</style>