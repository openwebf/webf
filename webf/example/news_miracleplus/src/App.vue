<template>
  <webf-router-link path="/register">
    <register-page></register-page>
  </webf-router-link>
  <webf-router-link path="/login">
    <login-page></login-page>
  </webf-router-link>
  <flutter-tab-bar
    ref="tabBar"
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
    >
      <home-page></home-page>
    </flutter-tab-bar-item>
    <flutter-tab-bar-item
      title="搜索"
      icon="search"
      path="/search"
    >
      <search-page></search-page>
    </flutter-tab-bar-item>
    <flutter-tab-bar-item
      title="发布"
      icon="add_circled_solid"
      path="/publish"
    >
      <publish-page></publish-page>
    </flutter-tab-bar-item>
    <flutter-tab-bar-item
      title="消息"
      icon="bell"
      path="/message"
    >
      <notification-page></notification-page>
    </flutter-tab-bar-item>
    <flutter-tab-bar-item
      title="我的"
      icon="person"
      path="/my"
    >
      <my-page></my-page>
    </flutter-tab-bar-item>
  </flutter-tab-bar>
</template>

<script>
import HomePage from './Pages/HomePage.vue';
import SearchPage from './Pages/SearchPage.vue';
import PublishPage from './Pages/PublishPage.vue';
import NotificationPage from './Pages/NotificationPage.vue';
import MyPage from './Pages/MyPage.vue';
import RegisterPage from './Pages/RegisterPage.vue';
import LoginPage from './Pages/LoginPage.vue';
import tabBarManager from './utils/tabBarManager';
export default {
  name: 'App',
  components: {
    HomePage,
    SearchPage,
    PublishPage,
    NotificationPage,
    MyPage,
    RegisterPage,
    LoginPage,
  },
  mounted() {
    tabBarManager.setTabBarRef(this.$refs.tabBar);
  },
  methods: {
  }
}
</script>

<style src="./assets/styles/app.css" />
