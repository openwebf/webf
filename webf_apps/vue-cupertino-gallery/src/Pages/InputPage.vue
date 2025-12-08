<template>
  <div id="main">
    <webf-listview id="list">
      <div class="component-section">
        <div class="section-title">Input</div>
        <div class="component-block">
          <!-- Basic Usage -->
          <div class="component-item">
            <div class="item-label">Basic Usage</div>
            <flutter-cupertino-input placeholder="Enter content" />
          </div>

          <!-- Two-way Binding -->
          <div class="component-item">
            <div class="item-label">Two-way Binding</div>
            <flutter-cupertino-input 
              :val="inputText"
              placeholder="Enter content"
              @input="onInputChange"
            />
            <div class="event-output">
              Current input: {{ inputText }}
            </div>
          </div>

          <!-- Input Types -->
          <div class="component-item">
            <div class="item-label">Input Types</div>
            <div class="input-row">
              <flutter-cupertino-input type="text" placeholder="Text input" />
              <flutter-cupertino-input type="password" placeholder="Password input" />
              <flutter-cupertino-input type="number" placeholder="Number input" />
              <flutter-cupertino-input type="tel" placeholder="Phone input" />
              <flutter-cupertino-input type="email" placeholder="Email input" />
              <flutter-cupertino-input type="url" placeholder="URL input" />
            </div>
          </div>

          <!-- Clear Button -->
          <div class="component-item">
            <div class="item-label">Clear Button</div>
            <flutter-cupertino-input placeholder="Input text to show clear button" clearable />
          </div>

          <!-- Maximum Length -->
          <div class="component-item">
            <div class="item-label">Maximum Length</div>
            <flutter-cupertino-input placeholder="Maximum 10 characters" maxlength="10" />
          </div>

          <!-- Disabled State -->
          <div class="component-item">
            <div class="item-label">Disabled State</div>
            <div class="input-row">
              <flutter-cupertino-input val="This is disabled" disabled />
              <flutter-cupertino-input val="This is read-only" readonly />
            </div>
          </div>

          <!-- Custom Styles -->
          <div class="component-item">
            <div class="item-label">Custom Styles</div>
            <div class="input-row">
              <flutter-cupertino-input 
                placeholder="Custom height" 
                class="custom-height" 
              />
              <flutter-cupertino-input 
                placeholder="Custom border radius" 
                class="custom-radius" 
              />
              <flutter-cupertino-input 
                placeholder="Custom padding" 
                class="custom-padding" 
              />
              <flutter-cupertino-input 
                placeholder="Right aligned text" 
                class="text-right"
              />
            </div>
          </div>

          <!-- Prefix and Suffix -->
          <div class="component-item">
            <div class="item-label">Prefix and Suffix</div>
            <flutter-cupertino-input placeholder="Input with prefix">
              <span slotName="prefix">$</span>
            </flutter-cupertino-input>
            <flutter-cupertino-input placeholder="Input with suffix" style="margin-top: 12px;">
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
      inputText: 'Initial input content'
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
