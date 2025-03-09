<template>
  <div class="share-link-page">
    <webf-listview class="webf-listview">
      <PostHeader :user="shareLink.user" />
      <PostContent :post="shareLink" />
      <InteractionBar :views-count="shareLink.viewsCount" :likes-count="shareLink.likesCount"
        :comments-count="shareLink.commentsCount" :followers-count="shareLink.followersCount"
        :bookmarks-count="shareLink.bookmarksCount" :is-followed="isFollowed" :is-liked="isLiked"
        :is-bookmarked="isBookmarked" @follow="handleFollow" @like="handleLike" @bookmark="handleBookmark"
        @invite="handleInvite" @share="handleShare" />
      <CommentsSection :comments="comments" :total="shareLink.commentsCount" />
      <CommentInput @submit="handleCommentSubmit" />
    </webf-listview>
    <alert-dialog ref="alertRef" />
    <flutter-cupertino-loading ref="loading" />
    <flutter-cupertino-toast ref="toast" />
    <flutter-cupertino-modal-popup 
        :show="showInviteModal" 
        height="400"
        @close="onInviteModalClose"
      >
        <div class="invite-modal-content">
          <div class="invite-search-container">
            <flutter-cupertino-input 
              placeholder="搜索用户" 
              class="invite-search-input" 
              :value="searchKeyword"
              @input="handleSearchInput"
            />
          </div>
          <div class="invite-users-list">
            <div v-if="loadingUsers" class="loading-indicator">
              <flutter-cupertino-activity-indicator />
              <span>加载中...</span>
            </div>
            <div v-else-if="invitedUsers.length === 0" class="no-users">
              没有找到匹配的用户
            </div>
            <webf-listview v-else class="invite-users-list">
              <div 
                v-for="user in invitedUsers" 
                :key="user.id" 
                class="invite-user-item"
              >
                <img :src="user.avatar" class="user-avatar" />
                <div class="user-info">
                  <div class="user-name">{{ user.name }}</div>
                  <div class="user-company">{{ user.company }} {{ user.jobTitle }}</div>
                </div>
                <flutter-cupertino-icon
                  type="bookmark" 
                  class="invite-btn"
                  @click="handleInviteUser(user)"
                />
              </div>
            </webf-listview>
          </div>
        </div>
    </flutter-cupertino-modal-popup>
  </div>
</template>

<script>
import { api } from '../api';
import PostHeader from '@/Components/post/PostHeader.vue';
import PostContent from '@/Components/post/PostContent.vue';
import InteractionBar from '@/Components/post/InteractionBar.vue';
import CommentsSection from '@/Components/comment/CommentsSection.vue';
import CommentInput from '@/Components/comment/CommentInput.vue';

export default {
  name: 'ShareLinkPage',
  components: {
    PostHeader,
    PostContent,
    InteractionBar,
    CommentsSection,
    CommentInput
  },
  data() {
    return {
      id: '',
      shareLink: {
        user: {}
      },
      comments: [],
      showInviteModal: false,
      invitedUsers: [],
      searchKeyword: '',
      loadingUsers: false
    }
  },
  computed: {
    isLiked() {
      return this.shareLink.currentUserLike === 'like';
    },
    isBookmarked() {
      return this.shareLink.currentUserBookmark === 'bookmark';
    },
    isFollowed() {
      return !!this.shareLink.followed;
    }
  },
  async activated() {
    console.log('share link page mounted');
    this.$refs.loading.show({
      text: '加载中'
    });
    const id = window.webf.hybridHistory.state.id;
    this.id = id;
    await this.fetchShareLinkDetail();
    this.comments = await this.fetchComments(id);
    this.$refs.loading.hide();
    api.news.viewCount({ id });
  },
  methods: {
    async fetchShareLinkDetail() {
      try {
        const res = await api.news.getDetail(this.id);
        this.shareLink = res.data.share_link;
      } catch (error) {
        this.$refs.alertRef.show({
          message: '获取分享详情失败'
        });
      }
    },
    async fetchComments() {
      // TODO: mock data
      const res = await api.comments.getList({ resourceId: 55558 });
      const comments = res.data.comments;
      for (const comment of comments) {
        const subRes = await api.comments.getList({ resourceId: comment.id, resourceType: 'Comment' });
        comment.subComments = subRes.data.comments;
      }
      return comments;
    },
    async handleCommentSubmit(content) {
      console.log('handleCommentSubmit', content);
      const structuredContent = JSON.stringify([{
        type: 'paragraph',
        children: [
          {
            text: content,
          }
        ]
      }]);
      // Handle new comment submission
      const commentRes = await api.comments.create({
        resourceId: this.id,
        resourceType: 'ShareLink',
        content: structuredContent,
      });
      console.log('commentRes', commentRes);
      if (commentRes.success) {
        this.$refs.toast.show({
          type: 'success',
          content: '评论成功',
        });
        this.comments = await this.fetchComments(this.id);
      }
    },
    async handleFollow(newFollowState) {
      console.log('handleFollow', newFollowState);
      try {
        let res;
        if (newFollowState) {
          res = await api.news.follow(this.id);
        } else {
          res = await api.news.unfollow(this.id);
        }
        console.log('follow res', res);
        if (res.success) {
          // // 更新本地状态
          // this.shareLink.followed = newFollowState;
          // // 更新关注数
          // this.shareLink.followersCount = newFollowState
          //   ? (this.shareLink.followersCount || 0) + 1
          //   : (this.shareLink.followersCount || 1) - 1;
          await this.fetchShareLinkDetail();
        }
      } catch (error) {
        this.$refs.alertRef.show({
          title: '提示',
          message: newFollowState ? '关注失败' : '取消关注失败'
        });
      }
    },
    async handleInvite() {
      console.log('invite clicked');
      this.showInviteModal = true;
      await this.fetchInvitedUsers();
    },
    onInviteModalClose() {
      this.showInviteModal = false;
      this.searchKeyword = '';
      this.invitedUsers = [];
    },
    async fetchInvitedUsers() {
      try {
        this.loadingUsers = true;
        const res = await api.user.getInvitedUsers({
          resource: 'ShareLink',
          id: this.id,
          search: this.searchKeyword
        });
        this.invitedUsers = res.data.users;
      } catch (error) {
        this.$refs.alertRef.show({
          message: '获取用户列表失败'
        });
      } finally {
        this.loadingUsers = false;
      }
    },
    handleSearchInput(e) {
      this.searchKeyword = e.detail;
      // 使用防抖处理搜索输入
      if (this.searchTimeout) {
        clearTimeout(this.searchTimeout);
      }
      
      this.searchTimeout = setTimeout(() => {
        this.fetchInvitedUsers();
      }, 300);
    },
    async handleInviteUser(user) {
      try {
        this.$refs.loading.show({
          text: '邀请中'
        });
        
        const res = await api.user.invite({
          resourceType: 'ShareLink',
          resourceId: this.id,
          userId: user.id
        });
        
        if (res.success) {
          this.$refs.toast.show({
            type: 'success',
            content: `已成功邀请 ${user.name}`
          });
          this.onInviteModalClose();
        }
      } catch (error) {
        this.$refs.alertRef.show({
          message: '邀请用户失败'
        });
      } finally {
        this.$refs.loading.hide();
      }
    },
    handleShare() {
      // 处理分享按钮点击
      console.log('share clicked');
    },
    async handleLike() {
      // 处理点赞按钮点击
      if (this.isLiked) {
        await api.news.unlike(this.id);
      } else {
        await api.news.like(this.id);
      }
      await this.fetchShareLinkDetail();
    },
    async handleBookmark() {
      await api.news.bookmark(this.id);
      await this.fetchShareLinkDetail();
    }
  }
}
</script>

<style lang="scss" scoped>
.share-link-page {
  background: var(--background-primary);
  padding: 16px;
  padding-bottom: 60px; // Space for comment input
}

.webf-listview {
  height: 100vh;
}

.invite-modal-content {
  display: flex;
  flex-direction: column;
  height: 100%;
  padding: 16px;
  
  .invite-search-container {
    margin-bottom: 16px;
    
    .invite-search-input {
      width: 100%;
    }
  }
  
  .invite-users-list {
    height: 300px;
    flex: 1;
    overflow-y: auto;
    
    .loading-indicator {
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      height: 100px;
      color: #999;
    }
    
    .no-users {
      display: flex;
      align-items: center;
      justify-content: center;
      height: 100px;
      color: #999;
    }
    
    .invite-user-item {
      display: flex;
      align-items: center;
      padding: 12px 0;
      border-bottom: 1px solid #eee;
      
      .user-avatar {
        width: 40px;
        height: 40px;
        border-radius: 50%;
        margin-right: 12px;
        object-fit: cover;
      }
      
      .user-info {
        flex: 1;
        
        .user-name {
          font-size: 16px;
          font-weight: 500;
          color: #333;
          margin-bottom: 4px;
        }
        
        .user-company {
          font-size: 12px;
          color: #666;
        }
      }
      
      .invite-btn {
        padding: 4px 12px;
        font-size: 14px;
      }
    }
  }
}
</style>