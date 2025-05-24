<template>
  <div id="main">
    <webf-listview id="list">
      <div class="component-section">
        <div class="section-title">Textarea</div>
        <div class="component-block">
          <!-- Basic Usage -->
          <div class="component-item">
            <div class="item-label">Basic Usage</div>
            <flutter-cupertino-textarea placeholder="Enter content" />
          </div>

          <!-- Two-way Binding -->
          <div class="component-item">
            <div class="item-label">Two-way Binding</div>
            <flutter-cupertino-textarea
              :val="textareaContent"
              placeholder="Enter content"
              @input="onTextareaChange"
            />
            <div class="event-output">
              Current content: {{ textareaContent }}
            </div>
          </div>

          <!-- Rows Control -->
          <div class="component-item">
            <div class="item-label">Rows Control</div>
            <div class="textarea-row">
              <flutter-cupertino-textarea
                placeholder="2 rows (default)"
                :rows="2"
              />
              <flutter-cupertino-textarea
                placeholder="4 rows"
                :rows="4"
              />
            </div>
          </div>

          <!-- Auto Size -->
          <div class="component-item">
            <div class="item-label">Auto Size</div>
            <flutter-cupertino-textarea
              placeholder="Auto size textarea"
              auto-size
            />
          </div>

          <!-- Maximum Length -->
          <div class="component-item">
            <div class="item-label">Maximum Length with Counter</div>
            <flutter-cupertino-textarea
              placeholder="Maximum 100 characters"
              :max-length="100"
              show-count
            />
          </div>

          <!-- Disabled State -->
          <div class="component-item">
            <div class="item-label">Disabled State</div>
            <div class="textarea-row">
              <flutter-cupertino-textarea
                val="This textarea is disabled"
                disabled
              />
              <flutter-cupertino-textarea
                val="This textarea is read-only"
                readonly
              />
            </div>
          </div>

          <!-- Custom Styles -->
          <div class="component-item">
            <div class="item-label">Custom Styles</div>
            <div class="textarea-row">
              <flutter-cupertino-textarea
                placeholder="Transparent background"
                transparent
              />
              <flutter-cupertino-textarea
                placeholder="Custom border radius"
                class="custom-radius"
              />
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
      textareaContent: 'Initial textarea content'
    }
  },
  methods: {
    onTextareaChange(e) {
      this.textareaContent = e.detail;
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

.textarea-row {
  display: flex;
  flex-wrap: wrap;

  :deep(flutter-cupertino-textarea) {
    flex: 1;
    min-width: 200px;
    margin-bottom: 12px;

    &.custom-radius {
      border-radius: 20px;
    }
  }
}

.event-output {
  margin-top: 8px;
  font-size: 14px;
  color: var(--font-color-secondary);
}
</style>
