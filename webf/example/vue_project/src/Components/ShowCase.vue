<template>
  <div class="container">
    <div class="example-choice-list">
      <div class="example-choice">
        <span>Position: Static</span>
      </div>
      <div class="example-choice">
        control item
      </div>
      <div class="example-choice">
        control item
      </div>
      <div class="example-choice">
        control item
      </div>
    </div>

    <div class="demo-container">
      <!-- <div :class="['box', position]" v-bind:style="positionStyles"></div>
      <p>
        In this demo you can control the <code>position</code> property for the yellow box.
      </p>
      <p>
        To see the effect of <code>sticky</code> positioning, select the
        <code>position: sticky</code> option and scroll this container.
      </p>
      <p>
        The element will scroll along with its container until it is at the top
        of the container (according to the offset specified). Then, it will
        stick in place.
      </p> -->
    </div>
  </div>
</template>

<style scoped>
.container {
  --focus-color: #fff;
  display: flex;
  flex-wrap: wrap;
  flex-direction: row;
}

.example-choice-list {
  width: 50%;
  background-color: red;
  padding: 1rem 2rem 1rem 1rem;
}

.example-choice {
  padding: 12px 0;
  background-color: #343434;
}

.example-choice-list button {
  padding: 0.5rem 1rem;
  border: 1px solid #ccc;
  background: #f9f9f9;
  cursor: pointer;
  border-radius: 5px;
}

.example-choice-list button.active {
  border-color: #007bff;
  color: #fff;
  background: #007bff;
}

.demo-container {
  flex: 1;
  width: 50%;
  border: 1px solid #ccc;
  overflow-y: auto;
  position: relative;
  background-color: blue;
}

.box {
  width: 50px;
  height: 50px;
  margin-bottom: 1rem;
}

.static {
  background: yellow;
  border: 2px solid red;
}

.relative {
  background: yellow;
  border: 2px solid green;
  position: relative;
}

.absolute {
  background: yellow;
  border: 2px solid blue;
  position: absolute;
}

.sticky {
  background: yellow;
  border: 2px solid orange;
  position: sticky;
}
</style>

<script>
export default {
  data() {
    return {
      position: 'static',
      positionOptions: ['static', 'relative', 'absolute', 'sticky'],
    };
  }
}
</script>