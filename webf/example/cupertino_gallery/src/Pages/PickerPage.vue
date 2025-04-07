<template>
  <div id="main">
    <webf-listview id="list">
      <div class="component-section">
        <div class="section-title">Picker</div>
        <div class="component-block">
          <!-- 基础用法 -->
          <div class="component-item">
            <div class="item-label">基础用法</div>
            <flutter-cupertino-button @click="showBasicPicker">
              选择城市
            </flutter-cupertino-button>
            <div class="picker-value" v-if="cityValue">
              已选择：{{ cityValue }}
            </div>
          </div>

          <!-- 多列选择 -->
          <div class="component-item">
            <div class="item-label">多列选择</div>
            <flutter-cupertino-button @click="showMultiPicker">
              选择日期
            </flutter-cupertino-button>
            <div class="picker-value" v-if="dateValue">
              已选择：{{ dateValue }}
            </div>
          </div>

          <!-- 联动选择 -->
          <div class="component-item">
            <div class="item-label">联动选择</div>
            <flutter-cupertino-button @click="showCascadePicker">
              选择地区
            </flutter-cupertino-button>
            <div class="picker-value" v-if="areaValue">
              已选择：{{ areaValue }}
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
              :label="year + '年'"
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
              :label="month + '月'"
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
      // 城市选择
      cities: ['北京', '上海', '广州', '深圳', '杭州', '南京', '成都', '武汉'],
      cityValue: '',

      // 日期选择
      years: Array.from({ length: 10 }, (_, i) => 2020 + i),
      months: Array.from({ length: 12 }, (_, i) => i + 1),
      selectedYear: '',
      selectedMonth: '',
      dateValue: '',

      // 地区选择
      provinces: ['广东省', '浙江省', '江苏省'],
      citiesMap: {
        '广东省': ['广州市', '深圳市', '东莞市'],
        '浙江省': ['杭州市', '宁波市', '温州市'],
        '江苏省': ['南京市', '苏州市', '无锡市'],
      },
      selectedProvince: '广东省',
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
        this.dateValue = `${this.selectedYear}年${this.selectedMonth}月`;
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
        this.areaValue = `${this.selectedProvince} ${this.selectedCity}`;
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