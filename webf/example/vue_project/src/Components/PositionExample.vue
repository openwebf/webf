<template>
  <div id="example-element-container">
    <p>In this demo the yellow box is set with 'position: {{ style['position'] }}'</p>
    <div class="box-group">
      <div class="box">A</div>
      <div class="box" id="example-element" :style="computedStyle">B</div>
      <div class="box">C</div>
    </div>
    <div class="controls">
      <div class="control-panel">
        <div>
          <span>Top: </span>
          <input type="checkbox" v-model="enableTop" @change="onPanelChange" />
        </div>
        <div>
          <span>left: </span>
          <input type="checkbox" v-model="enableLeft" />
        </div>
        <div>
          <span>right: </span>
          <input type="checkbox" v-model="enableRight" />
        </div>
        <div>
          <span>bottom: </span>
          <input type="checkbox" v-model="enableBottom" />
        </div>
      </div>
      <div class="control-item" v-if="enableTop">
        <div class="control-title">top: </div>
        <flutter-slider max="100" min="-100" :val="top" class="control-slider"
          @change="onControlChange($event, 'top')"></flutter-slider>
        <div class="control-result">{{ top }}</div>
      </div>
      <div class="control-item" v-if="enableLeft">
        <div class="control-title">left: </div>
        <flutter-slider class="control-slider" :val="left" @change="onControlChange($event, 'left')"></flutter-slider>
        <div class="control-result">{{ left }}</div>
      </div>
      <div class="control-item" v-if="enableRight">
        <div class="control-title">right: </div>
        <flutter-slider class="control-slider" :val="right"
          @change="onControlChange($event, 'right')"></flutter-slider>
        <div class="control-result">{{ right }}</div>
      </div>
      <div class="control-item" v-if="enableBottom">
        <div class="control-title">bottom: </div>
        <flutter-slider class="control-slider" :val="bottom"
          @change="onControlChange($event, 'bottom')"></flutter-slider>
        <div class="control-result">{{ bottom }}</div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  props: {
    style: Object
  },
  created() {
    this.top = this.style['top'];
    this.left = this.style['left'];
    this.right = this.style['right'];
    this.bottom = this.style['bottom'];
  },
  data() {
    return {
      top: undefined,
      left: undefined,
      right: undefined,
      bottom: undefined,
      enableTop: true,
      enableLeft: true,
      enableRight: false,
      enableBottom: false
    }
  },
  computed: {
    computedStyle() {
      const style = {
        'position': this.$props.style['position'],
        zIndex: 100
      };
      if (this.top !== null) style.top = this.top + 'px';
      if (this.left !== null) style.left = this.left + 'px';
      if (this.right !== null) style.right = this.right + 'px';
      if (this.bottom !== null) style.bottom = this.bottom + 'px';
      return style;
    },
  },
  methods: {
    onControlChange(e, label) {
      switch (label) {
        case 'top':
          this.top = e.detail;
          break;
        case 'left':
          this.left = e.detail;
          break;
        case 'right':
          this.right = e.detail;
          break;
        case 'bottom':
          this.bottom = e.detail;
          break;
      }
    },
    onPanelChange(e) {
      console.log('check', e.target.checked);
    }
  }
}
</script>

<style scoped>
#example-element-container {
  position: relative;
  padding: 10px;
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

.controls {
  margin-top: 50px;
  width: 100%;
}

.control-panel {
  display: flex;
  flex-direction: row;
  justify-content: space-around;
}

.control-panel span {
  line-height: 30px;
}

.control-item {
  display: flex;
}

.control-item .control-title {
  flex: 1;
  text-align: center;
  line-height: 50px;
}

.control-item .control-result {
  flex: 1;
  text-align: center;
  line-height: 50px;
}

.control-slider {
  flex: 2;
  margin-left: 10px;
  height: 50px;
}
</style>