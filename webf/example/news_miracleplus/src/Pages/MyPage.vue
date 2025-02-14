<template>
  <div @click="goToHomePage">
    点我去首页
  </div>
  <div @click="goToRegisterPage">
    点我去注册页
  </div>
  <div @click="goToLoginPage">
    点我去登录页
  </div>
</template>

<script>
import tabBarManager from '../utils/tabBarManager';
export default {
  components: {},
  mounted() {
    console.log('my page mounted');
  },
  activated() {
    console.log('onShow');
    console.log('window.webf.hybridHistory.state: ', window.webf.hybridHistory.state);
  },
  data: () => {
    return {}
  },
  methods: {
    goToHomePage() {
      console.log('tabBarManager.switchTab: ', tabBarManager.switchTab);
      tabBarManager.switchTab('/home');
    },
    goToRegisterPage() {
      window.webf.hybridHistory.pushState({}, '/register');
    },
    goToLoginPage() {
      window.webf.hybridHistory.pushState({}, '/login');
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