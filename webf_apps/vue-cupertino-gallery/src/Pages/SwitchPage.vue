<template>
  <div id="main">
    <webf-listview id="list">
      <div class="component-section">
        <div class="section-title">Switch</div>
        <div class="component-block">
          <!-- Basic Usage -->
          <div class="component-item">
            <div class="item-label">Basic Usage</div>
            <div class="switch-row">
              <flutter-cupertino-switch checked="true" @change="handleSwitchChange" />
            </div>
          </div>

          <!-- Custom Colors -->
          <div class="component-item">
            <div class="item-label">Custom Colors</div>
            <div class="switch-row">
              <flutter-cupertino-switch 
                checked="true" 
                active-color="#07c160"
                inactive-color="#f5f5f5"
              />
              <flutter-cupertino-switch 
                checked="true" 
                active-color="#ff6b81"
                inactive-color="#ff00ff"
              />
            </div>
          </div>

          <!-- Disabled State -->
          <div class="component-item">
            <div class="item-label">Disabled State</div>
            <div class="switch-row">
              <flutter-cupertino-switch checked="true" disabled />
              <flutter-cupertino-switch checked="false" disabled />
            </div>
          </div>
        </div>
      </div>
    </webf-listview>
  </div>
</template>

<script>
export default {
  methods: {
    handleSwitchChange(value) {
      console.log('switch value changed:', value);
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

.switch-row {
  display: flex;
  align-items: center;
  gap: 20px;
}
</style>
