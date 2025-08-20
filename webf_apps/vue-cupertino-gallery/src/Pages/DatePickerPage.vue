<template>
  <div id="main">
    <webf-listview id="list">
      <div class="component-section">
        <div class="section-title">Date Picker</div>
        <div class="component-block">
          <!-- Date Selection -->
          <div class="component-item">
            <div class="item-label">Date Selection</div>
            <flutter-cupertino-date-picker
              mode="date"
              height="200"
              value="2024-03-14"
              minimum-date="2024-01-01"
              maximum-date="2024-12-31"
              show-day-of-week="true"
              date-order="ymd"
              @change="onDateChange"
            />
            <div class="picker-value" v-if="dateValue">
              Selected: {{ formatDate(dateValue) }}
            </div>
          </div>

          <!-- Time Selection -->
          <div class="component-item">
            <div class="item-label">Time Selection</div>
            <flutter-cupertino-date-picker
              mode="time"
              height="200"
              value="2024-03-14T10:00:00"
              use-24h="true"
              minute-interval="5"
              @change="onTimeChange"
            />
            <div class="picker-value" v-if="timeValue">
              Selected: {{ timeValue }}
            </div>
          </div>

          <!-- Date and Time Selection -->
          <div class="component-item">
            <div class="item-label">Date and Time Selection</div>
            <flutter-cupertino-date-picker
              mode="dateAndTime"
              height="200"
              value="2024-03-14T10:00:00"
              minimum-year="2020"
              maximum-year="2030"
              use-24h="true"
              @change="onDateTimeChange"
            />
            <div class="picker-value" v-if="dateTimeValue">
              Selected: {{ formatDateTime(dateTimeValue) }}
            </div>
          </div>

          <!-- Popup Picker -->
          <div class="component-item">
            <div class="item-label">Popup Picker</div>
            <flutter-cupertino-button variant="filled" @click="showCustomPicker">
              Select Date (with restrictions)
            </flutter-cupertino-button>
            <div class="picker-value" v-if="customValue">
              Selected: {{ formatDate(customValue) }}
            </div>
          </div>
        </div>
      </div>

      <!-- Custom Picker Modal -->
      <flutter-cupertino-modal-popup
        ref="customPickerModal"
        :show="showModalPopup"
      >
        <flutter-cupertino-date-picker
          mode="date"
          :value="customValue"
          :minimum-date="minDate"
          :maximum-date="maxDate"
          show-day-of-week="true"
          @change="onCustomChange"
        />
      </flutter-cupertino-modal-popup>
    </webf-listview>
  </div>
</template>

<script>
export default {
  data() {
    const today = new Date();
    const minDate = new Date();
    minDate.setDate(today.getDate() - 7);
    const maxDate = new Date();
    maxDate.setDate(today.getDate() + 7);

    return {
      showModalPopup: false,
      dateValue: '',
      timeValue: '',
      dateTimeValue: '',
      customValue: '',
      minDate: minDate.toISOString(),
      maxDate: maxDate.toISOString(),
    }
  },
  methods: {
    showCustomPicker() {
      // this.$refs.customPickerModal.show();
      this.showModalPopup = true;
    },
    onDateChange(e) {
      this.dateValue = e.detail;
    },
    onTimeChange(e) {
      this.timeValue = e.detail;
    },
    onDateTimeChange(e) {
      this.dateTimeValue = e.detail;
    },
    onCustomChange(e) {
      this.customValue = e.detail;
    },
    formatDate(dateStr) {
      const date = new Date(dateStr);
      return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}`;
    },
    formatDateTime(dateStr) {
      const date = new Date(dateStr);
      return `${this.formatDate(dateStr)} ${String(date.getHours()).padStart(2, '0')}:${String(date.getMinutes()).padStart(2, '0')}`;
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

.picker-value {
  margin-top: 8px;
  font-size: 14px;
  color: var(--font-color-secondary);
}
</style> 