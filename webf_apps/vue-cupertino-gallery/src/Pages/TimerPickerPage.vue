<template>
  <div id="main">
    <webf-listview id="list">
      <div class="component-section">
        <div class="section-title">Timer Picker</div>
        <div class="component-block">
          <!-- Default (hms) -->
          <div class="component-item">
            <div class="item-label">Default (hms)</div>
            <flutter-cupertino-timer-picker 
              mode="hms"
              :initial-timer-duration="durationHMS"
              @change="onHMSChange"
            />
            <div class="picker-value">Selected: {{ formatDuration(durationHMS) }}</div>
          </div>

          <!-- Hour/Minute (hm) -->
          <div class="component-item">
            <div class="item-label">Hour/Minute (hm)</div>
            <flutter-cupertino-timer-picker 
              mode="hm"
              :initial-timer-duration="durationHM"
              :minute-interval="15"
              @change="onHMChange"
            />
            <div class="picker-value">Selected: {{ formatDuration(durationHM) }} (15min intervals)</div>
          </div>

          <!-- Minute/Second (ms) -->
          <div class="component-item">
            <div class="item-label">Minute/Second (ms)</div>
            <flutter-cupertino-timer-picker 
              mode="ms"
              :initial-timer-duration="durationMS"
              :second-interval="10"
              @change="onMSChange"
            />
            <div class="picker-value">Selected: {{ formatDuration(durationMS) }} (10sec intervals)</div>
          </div>
          
          <!-- Custom Background -->
          <div class="component-item">
            <div class="item-label">Custom Background (Darker Example)</div>
            <flutter-cupertino-timer-picker 
              mode="hms"
              :initial-timer-duration="durationHMS" 
              background-color="#dddddd"
              @change="onHMSChange"
            />
            <div class="picker-value">Selected: {{ formatDuration(durationHMS) }}</div>
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
      durationHMS: 3665, // 1 hour, 1 minute, 5 seconds
      durationHM: 7200,  // 2 hours
      durationMS: 95,    // 1 minute, 35 seconds
    };
  },
  methods: {
    onHMSChange(event) {
      console.log('HMS Picker changed:', event.detail);
      this.durationHMS = event.detail;
    },
    onHMChange(event) {
      console.log('HM Picker changed:', event.detail);
      this.durationHM = event.detail;
    },
    onMSChange(event) {
      console.log('MS Picker changed:', event.detail);
      this.durationMS = event.detail;
    },
    // Helper to format duration seconds into HH:MM:SS
    formatDuration(totalSeconds) {
      if (typeof totalSeconds !== 'number' || totalSeconds < 0) {
        return '00:00:00';
      }
      const hours = Math.floor(totalSeconds / 3600);
      const minutes = Math.floor((totalSeconds % 3600) / 60);
      const seconds = totalSeconds % 60;
      return `${String(hours).padStart(2, '0')}:${String(minutes).padStart(2, '0')}:${String(seconds).padStart(2, '0')}`;
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
    }
  }
}

.picker-value {
  margin-top: 8px;
  font-size: 14px;
  color: var(--font-color-secondary);
}
</style> 