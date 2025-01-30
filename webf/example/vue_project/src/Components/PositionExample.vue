<template>
  <webf-listview id="example-element-container">
    <p>In this demo the yellow box is set with 'position: {{ style['position'] }}'</p>
    <div class="box-group">
      <div class="box">A</div>
      <div class="box" id="example-element" :style="computedStyle" @click="onBClicked">B</div>
      <div class="box">C</div>
    </div>
    <div class="controls">
      <div class="control-panel">
        <div>
          <span>Top: </span>
          <input type="checkbox" v-model="enableTop" />
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
      <div class="control-buttons" v-if="style['position'] == 'absolute'">
        <flutter-button @press="onMarginAutoButtonClick('horizontal')">Horizontal Center</flutter-button>
        <flutter-button @press="onMarginAutoButtonClick('vertical')">Vertical Center</flutter-button>
      </div>
      <div class="control-item" v-if="enableTop">
        <div class="control-title">top: </div>
        <flutter-slider max="100" min="-100" :val="top" class="control-slider"
          @change="onControlChange($event, 'top')"></flutter-slider>
        <div class="control-result">{{ top }} {{  topPercentage ? '%' : 'px' }}</div>
        <flutter-switch :selected="topPercentage" @change="onSwitchChange($event, 'top')"></flutter-switch>
      </div>
      <div class="control-item" v-if="enableLeft">
        <div class="control-title">left: </div>
        <flutter-slider class="control-slider" :val="left" @change="onControlChange($event, 'left')"></flutter-slider>
        <div class="control-result">{{ left }} {{ leftPercentage ? '%' : 'px' }}</div>
        <flutter-switch :selected="leftPercentage" @change="onSwitchChange($event, 'left')"></flutter-switch>
      </div>
      <div class="control-item" v-if="enableRight">
        <div class="control-title">right: </div>
        <flutter-slider class="control-slider" :val="right" @change="onControlChange($event, 'right')"></flutter-slider>
        <div class="control-result">{{ right }} {{ rightPercentage ? '%' : 'px'}}</div>
        <flutter-switch :selected="rightPercentage" @change="onSwitchChange($event, 'right')"></flutter-switch>
      </div>
      <div class="control-item" v-if="enableBottom">
        <div class="control-title">bottom: </div>
        <flutter-slider class="control-slider" :val="bottom"
          @change="onControlChange($event, 'bottom')"></flutter-slider>
        <div class="control-result">{{ bottom }} {{ bottomPercentage ? '%' : 'px' }}</div>
        <flutter-switch :selected="bottomPercentage" @change="onSwitchChange($event, 'bottom')"></flutter-switch>
      </div>
      <div class="control-item">
        <div class="control-title">margin-top: </div>
        <flutter-slider class="control-slider" :val="marginTop"
          @change="onControlChange($event, 'marginTop')"></flutter-slider>
        <div class="control-result">{{ marginTopAuto ? 'auto' : marginTop }} {{ marginTopAuto ? '' : (marginTopPercentage ?  '%' : 'px') }}</div>
        <flutter-switch :selected="marginTopPercentage" @change="onSwitchChange($event, 'marginTop')"></flutter-switch>
      </div>
      <div class="control-item">
        <div class="control-title">margin-left: </div>
        <flutter-slider class="control-slider" :val="marginLeft"
          @change="onControlChange($event, 'marginLeft')"></flutter-slider>
        <div class="control-result">{{ marginLeftAuto ? 'auto' : marginLeft }} {{ marginLeftAuto ? '' : (marginLeftPercentage ? '%' : 'px') }}</div>
        <flutter-switch :selected="marginLeftPercentage" @change="onSwitchChange($event, 'marginLeft')"></flutter-switch>
      </div>
    </div>
  </webf-listview>
</template>

<script>
export default {
  props: {
    style: Object
  },
  data() {
    return {
      top: 0,
      left: 0,
      right: 0,
      bottom: 0,
      marginTop: 10,
      marginBottom: 0,
      marginLeft: 0,
      marginRight: 0,
      enableTop: true,
      enableLeft: true,
      enableRight: false,
      enableBottom: false,
      topPercentage: false,
      leftPercentage: false,
      rightPercentage: false,
      bottomPercentage: false,
      marginTopPercentage: false,
      marginRightPercentage: false,
      marginBottomPercentage: false,
      marginLeftPercentage: false,
      marginLeftAuto: false,
      marginRightAuto: false,
      marginTopAuto: false,
      marginBottomAuto: false
    }
  },
  computed: {
    computedStyle() {
      const style = {
        'position': this.$props.style['position'],
        zIndex: 100,
        'margin-top': this.marginTopAuto ? 'auto' : (this.marginTop + (this.marginTopPercentage ? '%' : 'px')),
        'margin-bottom': this.marginBottomAuto ? 'auto' : (this.marginBottom + (this.marginBottomPercentage ? '%' : 'px')),
        'margin-left': this.marginLeftAuto ? 'auto' : (this.marginLeft + (this.marginLeftPercentage ? '%' : 'px')),
        'margin-right': this.marginRightAuto ? 'auto' : (this.marginRight + (this.marginRightPercentage ? '%' : 'px'))
      };
      if (this.top !== null && this.enableTop) style.top = this.top + (this.topPercentage ? '%' : 'px');
      if (this.left !== null && this.enableLeft) style.left = this.left + (this.leftPercentage ? '%' : 'px');
      if (this.right !== null && this.enableRight) style.right = this.right + (this.rightPercentage ? '%' : 'px');
      if (this.bottom !== null && this.enableBottom) style.bottom = this.bottom + (this.bottomPercentage ? '%' : 'px');
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
        case 'marginTop':
          this.marginTop = e.detail;
          this.marginTopAuto = false;
          this.marginBottomAuto = false;
          break;
        case 'marginLeft':
          this.marginLeft = e.detail;
          this.marginLeftAuto = false;
          this.marginRightAuto = false;
          break;
        case 'marginRight':
          this.marginRight = e.detail;
          break;
        case 'marginBottom':
          this.marginBottom = e.detail;
            break;
      }
    },

    onSwitchChange(e, label) {
      switch (label) {
        case 'top':
          this.topPercentage = e.detail;
          break;
        case 'left':
          this.leftPercentage = e.detail;
          break;
        case 'right':
          this.rightPercentage = e.detail;
          break;
        case 'bottom':
          this.bottomPercentage = e.detail;
          break;
        case 'marginTop':
          this.marginTopPercentage = e.detail;
          break;
        case 'marginLeft':
          this.marginLeftPercentage = e.detail;
          break;
        case 'marginRight':
          this.marginRightPercentage = e.detail;
          break;
        case 'marginBottom':
          this.marginBottomPercentage = e.detail;
            break;
      }
    },
    onBClicked(e) {
      e.target.style.backgroundColor = '#' + Math.floor(Math.random()*16777215).toString(16);
    },
    onMarginAutoButtonClick(direction) {
      switch(direction) {
        case 'horizontal':
          this.left = 0;
          this.right = 0;
          this.enableRight = true;
          this.marginLeftAuto = true;
          this.marginRightAuto = true;
          break;
        case 'vertical':
          this.top = 0;
          this.bottom = 0;
          this.enableBottom = true;
          this.marginTopAuto = true;
          this.marginBottomAuto = true;
          break;
      }
    }
  },
  watch: {
    enableTop(newValue) {
      if (newValue && !this.marginTopAuto && !this.marginBottomAuto) {
        this.enableBottom = !newValue;
      }
    },
    enableBottom(newValue) {
      if (newValue && !this.marginTopAuto && !this.marginBottomAuto) {
        this.enableTop = !newValue;
      }

    },
    enableLeft(newValue) {
      if (newValue && !this.marginLeftAuto && !this.marginRightAuto) {
        this.enableRight = !newValue;
      }

    },
    enableRight(newValue) {
      if (newValue && !this.marginLeftAuto && !this.marginRightAuto) {
        this.enableLeft = !newValue;
      }

    }
  },
}
</script>

<style scoped>
#example-element-container {
  position: relative;
  padding: 10px;
  height: 90vh;
}

.box-group {
  border: 1px solid var(--font-color);
  position: relative;
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
  height: 45vh;
}

.control-panel {
  display: flex;
  flex-direction: row;
  justify-content: space-around;
}

.control-panel span {
  line-height: 30px;
}

.control-panel input {
  border: 1px solid red;
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

.control-buttons {
  display: flex;
  justify-content: space-around;
}
</style>