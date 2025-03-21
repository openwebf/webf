<template>
    <div class="user-page">
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
        </flutter-cupertino-segmented-tab-item>
        <flutter-cupertino-segmented-tab-item title="分享">
        </flutter-cupertino-segmented-tab-item>
        <flutter-cupertino-segmented-tab-item title="评论">
        </flutter-cupertino-segmented-tab-item>
        <flutter-cupertino-segmented-tab-item title="点赞">
        </flutter-cupertino-segmented-tab-item>
        <flutter-cupertino-segmented-tab-item title="收藏">
        </flutter-cupertino-segmented-tab-item>
      </flutter-cupertino-segmented-tab>
    </div>
  
  </template>
  
  <script>
  import { useUserStore } from '@/stores/userStore';
  import formatAvatar from '@/utils/formatAvatar';
  import { api } from '@/api';
  export default {
    components: {
      // FeedCard,
      // CommentCard,
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
        user: {},
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
      formattedAvatar() {
        return formatAvatar(this.user.avatar);
      },
      formattedTitle() {
        if (this.user.jobTitle) {
          return `${this.user.company} · ${this.user.jobTitle}`;
        }
        return this.user.company;
      },
    },
    async mounted() {
        const userId = window.webf.hybridHistory.state.id;
        if (!userId) {
            return;
        }
        console.log('userId: ', userId);
        const res = await api.user.getFeeds({
            userId,
        });
        this.user = res.data.user;
    },
    methods: {}
  }
  </script>
  
  
  <style>
  .user-page {
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