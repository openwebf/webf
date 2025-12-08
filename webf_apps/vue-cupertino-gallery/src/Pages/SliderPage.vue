<template>
  <div id="main">
    <webf-listview id="list">
      <div class="component-section">
        <div class="section-title">Slider</div>
        <div class="component-block">
          <!-- Basic Slider -->
          <div class="component-item">
            <div class="item-label">Basic Slider</div>
            <div class="slider-container">
              <flutter-cupertino-slider
                :val="basicValue"
                @change="onBasicChange"
              />
              <div class="value-display">Value: {{ basicValue.toFixed(0) }}</div>
            </div>
          </div>

          <!-- Custom Range -->
          <div class="component-item">
            <div class="item-label">Custom Range</div>
            <div class="slider-container">
              <flutter-cupertino-slider
                :val="rangeValue"
                :min="-100"
                :max="100"
                @change="onRangeChange"
              />
              <div class="value-display">Value: {{ rangeValue.toFixed(0) }}</div>
            </div>
          </div>

          <!-- With Steps -->
          <div class="component-item">
            <div class="item-label">With Steps</div>
            <div class="slider-container">
              <flutter-cupertino-slider
                :val="stepValue"
                :step="10"
                @change="onStepChange"
              />
              <div class="value-display">Value: {{ stepValue.toFixed(0) }}</div>
            </div>
          </div>

          <!-- Disabled Slider -->
          <div class="component-item">
            <div class="item-label">Disabled Slider</div>
            <div class="slider-container">
              <flutter-cupertino-slider
                :val="50"
                disabled
              />
            </div>
          </div>

          <!-- With Events -->
          <div class="component-item">
            <div class="item-label">With Events</div>
            <div class="slider-container">
              <flutter-cupertino-slider
                :val="eventValue"
                @change="onEventChange"
                @changestart="onChangeStart"
                @changeend="onChangeEnd"
              />
              <div class="value-display">Value: {{ eventValue.toFixed(0) }}</div>
              <div class="event-log">Last Event: {{ lastEvent }}</div>
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
      basicValue: 50,
      rangeValue: 0,
      stepValue: 40,
      eventValue: 50,
      lastEvent: 'None'
    }
  },
  methods: {
    onBasicChange(event) {
      this.basicValue = event.detail;
    },
    onRangeChange(event) {
      this.rangeValue = event.detail;
    },
    onStepChange(event) {
      this.stepValue = event.detail;
    },
    onEventChange(event) {
      this.eventValue = event.detail;
      this.lastEvent = 'Change: ' + event.detail.toFixed(0);
    },
    onChangeStart(event) {
      this.lastEvent = 'Start: ' + event.detail.toFixed(0);
    },
    onChangeEnd(event) {
      this.lastEvent = 'End: ' + event.detail.toFixed(0);
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

      .slider-container {
        padding: 8px 0;

        .value-display {
          margin-top: 8px;
          font-size: 14px;
          color: var(--font-color-secondary);
        }

        .event-log {
          margin-top: 4px;
          font-size: 14px;
          color: var(--font-color-secondary);
          font-style: italic;
        }
      }
    }
  }
}
</style>
