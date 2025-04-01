<template>
  <div id="main">
    <webf-listview id="list">
      <div class="component-section">
        <div class="section-title">Search Input</div>
        <div class="component-block">
          <!-- Basic Usage -->
          <div class="component-item">
            <div class="item-label">Basic Usage</div>
            <flutter-cupertino-search-input placeholder="Enter search content" />
          </div>

          <!-- Default Value -->
          <div class="component-item">
            <div class="item-label">Default Value</div>
            <flutter-cupertino-search-input 
              val="Default search content" 
              placeholder="Enter search content" 
            />
          </div>

          <!-- Two-way Binding -->
          <div class="component-item">
            <div class="item-label">Two-way Binding</div>
            <flutter-cupertino-search-input 
              :val="searchText"
              placeholder="Enter search content"
              @input="onSearchInput"
            />
            <div class="event-output">
              Current input: {{ searchText }}
            </div>
          </div>

          <!-- Disabled State -->
          <div class="component-item">
            <div class="item-label">Disabled State</div>
            <flutter-cupertino-search-input 
              placeholder="Disabled search input" 
              disabled
            />
          </div>

          <!-- Input Types -->
          <div class="component-item">
            <div class="item-label">Input Types</div>
            <div class="search-row">
              <flutter-cupertino-search-input 
                type="number"
                placeholder="Number input" 
              />
              <flutter-cupertino-search-input 
                type="tel"
                placeholder="Phone number" 
              />
              <flutter-cupertino-search-input 
                type="url"
                placeholder="URL" 
              />
            </div>
          </div>

          <!-- Custom Icons -->
          <div class="component-item">
            <div class="item-label">Custom Icons</div>
            <div class="search-row">
              <flutter-cupertino-search-input 
                prefix-icon="search"
                suffix-icon="xmark_circle_fill"
                placeholder="Default icons" 
              />
              <flutter-cupertino-search-input 
                item-color="#007AFF"
                item-size="24"
                placeholder="Custom icon color and size" 
              />
            </div>
          </div>

          <!-- Clear Button Display Mode -->
          <div class="component-item">
            <div class="item-label">Clear Button Display Mode</div>
            <div class="search-row">
              <flutter-cupertino-search-input 
                suffix-mode="never"
                placeholder="Never show clear button" 
              />
              <flutter-cupertino-search-input 
                suffix-mode="always"
                placeholder="Always show clear button" 
              />
              <flutter-cupertino-search-input 
                suffix-mode="editing"
                placeholder="Show clear button while editing" 
              />
            </div>
          </div>

          <!-- Custom Styles -->
          <div class="component-item">
            <div class="item-label">Custom Styles</div>
            <div class="search-row">
              <flutter-cupertino-search-input 
                placeholder="Custom border radius" 
                class="custom-radius" 
              />
              <flutter-cupertino-search-input 
                placeholder="Custom padding" 
                class="custom-padding" 
              />
            </div>
          </div>

          <!-- Event Handling -->
          <div class="component-item">
            <div class="item-label">Event Handling</div>
            <flutter-cupertino-search-input 
              placeholder="Input triggers events" 
              @input="onInput"
              @search="onSearch"
              @clear="onClear"
            />
            <div class="event-output" v-if="inputValue">
              Input content: {{ inputValue }}
            </div>
            <div class="event-output" v-if="searchValue">
              Search content: {{ searchValue }}
            </div>
            <div class="event-output" v-if="isCleared">
              Search input cleared
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
      searchText: 'Initial search content'
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