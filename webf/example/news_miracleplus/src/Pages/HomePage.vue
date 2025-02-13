<template>
  <div id="main">
    <feeds-tabs :tabs="tabsConfig">
        <!-- 热门标签页内容 -->
        <template #hot>
            <div>热门内容列表</div>

            <div @click="goToLogin">去登录页面</div>
            <div @click="goToRegister">去注册页面</div>

            <!-- <div>Cupertino 组件展示</div>
            <div>Cupertino Switch</div>
            <flutter-cupertino-switch
              :selected="switchValue"
              @change="onSwitchChange"
              active-color="#FF0000"
              inactive-color="#CCCCCC"
            />
            <div>Cupertino Segmented Tabs</div>
            <flutter-cupertino-segmented-tab>
              <flutter-cupertino-segmented-tab-item title="标签1">
                <div>内容1</div>
              </flutter-cupertino-segmented-tab-item>
              <flutter-cupertino-segmented-tab-item title="标签2">
                <div>内容2</div>
              </flutter-cupertino-segmented-tab-item>
            </flutter-cupertino-segmented-tab> -->
        </template>
        
        <!-- 最新标签页内容 -->
        <template #latest>
            <div>最新内容列表</div>
            <div>Cupertino 组件展示</div>
            <div>Cupertino Picker</div>
            <flutter-cupertino-picker height="200" item-height="32" @change="onPickerChange">
              <flutter-cupertino-picker-item label="选项1"></flutter-cupertino-picker-item>
              <flutter-cupertino-picker-item label="选项2"></flutter-cupertino-picker-item>
              <flutter-cupertino-picker-item label="选项3"></flutter-cupertino-picker-item>
            </flutter-cupertino-picker>
            <div>Cupertino Date Picker</div>
            <flutter-cupertino-date-picker
              mode="date"
              height="200"
              minimum-date="2024-01-01"
              maximum-date="2025-12-31"
              value="2024-03-14"
              use-24h="true"
              @change="onDateChange"
            />
        </template>
        
        <!-- 讨论标签页内容 -->
        <template #discussion>
            <div>讨论内容列表</div>
            <div @click="showModalPopup">点我展示 modal</div>
            <flutter-cupertino-modal-popup 
              :show="showModal" 
              height="400"
              @close="onModalClose"
            >
              <div class="modal-content">
                <h1>这是一个底部弹出框</h1>
                <p>这里是内容区域</p>
              </div>
            </flutter-cupertino-modal-popup>
        </template>
        
        <!-- 新闻标签页内容 -->
        <template #news>
            <div>新闻内容列表</div>
        </template>
        
        <!-- 学术标签页内容 -->
        <template #academic>
            <div>学术内容列表</div>
        </template>
        
        <!-- 产品标签页内容 -->
        <template #product>
            <div>产品内容列表</div>
        </template>
    </feeds-tabs>
  </div>

</template>

<script>
import { mapGetters } from 'vuex'
import FeedsTabs from "@/Components/FeedsTabs.vue";

export default {
  components: {
    FeedsTabs,
  },
  computed: {
    ...mapGetters({
      isLoggedIn: 'user/isLoggedIn',
      userInfo: 'user/userInfo',
      userName: 'user/userName',
      userAvatar: 'user/userAvatar'
    })
  },
  updated() {
    console.log('isLoggedIn', this.isLoggedIn);
    console.log('userInfo', this.userInfo);
    console.log('userName', this.userName);
    console.log('userAvatar', this.userAvatar);
  },
  data: () => {
    return {
      tabsConfig: [
        { id: 'hot', title: '热门' },
        { id: 'latest', title: '最新' },
        { id: 'discussion', title: '讨论' },
        { id: 'news', title: '新闻' },
        { id: 'academic', title: '学术' },
        { id: 'product', title: '产品' }
      ],
      show: true,
      switchValue: false,
      showModal: false,
    }
  },
  methods: {
    onSwitchChange(e) {
      console.log('onSwitchChange', e.detail);
      this.switchValue = e.detail;
    },
    showModalPopup() {
      this.showModal = true;
      console.log('showModalPopup', this.showModal);
    },
    onModalClose() {
      console.log('onModalClose');
      this.showModal = false;
    },
    goToLogin() {
      window.webf.hybridHistory.pushState({}, '/login');
    },
    goToRegister() {
      window.webf.hybridHistory.pushState({}, '/register');
    }
  }
}
</script>


<style scoped>
#list {
  padding: 10px 0;
  height: 100vh;
  width: 100vw;
}
</style>