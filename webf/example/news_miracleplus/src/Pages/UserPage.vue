<template>
    <div class="user-page" @onscreen="onScreen" @offscreen="offScreen">
      <div class="user-info-block">
        <smart-image :src="formattedAvatar" class="avatar" />
        <div class="name">{{ user.name }}</div>
        <div class="title">
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
        <div class="karma-count">
          <div class="karma-count-text">社区 Karma： {{ user.karma || 0 }}</div>
          <flutter-cupertino-icon type="question_circle" class="karma-help-icon" @click="showKarmaHelp = true" />
        </div>
      </div>
      
      <flutter-cupertino-segmented-tab @change="onTabChange">
        <flutter-cupertino-segmented-tab-item title="全部">
          <webf-listview class="feed-listview" @refresh="onRefreshAll" @loadmore="onLoadMoreAll">
            <div v-if="allFeeds.length === 0" class="empty-state">
              暂无内容
            </div>
            <div v-else v-for="item in allFeeds" :key="item.id">
              <user-feed-card :feed="item"></user-feed-card>
            </div>
          </webf-listview>
        </flutter-cupertino-segmented-tab-item>
        <flutter-cupertino-segmented-tab-item title="分享">
          <webf-listview class="feed-listview" @refresh="onRefreshShare" @loadmore="onLoadMoreShare">
            <div v-if="shareFeeds.length === 0" class="empty-state">
              暂无分享内容
            </div>
            <div v-else v-for="item in shareFeeds" :key="item.id">
              <user-feed-card :feed="item"></user-feed-card>
            </div>
          </webf-listview>
        </flutter-cupertino-segmented-tab-item>
        <flutter-cupertino-segmented-tab-item title="评论">
          <webf-listview class="feed-listview" @refresh="onRefreshComment" @loadmore="onLoadMoreComment">
            <div v-if="commentFeeds.length === 0" class="empty-state">
              暂无评论内容
            </div>
            <div v-else v-for="item in commentFeeds" :key="item.id">
              <user-feed-card :feed="item"></user-feed-card>
            </div>
          </webf-listview>
        </flutter-cupertino-segmented-tab-item>
        <flutter-cupertino-segmented-tab-item title="点赞">
          <webf-listview class="feed-listview" @refresh="onRefreshLike" @loadmore="onLoadMoreLike">
            <div v-if="likeFeeds.length === 0" class="empty-state">
              暂无点赞内容
            </div>
            <div v-else v-for="item in likeFeeds" :key="item.id">
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
  import { useUserStore } from '@/stores/userStore';
  import formatAvatar from '@/utils/formatAvatar';
  import { api } from '@/api';
  import UserFeedCard from '@/Components/UserFeedCard.vue';
  import SmartImage from '@/Components/SmartImage.vue';
  export default {
    components: {
      UserFeedCard,
      SmartImage,
    },
    async onScreen() {
      console.log('UserPage onScreen');
      const userId = this.getUserId();
      if (userId) {
        await this.getUserInfo(userId);
        await this.loadFeeds('all', userId, 1, true);
      }
    },
    async offScreen() {
      console.log('UserPage offScreen');
    },
    data() {
      return {
        showKarmaHelp: false,
        user: {},
        allFeeds: [],
        shareFeeds: [],
        commentFeeds: [],
        likeFeeds: [],
        // 添加分页数据
        allPage: 1,
        sharePage: 1,
        commentPage: 1,
        likePage: 1,
        // 是否有更多数据
        allHasMore: true,
        shareHasMore: true,
        commentHasMore: true,
        likeHasMore: true,
        // 加载状态
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
      console.log('UserPage mounted');
      const userId = this.getUserId();
      if (userId) {
        await this.getUserInfo(userId);
        await this.loadFeeds('all', userId, 1, true);
      }
    },
    methods: {
      getUserId() {
        const userId = window.webf.hybridHistory.state.userId;
        console.log('userId from state: ', userId);
        return userId;
      },
      async getUserInfo(userId) {
        try {
          this.$refs.loading.show({
            text: '加载中'
          });
          
          const res = await api.user.getFeeds({
              userId,
          });
          
          if (res && res.data && res.data.user) {
            this.user = res.data.user;
            console.log('获取到用户信息: ', this.user);
          } else {
            this.$refs.toast.show({
              type: 'error',
              content: '获取用户信息失败'
            });
          }
        } catch (error) {
          console.error('获取用户信息失败:', error);
          this.$refs.toast.show({
            type: 'error',
            content: '获取用户信息失败'
          });
        } finally {
          this.$refs.loading.hide();
        }
      },
      async loadFeeds(category = 'all', userId, page = 1, replace = false) {
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
            userId,
            category,
            page,
          });
          
          // 处理数据
          if (res && res.data && res.data.feeds && res.data.feeds.length > 0) {
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
            
            if (this[`${category}Feeds`].length === 0) {
              // 如果没有数据，创建示例数据
              this.createSampleFeeds(category);
            }
          }
        } catch (error) {
          console.error(`获取${category}列表失败:`, error);
          this.$refs.toast.show({
            type: 'error',
            content: '获取数据失败'
          });
          
          if (this[`${category}Feeds`].length === 0) {
            // 如果出错且没有数据，创建示例数据
            this.createSampleFeeds(category);
          }
        } finally {
          this.isLoading = false;
          if (page === 1) {
            this.$refs.loading.hide();
          }
        }
      },
      async onRefreshAll() {
        const userId = this.getUserId();
        if (!userId) return;
        
        try {
          await this.loadFeeds('all', userId, 1, true);
          this.$refs.toast.show({
            type: 'success',
            content: '刷新成功'
          });
        } catch (error) {
          // 错误已在 loadFeeds 中处理
        }
      },
      async onRefreshShare() {
        const userId = this.getUserId();
        if (!userId) return;
        
        try {
          await this.loadFeeds('share', userId, 1, true);
          this.$refs.toast.show({
            type: 'success',
            content: '刷新成功'
          });
        } catch (error) {
          // 错误已在 loadFeeds 中处理
        }
      },
      async onRefreshComment() {
        const userId = this.getUserId();
        if (!userId) return;
        
        try {
          await this.loadFeeds('comment', userId, 1, true);
          this.$refs.toast.show({
            type: 'success',
            content: '刷新成功'
          });
        } catch (error) {
          // 错误已在 loadFeeds 中处理
        }
      },
      async onRefreshLike() {
        const userId = this.getUserId();
        if (!userId) return;
        
        try {
          await this.loadFeeds('like', userId, 1, true);
          this.$refs.toast.show({
            type: 'success',
            content: '刷新成功'
          });
        } catch (error) {
          // 错误已在 loadFeeds 中处理
        }
      },
      async onLoadMoreAll() {
        const userId = this.getUserId();
        if (!userId || !this.allHasMore || this.isLoading) return;
        
        try {
          await this.loadFeeds('all', userId, this.allPage + 1);
        } catch (error) {
          // 错误已在 loadFeeds 中处理
        }
      },
      async onLoadMoreShare() {
        const userId = this.getUserId();
        if (!userId || !this.shareHasMore || this.isLoading) return;
        
        try {
          await this.loadFeeds('share', userId, this.sharePage + 1);
        } catch (error) {
          // 错误已在 loadFeeds 中处理
        }
      },
      async onLoadMoreComment() {
        const userId = this.getUserId();
        if (!userId || !this.commentHasMore || this.isLoading) return;
        
        try {
          await this.loadFeeds('comment', userId, this.commentPage + 1);
        } catch (error) {
          // 错误已在 loadFeeds 中处理
        }
      },
      async onLoadMoreLike() {
        const userId = this.getUserId();
        if (!userId || !this.likeHasMore || this.isLoading) return;
        
        try {
          await this.loadFeeds('like', userId, this.likePage + 1);
        } catch (error) {
          // 错误已在 loadFeeds 中处理
        }
      },
      createSampleFeeds(category) {
        // 为测试创建样本数据
        const sampleFeed = {
          id: `sample-${Date.now()}`,
          actionType: category === 'all' ? 'share_link' : category,
          createdAt: new Date().toISOString(),
          account: {
            id: this.user.id,
            name: this.user.name,
            avatar: this.user.avatar,
            company: this.user.company,
            jobTitle: this.user.jobTitle
          },
          item: {
            id: `item-${Date.now()}`,
            title: '示例内容标题',
            content: '这是一段示例内容，用于测试用户动态展示。',
            commentCount: 5,
            likeCount: 10,
            liked: false,
            bookmarked: false
          }
        };
        
        if (category === 'all') {
          // 为全部标签创建多种类型的示例数据
          this.allFeeds = [
            { ...sampleFeed, actionType: 'share_link', id: 'sample-share' },
            { 
              ...sampleFeed, 
              actionType: 'comment', 
              id: 'sample-comment',
              item: {
                ...sampleFeed.item,
                content: '这是一条示例评论内容',
                resourceType: 'ShareLink',
                resource: {
                  id: 'resource-1',
                  brief: '评论的原始内容标题'
                }
              } 
            },
            { 
              ...sampleFeed, 
              actionType: 'like', 
              id: 'sample-like',
              item: {
                ...sampleFeed.item,
                __typename: 'ShareLink',
                liked: true
              } 
            }
          ];
        } else if (category === 'share') {
          this.shareFeeds = [sampleFeed];
        } else if (category === 'comment') {
          this.commentFeeds = [{
            ...sampleFeed,
            item: {
              ...sampleFeed.item,
              content: '这是一条示例评论内容',
              resourceType: 'ShareLink',
              resource: {
                id: 'resource-1',
                brief: '评论的原始内容标题'
              }
            }
          }];
        } else if (category === 'like') {
          this.likeFeeds = [{
            ...sampleFeed,
            item: {
              ...sampleFeed.item,
              __typename: 'ShareLink',
              liked: true
            }
          }];
        }
      },
      getActionName(actionType) {
        const types = {
          'share_link': '分享',
          'comment': '评论',
          'like': '点赞',
          'all': '全部'
        };
        return types[actionType] || '未知';
      },
      async onTabChange(e) {
        console.log('onTabChange: ', e.detail);
        const index = e.detail;
        const userId = this.getUserId();
        if (!userId) return;
        
        const category = ['all', 'share', 'comment', 'like'][index];
        
        // 如果数据为空，加载第一页
        if (this[`${category}Feeds`].length === 0) {
          await this.loadFeeds(category, userId, 1, true);
        }
      }
    }
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
        
        .karma-count-text {
          margin-right: 4px;
        }

        .karma-help-icon {
          color: #999;
        }
      }
    }

    .karma-help-modal {
      background: #fff;
      border-radius: 12px;
      padding: 20px;
      width: 280px;

      .karma-help-title {
        font-size: 17px;
        font-weight: 600;
        color: #333;
        margin-bottom: 12px;
        text-align: center;
      }

      .karma-help-content {
        font-size: 15px;
        color: #666;
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
      height: calc(100vh - 280px);
      padding: 16px;
    }
    
    .empty-state {
      padding: 24px;
      text-align: center;
      color: #999;
      font-size: 14px;
    }
  }
  </style>