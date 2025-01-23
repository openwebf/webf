<template>
  <div id="example-element-container">
    <p>In this demo the yellow box is set with 'position: {{ style['position'] }}'</p>
    <div class="box-group">
      <div class="box">A</div>
      <div class="box" id="example-element"
        :style="style">B</div>
      <div class="box">C</div>
    </div>
    <div>
      <p>Styles: </p>
      <div>position: {{ style['position'] }}</div>
      <div v-if="'top' in style">top: {{ style['top'] }}</div>
      <div v-if="'left' in style">left: {{ style['left'] }}</div>
      <div v-if="'right' in style">right: {{ style['right'] }}</div>
      <div v-if="'bottom' in style">bottom: {{ style['bottom'] }}</div>
    </div>
  </div>
</template>

<script>
export default {
  props: {
    style: Object
  }
}
</script>

<style scoped>
#example-element-container {
  position: relative;
  padding: 40px;
  border: 1px solid red;
}

.box {
  background-color: rgba(0, 0, 255, .2);
  border: 3px solid #00f;
  width: 65px;
  height: 65px;
  margin-top: 10px;
  text-align: center;
  line-height: 65px;
  font-size: 30px;
  z-index: 1;
  color: var(--font-color);
}

#example-element {
  background-color: rgba(251, 235, 78);
}
</style>