<template>
  <div @click="onClick" class="my-container">
    点我点我
    <flutter-tab-bar
    class="tab-bar"
    backgroundColor="#FFFFFF"
    activeColor="#007AFF"
    :currentIndex="currentIndex"
    @tabchange="handleTabChange"
  >
    <flutter-tab-bar-item
      title="首页"
      icon="home"
      path="/home"
    />
    <flutter-tab-bar-item
      title="搜索"
      icon="search"
      path="/search"
    />
    <flutter-tab-bar-item
      title="发布"
      icon="add_circled_solid"
      path="/publish"
    />
    <flutter-tab-bar-item
      title="消息"
      icon="bell"
      path="/message"
    />
    <flutter-tab-bar-item
      title="我的"
      icon="person"
      path="/my"
    />
  </flutter-tab-bar>
  </div>

</template>

<script>
import tabBarManager from '../utils/tabBarManager';
export default {
  components: {},
  mounted(options) {
    console.log('options: ', options);
    console.log('window.hybridHistory: ', window.location.href);
  },
  activated() {
    console.log('onShow');
    console.log('window.webf.hybridHistory.state: ', window.webf.hybridHistory.state);
  },
  data: () => {
    return {}
  },
  methods: {
    onClick() {
      console.log('tabBarManager.switchTab: ', tabBarManager.switchTab);
      tabBarManager.switchTab('/home');
    }
  }
}
</script>


<style>
.my-container {
  width: 100vw;
  height: 100vh;
  background-color: #f00;
}
</style>