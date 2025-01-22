<template>
  <flutter-tab>
    <flutter-tab-item title="Relative">
      <position-example layout="relative" top="30px" left="30px"></position-example>
    </flutter-tab-item>
    <flutter-tab-item title="Absolute">
      <div>absolute</div>
    </flutter-tab-item>
    <flutter-tab-item title="Fixed">
      <div>Fixed</div>
    </flutter-tab-item>
    <flutter-tab-item title="Sticky">
      <div>Sticky</div>
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

<style scoped>
.container {
  /* color: var(--font-color); */
}

.demo-container {
  border: 1px solid #ccc;
  /* overflow-y: auto; */
  position: relative;
  background-color: blue;
}
</style>