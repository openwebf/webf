<template>
  <div class="my-page">
    <div class="user-info-block">
      <img :src="formattedAvatar" class="avatar" />
      <div class="name" v-if="isLoggedIn"  @click="goToLoginPage">{{ user.name }}</div>
      <div class="login-button" v-else @click="goToLoginPage">登录/注册</div>
      <div class="title" v-if="isLoggedIn">
        {{ formattedTitle }}
      </div>
      <div class="stats">
        <div class="stat-item">
          <div class="number">{{ user.followingCount || 0 }}</div>
          <div class="label">关注</div>
        </div>
        <div class="stat-item">
          <div class="number">{{ user.followerCount || 0 }}</div>
          <div class="label">粉丝</div>
        </div>
      </div>
      <div class="edit-block" v-if="isLoggedIn">
          <flutter-cupertino-button class="edit-profile" type="primary" shape="rounded" @click="goToEditPage">
            编辑资料
          </flutter-cupertino-button>
          <flutter-cupertino-button class="setting" @click="goToSettingPage">
            设置
          </flutter-cupertino-button>
        </div>
      
      <div class="karma-count">
        <div>社区 Karma： {{ user.karma || 0 }}</div>
        <flutter-cupertino-icon type="question_circle" />
      </div>
    </div>
    <flutter-cupertino-segmented-tab>
      <flutter-cupertino-segmented-tab-item title="全部">
        <div v-if="!isLoggedIn">
          <login-tip />
        </div>
        <!-- <div v-for="item in allFeeds" :key="item.id">
          <feed-card :item="item"></feed-card>
        </div> -->
      </flutter-cupertino-segmented-tab-item>
      <flutter-cupertino-segmented-tab-item title="分享">
        <div v-if="!isLoggedIn">
          <login-tip />
        </div>
        <!-- <div v-for="item in shareFeeds" :key="item.id">
          <feed-card :item="item"></feed-card>
        </div> -->
      </flutter-cupertino-segmented-tab-item>
      <flutter-cupertino-segmented-tab-item title="评论">
        <div v-if="!isLoggedIn">
          <login-tip />
        </div>
        <!-- <div v-for="item in commentFeeds" :key="item.id">
          <comment-card :item="item"></comment-card>
        </div> -->
      </flutter-cupertino-segmented-tab-item>
      <flutter-cupertino-segmented-tab-item title="点赞">
        <div v-if="!isLoggedIn">
          <login-tip />
        </div>
        <!-- <div v-for="item in likeFeeds" :key="item.id">
          <feed-card :item="item"></feed-card>
        </div> -->
      </flutter-cupertino-segmented-tab-item>
      <flutter-cupertino-segmented-tab-item title="收藏">
        <div v-if="!isLoggedIn">
          <login-tip />
        </div>
        <!-- <div v-for="item in collectFeeds" :key="item.id">
          <feed-card :item="item"></feed-card>
        </div> -->
      </flutter-cupertino-segmented-tab-item>
    </flutter-cupertino-segmented-tab>
  </div>

</template>

<script>
// import FeedCard from '@/Components/FeedCard.vue';
// import CommentCard from '@/Components/comment/CommentCard.vue';
import LoginTip from '@/Components/LoginTip.vue';

import { useUserStore } from '@/stores/userStore';
import tabBarManager from '@/utils/tabBarManager';
import formatAvatar from '@/utils/formatAvatar';
// import { api } from '@/api';
export default {
  components: {
    // FeedCard,
    // CommentCard,
    LoginTip,
  },
  // async mounted() {
    // ['all', 'share', 'comment', 'like', 'collect'].forEach(async (category) => {
    //   const res = await api.auth.getUserFeedsList({
    //     userId: this.user.id,
    //     category,
    //     page: 1,
    //     token: this.user.token,
    //     anonymousId: this.user.anonymousId,
    //   });
    //   this[`${category}Feeds`] = res.data.feeds;
    // });
  // },
  data() {
    return {
      user: {
      },
      allFeeds: [],
      shareFeeds: [],
      commentFeeds: [],
      likeFeeds: [],
      collectFeeds: [],
    }
  },
  setup() {
      const userStore = useUserStore();
      return {
        userStore,
      }
    },
  computed: {
    isLoggedIn() {
      return this.userStore.isLoggedIn;
    },
    formattedAvatar() {
      return formatAvatar(this.user.avatar);
    },
    formattedTitle() {
      if (this.user.jobTitle) {
        return `${this.user.company} · ${this.user.jobTitle}`;
      }
      return this.user.company;
    }
  },
  activated() {
    console.log('onShow');
    console.log('window.webf.hybridHistory.state: ', window.webf.hybridHistory.state);
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
    },
    goToEditPage() {
        window.webf.hybridHistory.pushState({}, '/edit');
      },
    goToSettingPage() {
        window.webf.hybridHistory.pushState({}, '/setting');
    }
  }
}
</script>


<style>
.my-page {
  .user-info-block {
    display: flex;
    flex-direction: column;
    align-items: center;
    padding: 16px;
    border-radius: 12px;

    .avatar {
      width: 80px;
      height: 80px;
      border-radius: 50%;
      object-fit: cover;
      margin-bottom: 12px;
    }

    .name {
      font-size: 18px;
      font-weight: 600;
      color: #333;
      margin-bottom: 24px;
    }

    .login-button {
      font-size: 18px;
      font-weight: 600;
      color: #666;
      text-align: center;
      margin-top: 8px;
      margin-bottom: 24px;

    }

    .title {
      font-size: 14px;
      color: #666;
      margin-bottom: 20px;
      text-align: center;
    }

    .stats {
      display: flex;
      margin-bottom: 16px;
      margin-left: -24px;
      margin-right: -24px;
      align-items: center;
      .stat-item {
        display: flex;
        flex-direction: column;
        align-items: center;
        padding-left: 24px;
        padding-right: 24px;

        .number {
          font-size: 18px;
          font-weight: 600;
          color: #333;
        }

        .label {
          font-size: 14px;
          color: #666;
        }
      }
    }

    .edit-block {
      display: flex;
      flex-direction: row;
      align-items: center;
      justify-content: space-between;
      margin-bottom: 12px;

      .edit-profile {
        height: 36px;
        margin-right: 12px;
        width: 100px;
        color: var(--font-color-primary);
      }

      .setting {
        width: 100px;
        height: 36px;
        color: var(--font-color-primary);
      }
    }

    .karma-count {
      font-size: 12px;
      color: #999;
      display: flex;
      align-items: center;
    }
  }
}
</style>