<template>
  <router-view path="/register" title="注册">
    <register-page></register-page>
  </router-view>
  <router-view path="/login" title="登陆">
    <login-page></login-page>
  </router-view>
  <router-view path="/reset_password" title="重置密码">
    <reset-password-page></reset-password-page>
  </router-view>
  <router-view path="/share_link" title="分享链接">
    <share-link-page></share-link-page>
  </router-view>
  <router-view path="/comment" title="评论">
    <comment-page></comment-page>
  </router-view>
  <router-view path="/user" title="用户">
    <user-page></user-page>
  </router-view>
  <router-view path="/edit" title="编辑资料">
    <edit-page></edit-page>
  </router-view>
  <router-view path="/setting" title="设置">
    <setting-page></setting-page>
  </router-view>
  <router-view path="/user_agreement" title="用户协议">
    <user-agreement-page></user-agreement-page>
  </router-view>
  <router-view path="/privacy_policy" title="隐私政策">
    <privacy-policy-page></privacy-policy-page>
  </router-view>
  <router-view path="/answer" title="回答">
    <answer-page></answer-page>
  </router-view>
  <router-view path="/question" title="问题">
    <question-page></question-page>
  </router-view>
  <router-view path="/topic" title="话题">
    <topic-page></topic-page>
  </router-view>
  <router-view path="/home" title="首页">
    <flutter-cupertino-tab-bar ref="tabBar" class="tab-bar" :currentIndex="currentIndex" @tabchange="handleTabChange">
      <flutter-cupertino-tab-bar-item title="首页" icon="home" path="/home">
        <home-page v-show="currentIndex === 0"></home-page>
      </flutter-cupertino-tab-bar-item>
      <flutter-cupertino-tab-bar-item title="搜索" icon="search" path="/search">
        <search-page v-show="currentIndex === 1"></search-page>
      </flutter-cupertino-tab-bar-item>
      <flutter-cupertino-tab-bar-item title="发布" icon="add_circled_solid" path="/publish">
        <publish-page v-show="currentIndex === 2"></publish-page>
      </flutter-cupertino-tab-bar-item>
      <flutter-cupertino-tab-bar-item title="消息" icon="bell" path="/notification">
        <notification-page v-show="currentIndex === 3"></notification-page>
      </flutter-cupertino-tab-bar-item>
      <flutter-cupertino-tab-bar-item title="我的" icon="person" path="/my">
        <my-page v-show="currentIndex === 4"></my-page>
      </flutter-cupertino-tab-bar-item>
    </flutter-cupertino-tab-bar>
  </router-view>
</template>

<script>
import RouterView from '@/Components/RouterView.vue';
import HomePage from '@/Pages/HomePage.vue';
import SearchPage from '@/Pages/SearchPage.vue';
import PublishPage from '@/Pages/PublishPage.vue';
import NotificationPage from '@/Pages/NotificationPage.vue';
import UserPage from '@/Pages/UserPage.vue';
import MyPage from '@/Pages/MyPage.vue';
import RegisterPage from '@/Pages/RegisterPage.vue';
import LoginPage from '@/Pages/LoginPage.vue';
import ShareLinkPage from '@/Pages/ShareLinkPage.vue';
import CommentPage from '@/Pages/CommentPage.vue';
import EditPage from '@/Pages/EditPage.vue';
import SettingPage from '@/Pages/SettingPage.vue';
import UserAgreementPage from '@/Pages/UserAgreementPage.vue';
import PrivacyPolicyPage from '@/Pages/PrivacyPolicyPage.vue';
import AnswerPage from '@/Pages/AnswerPage.vue';
import QuestionPage from '@/Pages/QuestionPage.vue';
import TopicPage from '@/Pages/TopicPage.vue';
import ResetPasswordPage from '@/Pages/ResetPasswordPage.vue';
import tabBarManager from '@/utils/tabBarManager';

export default {
  name: 'App',
  components: {
    RouterView,
    HomePage,
    SearchPage,
    PublishPage,
    NotificationPage,
    RegisterPage,
    LoginPage,
    ShareLinkPage,
    CommentPage,
    UserPage,
    MyPage,
    EditPage,
    SettingPage,
    UserAgreementPage,
    PrivacyPolicyPage,
    AnswerPage,
    QuestionPage,
    TopicPage,
    ResetPasswordPage,
  },
  mounted() {
    tabBarManager.setTabBarRef(this.$refs.tabBar);
    tabBarManager.setCurrentPath('/home');
  },
  methods: {
    handleTabChange(e) {
      this.currentIndex = e.detail;
    },
  },
  data() {
    return {
      currentIndex: 0,
    };
  },
};
</script>

<style src="./assets/styles/app.css" />
