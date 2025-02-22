<template>
  <div class="my-page">
    <div @click="goToHomePage">
      点我去首页
    </div>
    <div @click="goToRegisterPage">
      点我去注册页
    </div>
    <div @click="goToLoginPage">
      点我去登录页
    </div>
    <div class="user-info-block">
      <img :src="formattedAvatar" class="avatar" />
      <div class="name">{{ user.name }}</div>
      <div class="title">
        {{ formattedTitle }}
      </div>
      <div class="stats">
        <div class="stat-item">
          <div class="number">{{ user.followingCount }}</div>
          <div class="label">关注</div>
        </div>
        <div class="stat-item">
          <div class="number">{{ user.followerCount }}</div>
          <div class="label">粉丝</div>
        </div>
      </div>
      
      <div class="karma-count">
        <div>社区 Karma： {{ user.karma }}</div>
        <flutter-cupertino-icon type="question_circle" />
      </div>
    </div>
    <flutter-cupertino-segmented-tab>
      <flutter-cupertino-segmented-tab-item title="全部">
        <!-- <div v-for="item in allFeeds" :key="item.id">
          <feed-card :item="item"></feed-card>
        </div> -->
      </flutter-cupertino-segmented-tab-item>
      <flutter-cupertino-segmented-tab-item title="分享">
        <!-- <div v-for="item in shareFeeds" :key="item.id">
          <feed-card :item="item"></feed-card>
        </div> -->
      </flutter-cupertino-segmented-tab-item>
      <flutter-cupertino-segmented-tab-item title="评论">
        <!-- <div v-for="item in commentFeeds" :key="item.id">
          <comment-card :item="item"></comment-card>
        </div> -->
      </flutter-cupertino-segmented-tab-item>
      <flutter-cupertino-segmented-tab-item title="点赞">
        <!-- <div v-for="item in likeFeeds" :key="item.id">
          <feed-card :item="item"></feed-card>
        </div> -->
      </flutter-cupertino-segmented-tab-item>
      <flutter-cupertino-segmented-tab-item title="收藏">
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
import tabBarManager from '@/utils/tabBarManager';
import formatAvatar from '@/utils/formatAvatar';
// import { api } from '@/api';
export default {
  components: {
    // FeedCard,
    // CommentCard,
  },
  async mounted() {
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
  },
  data() {
    return {
      user: {
        bio: null,
        name: "殷木",
        company: "OpenWebF",
        phone: "15652964849",
        email: "yxy0919@foxmail.com",
        desc: "",
        karma: 26,
        roles: [],
        id: "k6tJN2",
        userId: 7492,
        jobTitle: "工程师",
        wechatId: null,
        profileFullDisclosure: false,
        anonymousId: "194a2cc892e7c7-0fb45bdd71fd0d-1d525636-1238988-194a2cc892f2615",
        token: "eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoiNjc5NjM4OTJkMDE3YWEzYzM0ZTE3MTljIiwiaWF0IjoxNzM5NjAyNjk1fQ.06JzbsQCVuFCS3FC_o9Yzyz91aP9wHjuMV3PJQvuSt0",
        followingCount: 5,
        followerCount: 0,
        likesCount: 0,
        unreadNotificationCount: 2,
        countryCode: "86",
        karmaRanking: 352,
        avatar: "/img/avatar/defaultavatar4.png",
        wechatUser: null
      },
      allFeeds: [],
      shareFeeds: [],
      commentFeeds: [],
      likeFeeds: [],
      collectFeeds: [],
    }
  },
  computed: {
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
    padding: 24px 16px;
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
      margin-bottom: 8px;
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

    .karma-count {
      font-size: 12px;
      color: #999;
      display: flex;
      align-items: center;
    }
  }
}
</style>