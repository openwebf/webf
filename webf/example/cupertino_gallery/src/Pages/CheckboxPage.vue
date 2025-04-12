<template>
  <div id="main">
    <webf-listview id="list">
      <div class="component-section">
        <div class="section-title">Checkbox</div>
        <div class="component-block">
          <!-- Basic Usage -->
          <div class="component-item">
            <div class="item-label">Basic Usage</div>
            <div class="control-row">
              <flutter-cupertino-checkbox :val="basicValue" @change="handleBasicChange" />
              <span>Value: {{ basicValue }}</span>
            </div>
          </div>
          
          <!-- Custom Colors -->
          <div class="component-item">
            <div class="item-label">Custom Colors</div>
            <div class="control-row">
              <flutter-cupertino-checkbox :val="true" active-color="#07c160" />
              <span>Active Color (Green)</span>
            </div>
            <div class="control-row">
              <flutter-cupertino-checkbox :val="true" active-color="#ff6b81" check-color="#000000" />
              <span>Check Color (Black on Pink Background)</span>
            </div>
            <div class="control-row">
              <flutter-cupertino-checkbox :val="true" fill-color-selected="#ffddcc" check-color="#aa0000" />
              <span>Fill Color Selected (Peach with Red Check)</span>
            </div>
            <div class="control-row">
              <flutter-cupertino-checkbox :val="true" disabled fill-color-disabled="#bbbbff" />
              <span>Fill Color Disabled (Light Blue)</span>
            </div>
            <div class="control-row">
              <flutter-cupertino-checkbox :val="false" focus-color="#ff9900" />
              <span>Focus Color (Orange - Requires Focus)</span>
            </div>
          </div>

          <!-- Disabled State -->
          <div class="component-item">
            <div class="item-label">Disabled State</div>
            <div class="control-row">
              <flutter-cupertino-checkbox :val="true" disabled />
              <flutter-cupertino-checkbox :val="false" disabled />
              <!-- Removed tristate disabled example -->
              <!-- <flutter-cupertino-checkbox :val="null" tristate disabled /> -->
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
      basicValue: false,
      // tristateValue: null, // Removed tristate data
    };
  },
  methods: {
    handleBasicChange(event) {
      console.log('Basic Checkbox changed:', event.detail);
      this.basicValue = event.detail;
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
      
      .control-row {
        display: flex;
        align-items: center;
        gap: 16px; // Add some gap between controls
        margin-bottom: 8px;

        span {
           font-size: 14px;
           color: var(--font-color-primary);
        }
        
        button {
           padding: 4px 8px;
           font-size: 12px;
           // Add basic button styling if needed
        }
      }
    }
  }
}
</style> 