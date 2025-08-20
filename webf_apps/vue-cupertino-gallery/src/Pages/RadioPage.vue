<template>
  <div id="main">
    <webf-listview id="list">
      <div class="component-section">
        <div class="section-title">Radio Button</div>
        <div class="component-block">
          <!-- Basic Usage -->
          <div class="component-item">
            <div class="item-label">Basic Usage</div>
            <div class="control-group">
              <div class="control-row" v-for="option in basicOptions" :key="option.value">
                <flutter-cupertino-radio 
                  :val="option.value" 
                  :group-value="basicSelectedValue" 
                  @change="handleBasicChange"
                />
                <span>{{ option.label }}</span>
              </div>
            </div>
            <div class="value-display">Selected: {{ basicSelectedValue }}</div>
          </div>

          <!-- Custom Colors -->
          <div class="component-item">
            <div class="item-label">Custom Colors</div>
            <div class="control-group">
              <div class="control-row" v-for="option in colorOptions" :key="option.value">
                <flutter-cupertino-radio 
                  :val="option.value" 
                  :group-value="colorSelectedValue" 
                  :active-color="option.activeColor"
                  :focus-color="option.focusColor"
                  @change="handleColorChange"
                />
                <span>{{ option.label }}</span>
              </div>
            </div>
            <div class="value-display">Selected: {{ colorSelectedValue }}</div>
          </div>

          <!-- Disabled State -->
          <div class="component-item">
            <div class="item-label">Disabled State</div>
            <div class="control-group">
              <div class="control-row">
                <flutter-cupertino-radio val="A" group-value="A" disabled />
                <span>Disabled Selected</span>
              </div>
              <div class="control-row">
                <flutter-cupertino-radio val="B" group-value="A" disabled />
                <span>Disabled Unselected</span>
              </div>
            </div>
          </div>
          
          <!-- Checkmark Style -->
          <div class="component-item">
            <div class="item-label">Checkmark Style</div>
            <div class="control-group">
              <div class="control-row" v-for="option in checkmarkOptions" :key="option.value">
                <flutter-cupertino-radio 
                  :val="option.value" 
                  :group-value="checkmarkSelectedValue" 
                  use-checkmark-style
                  @change="handleCheckmarkChange"
                />
                <span>{{ option.label }}</span>
              </div>
            </div>
            <div class="value-display">Selected: {{ checkmarkSelectedValue }}</div>
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
      basicSelectedValue: 'A',
      basicOptions: [
        { label: 'Option A', value: 'A' },
        { label: 'Option B', value: 'B' },
        { label: 'Option C', value: 'C' },
      ],
      colorSelectedValue: 'Red',
      colorOptions: [
        { label: 'Red', value: 'Red', activeColor: '#ff0000', focusColor: '#ffcccc' },
        { label: 'Green', value: 'Green', activeColor: '#00ff00', focusColor: '#ccffcc' },
        { label: 'Blue', value: 'Blue', activeColor: '#0000ff', focusColor: '#ccccff' },
      ],
      checkmarkSelectedValue: 'C1',
      checkmarkOptions: [
        { label: 'Check 1', value: 'C1' },
        { label: 'Check 2', value: 'C2' },
      ],
    };
  },
  methods: {
    handleBasicChange(event) {
      console.log('Basic Radio changed:', event.detail);
      this.basicSelectedValue = event.detail;
    },
    handleColorChange(event) {
      console.log('Color Radio changed:', event.detail);
      this.colorSelectedValue = event.detail;
    },
    handleCheckmarkChange(event) {
      console.log('Checkmark Radio changed:', event.detail);
      this.checkmarkSelectedValue = event.detail;
    },
  },
};
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
      
      .control-group {
        margin-bottom: 8px;
      }
      
      .control-row {
        display: flex;
        align-items: center;
        margin-bottom: 8px;

        span {
           font-size: 14px;
           color: var(--font-color-primary);
        }
      }
      
      .value-display {
         margin-top: 8px;
         font-size: 14px;
         color: var(--font-color-secondary);
      }
    }
  }
}
</style> 