<template>
  <div id="main">
    <webf-listview id="list">
      <div class="component-section">
        <div class="section-title">Cupertino Form Row</div>
        <div class="component-block">

          <!-- Basic Usage with Input -->
          <div class="component-item">
            <div class="item-label">Basic Usage</div>
            <flutter-cupertino-form-row>
              <span slotName="prefix">Label</span>
              <flutter-cupertino-input placeholder="Enter value" />
            </flutter-cupertino-form-row>
          </div>

          <!-- With Switch -->
          <div class="component-item">
            <div class="item-label">With Switch</div>
            <flutter-cupertino-form-row>
              <span slotName="prefix">Enable Feature</span>
              <flutter-cupertino-switch :checked="switchValue" @change="switchValue = $event.detail" />
            </flutter-cupertino-form-row>
          </div>

          <!-- With Slider -->
          <div class="component-item">
            <div class="item-label">With Slider</div>
            <flutter-cupertino-form-row>
              <span slotName="prefix">Volume</span>
              <flutter-cupertino-slider 
                :value="sliderValue" 
                min="0" 
                max="100" 
                @input="sliderValue = $event.detail"
                style="flex: 1;"
              ></flutter-cupertino-slider>
              <span>{{ sliderValue.toFixed(0) }}</span> <!-- Display slider value -->
            </flutter-cupertino-form-row>
          </div>

          <!-- With Helper Text -->
          <div class="component-item">
            <div class="item-label">With Helper Text</div>
            <flutter-cupertino-form-row>
              <span slotName="prefix">Username</span>
              <flutter-cupertino-input placeholder="Enter username" />
              <span slotName="helper">Username must be unique.</span>
            </flutter-cupertino-form-row>
          </div>

          <!-- With Error Text -->
          <div class="component-item">
            <div class="item-label">With Error Text</div>
            <flutter-cupertino-form-row>
              <span slotName="prefix">Password</span>
              <flutter-cupertino-input type="password" placeholder="Enter password" />
              <!-- Simple text in error slot gets default red styling -->
              <span slotName="error" style="color: red; font-style: italic;">Password is required.</span> 
            </flutter-cupertino-form-row>
          </div>

           <!-- With Custom Styled Error -->
          <div class="component-item">
            <div class="item-label">With Custom Styled Error</div>
            <flutter-cupertino-form-row>
              <span slotName="prefix">Confirm Password</span>
              <flutter-cupertino-input type="password" placeholder="Confirm password" />
              <span slotName="error" style="color: orange; font-style: italic;">Passwords do not match!</span> 
            </flutter-cupertino-form-row>
          </div>

          <!-- Custom Padding -->
          <div class="component-item">
            <div class="item-label">Custom Padding</div>
            <flutter-cupertino-form-row style="padding: 20px 5px;">
              <span slotName="prefix">Padded Row</span>
              <flutter-cupertino-input placeholder="Value" />
            </flutter-cupertino-form-row>
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
      switchValue: false,
      sliderValue: 50,
    }
  },
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
      margin-bottom: 16px; // Reduced margin between items

      &:last-child {
        margin-bottom: 0;
      }

      .item-label {
        font-size: 14px;
        color: var(--font-color-secondary);
        margin-bottom: 12px;
      }
      
      // Style prefix span specifically if needed
      :deep(span[slotName="prefix"]) {
        margin-right: 8px; // Add some space after prefix
        color: var(--font-color-secondary); // Example style
      }

      :deep(span[slotName="helper"]) {
        font-size: 12px;
        color: var(--font-color-secondary);
        // padding-top: 4px; // FormRow handles spacing
      }
      
      :deep(span[slotName="error"]) {
         font-size: 12px;
         // Add default error color here via CSS
         color: red; 
      }
    }
  }
}
</style>
