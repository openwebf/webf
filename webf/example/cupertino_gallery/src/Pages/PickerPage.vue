<template>
  <div id="main">
    <webf-listview id="list">
      <div class="component-section">
        <div class="section-title">Picker</div>
        <div class="component-block">
          <!-- Basic Usage -->
          <div class="component-item">
            <div class="item-label">Basic Usage</div>
            <flutter-cupertino-button variant="filled" @click="showBasicPicker">
              Select City
            </flutter-cupertino-button>
            <div class="picker-value" v-if="cityValue">
              Selected: {{ cityValue }}
            </div>
          </div>

          <!-- Multi Column -->
          <div class="component-item">
            <div class="item-label">Multi Column</div>
            <flutter-cupertino-button variant="filled" @click="showMultiPicker">
              Select Date
            </flutter-cupertino-button>
            <div class="picker-value" v-if="dateValue">
              Selected: {{ dateValue }}
            </div>
          </div>

          <!-- Cascade Selection -->
          <div class="component-item">
            <div class="item-label">Cascade Selection</div>
            <flutter-cupertino-button variant="filled" @click="showCascadePicker">
              Select Region
            </flutter-cupertino-button>
            <div class="picker-value" v-if="areaValue">
              Selected: {{ areaValue }}
            </div>
          </div>
        </div>
      </div>

      <!-- Basic Picker -->
      <flutter-cupertino-modal-popup ref="basicPickerModal">
        <flutter-cupertino-picker
          height="200"
          item-height="44"
          @change="onCityChange"
        >
          <flutter-cupertino-picker-item
            v-for="city in cities"
            :key="city"
            :label="city"
            :val="city"
          />
        </flutter-cupertino-picker>
      </flutter-cupertino-modal-popup>

      <!-- Multi Picker -->
      <flutter-cupertino-modal-popup ref="multiPickerModal">
        <div class="multi-picker-container">
          <flutter-cupertino-picker
            height="200"
            item-height="44"
            @change="onYearChange"
          >
            <flutter-cupertino-picker-item
              v-for="year in years"
              :key="year"
              :label="year + ' Year'"
              :val="year"
            />
          </flutter-cupertino-picker>
          <flutter-cupertino-picker
            height="200"
            item-height="44"
            @change="onMonthChange"
          >
            <flutter-cupertino-picker-item
              v-for="month in months"
              :key="month"
              :label="month + ' Month'"
              :val="month"
            />
          </flutter-cupertino-picker>
        </div>
      </flutter-cupertino-modal-popup>

      <!-- Cascade Picker -->
      <flutter-cupertino-modal-popup ref="cascadePickerModal">
        <div class="multi-picker-container">
          <flutter-cupertino-picker
            height="200"
            item-height="44"
            @change="onProvinceChange"
          >
            <flutter-cupertino-picker-item
              v-for="province in provinces"
              :key="province"
              :label="province"
              :val="province"
            />
          </flutter-cupertino-picker>
          <flutter-cupertino-picker
            height="200"
            item-height="44"
            @change="onCityAreaChange"
          >
            <flutter-cupertino-picker-item
              v-for="city in currentCities"
              :key="city"
              :label="city"
              :val="city"
            />
          </flutter-cupertino-picker>
        </div>
      </flutter-cupertino-modal-popup>
    </webf-listview>
  </div>
</template>

<script>
export default {
  data() {
    return {
      // City selection
      cities: ['Beijing', 'Shanghai', 'Guangzhou', 'Shenzhen', 'Hangzhou', 'Nanjing', 'Chengdu', 'Wuhan'],
      cityValue: '',

      // Date selection
      years: Array.from({ length: 10 }, (_, i) => 2020 + i),
      months: Array.from({ length: 12 }, (_, i) => i + 1),
      selectedYear: '',
      selectedMonth: '',
      dateValue: '',

      // Region selection
      provinces: ['Guangdong', 'Zhejiang', 'Jiangsu'],
      citiesMap: {
        'Guangdong': ['Guangzhou', 'Shenzhen', 'Dongguan'],
        'Zhejiang': ['Hangzhou', 'Ningbo', 'Wenzhou'],
        'Jiangsu': ['Nanjing', 'Suzhou', 'Wuxi'],
      },
      selectedProvince: 'Guangdong',
      selectedCity: '',
      areaValue: '',
    }
  },
  computed: {
    currentCities() {
      return this.citiesMap[this.selectedProvince] || [];
    }
  },
  methods: {
    showBasicPicker() {
      this.$refs.basicPickerModal.show();
    },
    showMultiPicker() {
      this.$refs.multiPickerModal.show();
    },
    showCascadePicker() {
      this.$refs.cascadePickerModal.show();
    },
    onCityChange(e) {
      this.cityValue = e.detail;
    },
    onYearChange(e) {
      this.selectedYear = e.detail;
      this.updateDateValue();
    },
    onMonthChange(e) {
      this.selectedMonth = e.detail;
      this.updateDateValue();
    },
    updateDateValue() {
      if (this.selectedYear && this.selectedMonth) {
        this.dateValue = `${this.selectedYear}-${String(this.selectedMonth).padStart(2, '0')}`;
      }
    },
    onProvinceChange(e) {
      this.selectedProvince = e.detail;
      this.selectedCity = this.currentCities[0];
      this.updateAreaValue();
    },
    onCityAreaChange(e) {
      this.selectedCity = e.detail;
      this.updateAreaValue();
    },
    updateAreaValue() {
      if (this.selectedProvince && this.selectedCity) {
        this.areaValue = `${this.selectedProvince}, ${this.selectedCity}`;
      }
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

.multi-picker-container {
  display: flex;

  :deep(flutter-cupertino-picker) {
    flex: 1;
  }
}
</style> 