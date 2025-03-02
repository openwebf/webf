<template>
  <webf-router-link path="/register" @mount="handleRouterMounted('register')" @unmount="handleRouterUnmounted">
    <register-page v-if="activedRouter === 'register'"></register-page>
  </webf-router-link>
  <webf-router-link path="/login" @mount="handleRouterMounted('login')" @unmount="handleRouterUnmounted">
    <login-page v-if="activedRouter === 'login'"></login-page>
  </webf-router-link>
  <webf-router-link path="/share_link" @mount="handleRouterMounted('share_link')" @unmount="handleRouterUnmounted">
    <share-link-page v-if="activedRouter === 'share_link'"></share-link-page>
  </webf-router-link>
  <webf-router-link path="/user" @mount="handleRouterMounted('user')" @unmount="handleRouterUnmounted">
    <user-page v-if="activedRouter === 'user'"></user-page>
  </webf-router-link>
  <webf-router-link path="/edit" @mount="handleRouterMounted('edit')" @unmount="handleRouterUnmounted">
    <edit-page v-if="activedRouter === 'edit'"></edit-page>
  </webf-router-link>
  <webf-router-link path="/setting" @mount="handleRouterMounted('setting')" @unmount="handleRouterUnmounted">
    <setting-page v-if="activedRouter === 'setting'"></setting-page>
  </webf-router-link>
  <webf-router-link path="/user_agreement" @mount="handleRouterMounted('user_agreement')" @unmount="handleRouterUnmounted">
    <user-agreement-page v-if="activedRouter === 'user_agreement'"></user-agreement-page>
  </webf-router-link>
  <webf-router-link path="/privacy_policy" @mount="handleRouterMounted('privacy_policy')" @unmount="handleRouterUnmounted">
    <privacy-policy-page v-if="activedRouter === 'privacy_policy'"></privacy-policy-page>
  </webf-router-link>
  <webf-router-link path="/answer" @mount="handleRouterMounted('answer')" @unmount="handleRouterUnmounted">
    <answer-page v-if="activedRouter === 'answer'"></answer-page>
  </webf-router-link>
  <webf-router-link path="/question" @mount="handleRouterMounted('question')" @unmount="handleRouterUnmounted">
    <question-page v-if="activedRouter === 'question'"></question-page>
  </webf-router-link>
  <webf-router-link path="/topic" @mount="handleRouterMounted('topic')" @unmount="handleRouterUnmounted">
    <topic-page v-if="activedRouter === 'topic'"></topic-page>
  </webf-router-link>
  <webf-router-link path="/home">
    <flutter-tab-bar ref="tabBar" class="tab-bar" backgroundColor="#FFFFFF" activeColor="#007AFF"
      :currentIndex="currentIndex" @tabchange="handleTabChange">
      <flutter-tab-bar-item title="首页" icon="home" path="/home">
        <keep-alive>
          <home-page v-if="currentIndex === 0"></home-page>
        </keep-alive>
      </flutter-tab-bar-item>
      <flutter-tab-bar-item title="搜索" icon="search" path="/search">
        <keep-alive>
          <search-page v-if="currentIndex === 1"></search-page>
        </keep-alive>
      </flutter-tab-bar-item>
      <flutter-tab-bar-item title="发布" icon="add_circled_solid" path="/publish">
        <keep-alive>
          <publish-page v-if="currentIndex === 2"></publish-page>
        </keep-alive>
      </flutter-tab-bar-item>
      <flutter-tab-bar-item title="消息" icon="bell" path="/notification">
        <keep-alive>
          <notification-page v-if="currentIndex === 3"></notification-page>
        </keep-alive>
      </flutter-tab-bar-item>
      <flutter-tab-bar-item title="我的" icon="person" path="/my">
        <keep-alive>
          <my-page v-if="currentIndex === 4"></my-page>
        </keep-alive>
      </flutter-tab-bar-item>
    </flutter-tab-bar>
  </webf-router-link>
</template>

<script>
import HomePage from '@/Pages/HomePage.vue';
import SearchPage from '@/Pages/SearchPage.vue';
import PublishPage from '@/Pages/PublishPage.vue';
import NotificationPage from '@/Pages/NotificationPage.vue';
import UserPage from '@/Pages/UserPage.vue';
import MyPage from '@/Pages/MyPage.vue';
import RegisterPage from '@/Pages/RegisterPage.vue';
import LoginPage from '@/Pages/LoginPage.vue';
import ShareLinkPage from '@/Pages/ShareLinkPage.vue';
import EditPage from '@/Pages/EditPage.vue';
import SettingPage from '@/Pages/SettingPage.vue';
import UserAgreementPage from '@/Pages/UserAgreementPage.vue';
import PrivacyPolicyPage from '@/Pages/PrivacyPolicyPage.vue';
import AnswerPage from '@/Pages/AnswerPage.vue';
import QuestionPage from '@/Pages/QuestionPage.vue';
import TopicPage from '@/Pages/TopicPage.vue';
import tabBarManager from '@/utils/tabBarManager';
export default {
  name: 'App',
  components: {
    HomePage,
    SearchPage,
    PublishPage,
    NotificationPage,
    RegisterPage,
    LoginPage,
    ShareLinkPage,
    UserPage,
    MyPage,
    EditPage,
    SettingPage,
    UserAgreementPage,
    PrivacyPolicyPage,
    AnswerPage,
    QuestionPage,
    TopicPage,
  },
  mounted() {
    tabBarManager.setTabBarRef(this.$refs.tabBar);
    tabBarManager.setCurrentPath('/home');
  },
  methods: {
    handleRouterMounted(page) {
      console.log('handleRouterMounted: ', page);
      this.activedRouter = page;
      tabBarManager.setCurrentPath(`/${page}`);
    },
    handleRouterUnmounted() {
      this.activedRouter = '';
    },
    handleTabChange(e) {
      console.log('handleTabChange: ', e.detail);
      this.currentIndex = e.detail;
    },
  },
  data() {
    return {
      activedRouter: '',
      currentIndex: 0
    };
  },
};
</script>

<style src="./assets/styles/app.css" />
