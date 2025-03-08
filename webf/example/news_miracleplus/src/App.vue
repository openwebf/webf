<template>
  <webf-router-link path="/register" @mount="handleRouterMounted(ROUTE_FLAGS.REGISTER)">
    <register-page v-if="isRouteActive(ROUTE_FLAGS.REGISTER)"></register-page>
  </webf-router-link>
  <webf-router-link path="/login" @mount="handleRouterMounted(ROUTE_FLAGS.LOGIN)">
    <login-page v-if="isRouteActive(ROUTE_FLAGS.LOGIN)"></login-page>
  </webf-router-link>
  <webf-router-link path="/share_link" @mount="handleRouterMounted(ROUTE_FLAGS.SHARE_LINK)">
    <share-link-page v-if="isRouteActive(ROUTE_FLAGS.SHARE_LINK)"></share-link-page>
  </webf-router-link>
  <webf-router-link path="/user" @mount="handleRouterMounted(ROUTE_FLAGS.USER)">
    <user-page v-if="isRouteActive(ROUTE_FLAGS.USER)"></user-page>
  </webf-router-link>
  <webf-router-link path="/edit" @mount="handleRouterMounted(ROUTE_FLAGS.EDIT)">
    <edit-page v-if="isRouteActive(ROUTE_FLAGS.EDIT)"></edit-page>
  </webf-router-link>
  <webf-router-link path="/setting" @mount="handleRouterMounted(ROUTE_FLAGS.SETTING)">
    <setting-page v-if="isRouteActive(ROUTE_FLAGS.SETTING)"></setting-page>
  </webf-router-link>
  <webf-router-link path="/user_agreement" @mount="handleRouterMounted(ROUTE_FLAGS.USER_AGREEMENT)">
    <user-agreement-page v-if="isRouteActive(ROUTE_FLAGS.USER_AGREEMENT)"></user-agreement-page>
  </webf-router-link>
  <webf-router-link path="/privacy_policy" @mount="handleRouterMounted(ROUTE_FLAGS.PRIVACY_POLICY)">
    <privacy-policy-page v-if="isRouteActive(ROUTE_FLAGS.PRIVACY_POLICY)"></privacy-policy-page>
  </webf-router-link>
  <webf-router-link path="/answer" @mount="handleRouterMounted(ROUTE_FLAGS.ANSWER)">
    <answer-page v-if="isRouteActive(ROUTE_FLAGS.ANSWER)"></answer-page>
  </webf-router-link>
  <webf-router-link path="/question" @mount="handleRouterMounted(ROUTE_FLAGS.QUESTION)">
    <question-page v-if="isRouteActive(ROUTE_FLAGS.QUESTION)"></question-page>
  </webf-router-link>
  <webf-router-link path="/topic" @mount="handleRouterMounted(ROUTE_FLAGS.TOPIC)">
    <topic-page v-if="isRouteActive(ROUTE_FLAGS.TOPIC)"></topic-page>
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

// Define route flags as bit positions
const ROUTE_FLAGS = {
  REGISTER: 0x001,        // 0000 0000 0001
  LOGIN: 0x002,           // 0000 0000 0010
  SHARE_LINK: 0x004,      // 0000 0000 0100
  USER: 0x008,            // 0000 0000 1000
  EDIT: 0x010,            // 0000 0001 0000
  SETTING: 0x020,         // 0000 0010 0000
  USER_AGREEMENT: 0x040,  // 0000 0100 0000
  PRIVACY_POLICY: 0x080,  // 0000 1000 0000
  ANSWER: 0x100,          // 0001 0000 0000
  QUESTION: 0x200,        // 0010 0000 0000
  HOME: 0x400,            // 0100 0000 0000
  TOPIC: 0x800,           // 1000 0000 0000
};

// Watch the hybrid router changes
window.addEventListener('hybridrouterchange', (e) => {
  console.log('router changes', e.state, e.kind, e.name);
});

// Map paths to route flags
// const PATH_TO_FLAG = {
//   '/register': ROUTE_FLAGS.REGISTER,
//   '/login': ROUTE_FLAGS.LOGIN,
//   '/share_link': ROUTE_FLAGS.SHARE_LINK,
//   '/user': ROUTE_FLAGS.USER,
//   '/edit': ROUTE_FLAGS.EDIT,
//   '/setting': ROUTE_FLAGS.SETTING,
//   '/user_agreement': ROUTE_FLAGS.USER_AGREEMENT,
//   '/privacy_policy': ROUTE_FLAGS.PRIVACY_POLICY,
//   '/answer': ROUTE_FLAGS.ANSWER,
//   '/question': ROUTE_FLAGS.QUESTION,
//   '/home': ROUTE_FLAGS.HOME
// };

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
    // Activate a specific route flag while preserving existing flags
    handleRouterMounted(flag) {
      console.log('handleRouterMounted with flag:', flag.toString(16));
      
      // Set the active route flag without clearing previous flags
      this.routeFlags |= flag;
      
      // Get the page name from the current history path
      const path = window.webf.hybridHistory.path;
      console.log('Current path:', path);
      
      // Extract page name from path
      const page = path.substring(1); // Remove leading slash
      
      tabBarManager.setCurrentPath(`/${page}`);
    },
    
    // Deactivate a specific route flag
    deactivateRoute(flag) {
      this.routeFlags &= ~flag;
    },
    
    // Check if a specific route is active
    isRouteActive(flag) {
      return (this.routeFlags & flag) === flag;
    },
    
    handleTabChange(e) {
      console.log('handleTabChange: ', e.detail);
      this.currentIndex = e.detail;
    },
  },
  data() {
    return {
      routeFlags: 0, // Initialize with no routes active
      currentIndex: 0,
      ROUTE_FLAGS // Make flags available in template
    };
  },
};
</script>

<style src="./assets/styles/app.css" />
