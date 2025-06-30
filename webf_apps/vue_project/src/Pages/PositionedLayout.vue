<template>
  <flutter-tab @tabchange="handleTabChange">
    <flutter-tab-item title="Relative">
      <position-example :style="{ position: 'relative' }"></position-example>
    </flutter-tab-item>
    <flutter-tab-item title="Absolute">
      <position-example :style="{ position: 'absolute' }"></position-example>
    </flutter-tab-item>
    <flutter-tab-item title="Fixed">
      <position-example v-if="tabIndex == 2" :style="{ position: 'fixed' }"></position-example>
    </flutter-tab-item>
    <flutter-tab-item title="Sticky">
    </flutter-tab-item>
  </flutter-tab>
</template>
<script>
import PositionExample from '@/Components/PositionExample.vue';

export default {
  data() {
    return {
      tabIndex: 0
    }
  },
  methods: {
    handleTabChange(e) {
      const tabIndex = e.detail;
      this.tabIndex = tabIndex;
    }
  },
  components: {
    PositionExample
  }
}
</script>

<style scoped></style>