<template>
  <div id="example-element-container">
    <p>In this demo the yellow box is set with 'position: {{ layout }}'.</p>
    <div class="box-group">
      <div class="box"></div>
      <div class="box" id="example-element" :style="{ 'position': layout, 'top': top, left: left }"></div>
      <div class="box"></div>
    </div>
    <pre style="margin-left: 0">
      <code style="margin-left: 0">
        position: {{ layout }};
        top: {{ top }};
        left: {{ left }};
      </code>
    </pre>
  </div>
</template>

<script>
export default {
  props: {
    layout: String,
    top: String,
    left: String
  }
}
</script>

<style scoped>
.box-group {
  display: flex;
  flex-direction: row;
  justify-content: space-around;
}

.box {
  background-color: rgba(0, 0, 255, .2);
  border: 3px solid #00f;
  width: 65px;
  height: 65px;
}
</style>