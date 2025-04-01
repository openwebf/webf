<template>
  <div id="main">
    <webf-listview id="list">
      <div class="component-section">
        <div class="section-title">Button</div>
        <div class="component-block">
          <!-- Button Variants -->
          <div class="component-item">
            <div class="item-label">Button Variants</div>
            <div class="button-row">
              <flutter-cupertino-button variant="filled">Filled Button</flutter-cupertino-button>
              <flutter-cupertino-button variant="tinted">Tinted Button</flutter-cupertino-button>
              <flutter-cupertino-button variant="plain">Plain Button</flutter-cupertino-button>
            </div>
          </div>

          <!-- Button Sizes -->
          <div class="component-item">
            <div class="item-label">Button Sizes</div>
            <div class="button-row">
              <flutter-cupertino-button size="small" variant="filled">Small Button</flutter-cupertino-button>
              <flutter-cupertino-button size="large" variant="filled">Large Button</flutter-cupertino-button>
            </div>
          </div>

          <!-- Custom Colors -->
          <div class="component-item">
            <div class="item-label">Custom Colors</div>
            <div class="button-row">
              <flutter-cupertino-button variant="tinted" color="#FFFF00">Custom Color</flutter-cupertino-button>
              <flutter-cupertino-button variant="filled" disabled>Disabled Button</flutter-cupertino-button>
            </div>
          </div>

          <!-- Custom Styles -->
          <div class="component-item">
            <div class="item-label">Custom Styles</div>
            <div class="button-row">
              <flutter-cupertino-button variant="filled" class="custom-padding">Custom
                Padding</flutter-cupertino-button>
              <flutter-cupertino-button variant="filled" class="custom-radius">Custom Radius</flutter-cupertino-button>
              <flutter-cupertino-button variant="filled" class="custom-size">Custom Size</flutter-cupertino-button>
            </div>
          </div>

          <!-- Press Effect -->
          <div class="component-item">
            <div class="item-label">Press Effect</div>
            <div class="button-row">
              <flutter-cupertino-button variant="filled" pressed-opacity="0.2">Light Press
                Effect</flutter-cupertino-button>
              <flutter-cupertino-button variant="filled" pressed-opacity="0.8">Heavy Press
                Effect</flutter-cupertino-button>
            </div>
          </div>

          <!-- Disabled State -->
          <div class="component-item">
            <div class="item-label">Disabled State</div>
            <div class="button-row">
              <flutter-cupertino-button variant="plain" disabled>Plain Disabled</flutter-cupertino-button>
              <flutter-cupertino-button variant="filled" disabled>Filled Disabled</flutter-cupertino-button>
              <flutter-cupertino-button variant="tinted" disabled>Tinted Disabled</flutter-cupertino-button>
            </div>
          </div>
        </div>
      </div>
    </webf-listview>
  </div>
</template>

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

      .button-row {
        display: flex;
        flex-wrap: wrap;
        align-items: center;

        :deep(flutter-cupertino-button) {
          margin-right: 12px;
          margin-bottom: 12px;

          &:last-child {
            margin-right: 0;
          }

          &.custom-padding {
            padding: 20px 32px;
          }

          &.custom-radius {
            border-radius: 20px;
          }

          &.custom-size {
            min-height: 60px;
            width: 120px;
          }
        }
      }
    }
  }
}
</style>
