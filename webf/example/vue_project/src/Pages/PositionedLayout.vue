<template>
  <flutter-tab>
    <flutter-tab-item title="Relative">
      <position-example :style="{ position: 'relative', left: '20px' }"></position-example>
    </flutter-tab-item>
    <flutter-tab-item title="Absolute">
      <position-example :style="{ position: 'absolute', left: '100px', top: '110px' }"></position-example>
    </flutter-tab-item>
    <flutter-tab-item title="Fixed">
    </flutter-tab-item>
    <flutter-tab-item title="Sticky">
    </flutter-tab-item>
  </flutter-tab>
</template>
<script>
import PositionExample from '@/Components/PositionExample.vue';

export default {
  components: {
    PositionExample
  }
}
</script>

<style scoped></style>