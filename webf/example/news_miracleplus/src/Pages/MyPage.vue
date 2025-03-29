<template>
  <div class="my-page" @onscreen="onScreen">
    <user-info-skeleton v-if="isLoading" />
    <div class="user-info-block" v-else>
      <smart-image :src="formattedAvatar" class="avatar" />
      <div class="name" v-if="isLoggedIn">{{ userInfo.name }}</div>
      <div class="login-button" v-else @click="goToLoginPage">登录/注册</div>
      <div class="title" v-if="isLoggedIn">
        {{ formattedTitle }}
      </div>
      <div class="stats">
        <div class="stat-item">
          <div class="number">{{ userInfo.followingCount || 0 }}</div>
          <div class="label">关注</div>
        </div>
        <div class="stat-item">
          <div class="number">{{ userInfo.followerCount || 0 }}</div>
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
      <!-- <div class="edit-block" v-if="isLoggedIn">
          <flutter-cupertino-button class="edit-profile" type="primary" shape="rounded" @click="goToQuestionPage">
            问题详情
          </flutter-cupertino-button>
          <flutter-cupertino-button class="setting" @click="goToAnswerPage">
            回答详情
          </flutter-cupertino-button>
      </div> -->
      
      <div class="karma-count">
        <div class="karma-count-text">社区 Karma： {{ userInfo.karma || 0 }}</div>
        <flutter-cupertino-icon type="question_circle" class="karma-help-icon" @click="showKarmaHelp = true" />
      </div>
    </div>
    <flutter-cupertino-segmented-tab @change="onTabChange">
      <flutter-cupertino-segmented-tab-item title="全部">
        <webf-listview class="feed-listview" @refresh="onRefreshAll" @loadmore="onLoadMoreAll">
          <div v-if="!isLoggedIn">
            <login-tip />
          </div>
          <div v-else-if="allFeeds.length === 0" class="empty-state">
            暂无内容
          </div>
          <div v-else v-for="item in allFeeds" :key="item.id">
            <user-feed-card :feed="item"></user-feed-card>
          </div>
        </webf-listview>
      </flutter-cupertino-segmented-tab-item>
      <flutter-cupertino-segmented-tab-item title="分享">
        <webf-listview class="feed-listview" @refresh="onRefreshShare" @loadmore="onLoadMoreShare">
          <div v-if="!isLoggedIn">
            <login-tip />
          </div>
          <div v-else-if="shareFeeds.length === 0" class="empty-state">
            暂无分享内容
          </div>
          <div v-else v-for="item in shareFeeds" :key="item.id">
            <user-feed-card :feed="item"></user-feed-card>
          </div>
        </webf-listview>
      </flutter-cupertino-segmented-tab-item>
      <flutter-cupertino-segmented-tab-item title="评论">
        <webf-listview class="feed-listview" @refresh="onRefreshComment" @loadmore="onLoadMoreComment">
          <div v-if="!isLoggedIn">
            <login-tip />
          </div>
          <div v-else-if="commentFeeds.length === 0" class="empty-state">
            暂无评论内容
          </div>
          <div v-else v-for="item in commentFeeds" :key="item.id">
            <user-feed-card :feed="item"></user-feed-card>
          </div>
        </webf-listview>
      </flutter-cupertino-segmented-tab-item>
      <flutter-cupertino-segmented-tab-item title="点赞">
        <webf-listview class="feed-listview" @refresh="onRefreshLike" @loadmore="onLoadMoreLike">
          <div v-if="!isLoggedIn">
            <login-tip />
          </div>
          <div v-else-if="likeFeeds.length === 0" class="empty-state">
            暂无点赞内容
          </div>
          <div v-else v-for="item in likeFeeds" :key="item.id">
            <user-feed-card :feed="item"></user-feed-card>
          </div>
        </webf-listview>
      </flutter-cupertino-segmented-tab-item>
      <flutter-cupertino-segmented-tab-item title="收藏">
        <webf-listview class="feed-listview" @refresh="onRefreshCollect" @loadmore="onLoadMoreCollect">
          <div v-if="!isLoggedIn">
            <login-tip />
          </div>
          <div v-else-if="collectFeeds.length === 0" class="empty-state">
            暂无收藏内容
          </div>
          <div v-else v-for="item in collectFeeds" :key="item.id">
            <user-feed-card :feed="item"></user-feed-card>
          </div>
        </webf-listview>
      </flutter-cupertino-segmented-tab-item>
    </flutter-cupertino-segmented-tab>
    <flutter-cupertino-toast ref="toast" />
    <flutter-cupertino-loading ref="loading" />

    <!-- Add Karma help modal -->
    <flutter-cupertino-modal-popup
      :show="showKarmaHelp"
      @close="showKarmaHelp = false"
      position="center"
    >
      <div class="karma-help-modal">
        <div class="karma-help-title">什么是 Karma？</div>
        <div class="karma-help-content">积分统计社区贡献，分享、回答、评论上的点赞和浏览能提高积分</div>
        <flutter-cupertino-button
          type="primary"
          class="karma-help-btn"
          @click="showKarmaHelp = false"
        >
          知道了
        </flutter-cupertino-button>
      </div>
    </flutter-cupertino-modal-popup>
  </div>

</template>

<script>
import UserFeedCard from '@/Components/UserFeedCard.vue';
import SmartImage from '@/Components/SmartImage.vue';
import LoginTip from '@/Components/LoginTip.vue';
import UserInfoSkeleton from '@/Components/skeleton/UserInfo.vue';
import { useUserStore } from '@/stores/userStore';
import formatAvatar from '@/utils/formatAvatar';
import { api } from '@/api';

export default {
  components: {
    UserFeedCard,
    LoginTip,
    SmartImage,
    UserInfoSkeleton,
  },
  data() {
    return {
      showKarmaHelp: false,
      user: {
      },
      allFeeds: [],
      shareFeeds: [],
      commentFeeds: [],
      likeFeeds: [],
      collectFeeds: [],
      allPage: 1,
      sharePage: 1,
      commentPage: 1,
      likePage: 1,
      collectPage: 1,
      allHasMore: true,
      shareHasMore: true,
      commentHasMore: true,
      likeHasMore: true,
      collectHasMore: true,
      isLoading: false
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
    userInfo() {
      return this.userStore.userInfo || {};
    },
    formattedAvatar() {
      return formatAvatar(this.userInfo?.avatar);
    },
    formattedTitle() {
      if (this.userInfo.jobTitle) {
        return `${this.userInfo.company} · ${this.userInfo.jobTitle}`;
      }
      return this.userInfo.company;
    }
  },
  methods: {
    async onScreen() {
      if (this.isLoggedIn) {
        await this.loadFeeds('all', 1, true);
      }
    },
    goToLoginPage() {
      window.webf.hybridHistory.pushState({}, '/login');
    },
    goToEditPage() {
      window.webf.hybridHistory.pushState({}, '/edit');
    },
    goToAnswerPage() {
      // window.webf.hybridHistory.pushState({
      //   id: '2046',
      //   questionId: 'xr9ho0',
      // }, '/answer');
      window.webf.hybridHistory.pushState({
        userId: 'b6mtKg',
      }, '/user');
    },
    goToQuestionPage() {
      window.webf.hybridHistory.pushState({
        id: 'v9Vh5b',
      }, '/question');
    },
    goToSettingPage() {
        window.webf.hybridHistory.pushState({}, '/setting');
    },
    async loadFeeds(category = 'all', page = 1, replace = false) {
      if (this.isLoading) return;
      
      try {
        this.isLoading = true;
        if (page === 1) {
          this.$refs.loading.show({
            text: '加载中'
          });
        }
        
        // 调用 API 获取数据
        const res = await api.auth.getUserFeedsList({
          userId: this.userInfo.id,
          category,
          page,
        });
        
        // 处理数据
        if (res && res.data && res.data.feeds) {
          // 更新页面数据
          if (replace) {
            this[`${category}Feeds`] = res.data.feeds;
            this[`${category}Page`] = 1;
          } else {
            this[`${category}Feeds`] = [...this[`${category}Feeds`], ...res.data.feeds];
          }
          
          // 判断是否还有更多数据
          this[`${category}HasMore`] = res.data.feeds.length > 0;
          
          // 更新页码
          if (!replace && res.data.feeds.length > 0) {
            this[`${category}Page`] = page;
          }
          
          console.log(`已加载 ${category} feeds: ${res.data.feeds.length}, 当前页: ${this[`${category}Page`]}`);
        } else {
          this[`${category}HasMore`] = false;
        }
      } catch (error) {
        console.error(`获取${category}列表失败:`, error);
        this.$refs.toast.show({
          type: 'error',
          content: '获取数据失败'
        });
      } finally {
        this.isLoading = false;
        if (page === 1) {
          this.$refs.loading.hide();
        }
      }
    },
    async onRefreshAll() {
      try {
        await this.loadFeeds('all', 1, true);
        this.$refs.toast.show({
          type: 'success',
          content: '刷新成功'
        });
      } catch (error) {
        // 错误已在 loadFeeds 中处理
      }
    },
    async onRefreshShare() {
      try {
        await this.loadFeeds('share', 1, true);
        this.$refs.toast.show({
          type: 'success',
          content: '刷新成功'
        });
      } catch (error) {
        // 错误已在 loadFeeds 中处理
      }
    },
    async onRefreshComment() {
      try {
        await this.loadFeeds('comment', 1, true);
        this.$refs.toast.show({
          type: 'success',
          content: '刷新成功'
        });
      } catch (error) {
        // 错误已在 loadFeeds 中处理
      }
    },
    async onRefreshLike() {
      try {
        await this.loadFeeds('like', 1, true);
        this.$refs.toast.show({
          type: 'success',
          content: '刷新成功'
        });
      } catch (error) {
        // 错误已在 loadFeeds 中处理
      }
    },
    async onRefreshCollect() {
      try {
        await this.loadFeeds('collect', 1, true);
        this.$refs.toast.show({
          type: 'success',
          content: '刷新成功'
        });
      } catch (error) {
        // 错误已在 loadFeeds 中处理
      }
    },
    async onLoadMoreAll() {
      if (!this.allHasMore || this.isLoading) return;
      
      try {
        await this.loadFeeds('all', this.allPage + 1);
      } catch (error) {
        // 错误已在 loadFeeds 中处理
      }
    },
    async onLoadMoreShare() {
      if (!this.shareHasMore || this.isLoading) return;
      
      try {
        await this.loadFeeds('share', this.sharePage + 1);
      } catch (error) {
        // 错误已在 loadFeeds 中处理
      }
    },
    async onLoadMoreComment() {
      if (!this.commentHasMore || this.isLoading) return;
      
      try {
        await this.loadFeeds('comment', this.commentPage + 1);
      } catch (error) {
        // 错误已在 loadFeeds 中处理
      }
    },
    async onLoadMoreLike() {
      if (!this.likeHasMore || this.isLoading) return;
      
      try {
        await this.loadFeeds('like', this.likePage + 1);
      } catch (error) {
        // 错误已在 loadFeeds 中处理
      }
    },
    async onLoadMoreCollect() {
      if (!this.collectHasMore || this.isLoading) return;
      
      try {
        await this.loadFeeds('collect', this.collectPage + 1);
      } catch (error) {
        // 错误已在 loadFeeds 中处理
      }
    },
    getActionName(actionType) {
      const types = {
        'share_link': '分享',
        'comment': '评论',
        'like': '点赞',
        'collect': '收藏',
        'all': '全部'
      };
      return types[actionType] || '未知';
    },
    async onTabChange(e) {
      const index = e.detail;
      const category = ['all', 'share', 'comment', 'like', 'collect'][index];
      
      // 如果数据为空，加载第一页
      if (this[`${category}Feeds`].length === 0) {
        await this.loadFeeds(category, 1, true);
      }
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
      color: var(--font-color-primary);
      margin-bottom: 24px;
      text-align: center;
    }

    .login-button {
      font-size: 18px;
      font-weight: 600;
      color: var(--font-color-secondary);
      text-align: center;
      margin-top: 8px;
      margin-bottom: 24px;
    }

    .title {
      font-size: 14px;
      color: var(--font-color-secondary);
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
          color: var(--font-color-primary);
        }

        .label {
          font-size: 14px;
          color: var(--font-color-secondary);
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
      color: var(--font-color-secondary);
      display: flex;
      align-items: center;

      .karma-count-text {
        margin-right: 4px;
      }

      .karma-help-icon {
        color: var(--font-color-secondary);
      }
    }
  }

  .karma-help-modal {
    background: var(--background-primary);
    border-radius: 12px;
    padding: 20px;
    width: 280px;

    .karma-help-title {
      font-size: 17px;
      font-weight: 600;
      color: var(--font-color-primary);
      margin-bottom: 12px;
      text-align: center;
    }

    .karma-help-content {
      font-size: 15px;
      color: var(--font-color-secondary);
      line-height: 1.5;
      margin-bottom: 20px;
      text-align: center;
    }

    .karma-help-btn {
      width: 100%;
      height: 44px;
      color: var(--font-color-primary);
    }
  }
  
  .feed-listview {
    height: calc(100vh - 350px);
    padding: 16px;
  }
  
  .empty-state {
    padding: 24px;
    text-align: center;
    color: var(--font-color-secondary);
    font-size: 14px;
  }
}
</style>