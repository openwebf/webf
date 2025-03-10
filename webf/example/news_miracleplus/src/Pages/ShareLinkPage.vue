<template>
  <div class="share-link-page" @onscreen="onScreen" @offscreen="offScreen">
    <webf-listview class="webf-listview">
      <PostHeader :user="shareLink.user" />
      <PostContent :post="shareLink" />
      <LinkPreview 
        v-if="shareLink.link"
        :title="shareLink.title"
        :introduction="shareLink.introduction"
        :logo-url="shareLink.logoUrl"
      />
      <ContentBlock
        title="内容导读"
        :content="shareLink.introduction"
      />
      <ContentBlock
        title="自动总结"
        :content="shareLink.summariedLinkContent"
      />
      <NotesList
        :notes="shareLink.notes"
        :notes-list="notesList"
        @note-click="handleNoteClick"
      />
      <RecommendList
        :recommend-list="recommendList"
        @recommend-click="handleRecommendClick"
      />

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
    <InviteModal
      :show="showInviteModal"
      :loading="loadingUsers"
      :users="invitedUsers"
      :search-keyword="searchKeyword"
      @close="onInviteModalClose"
      @search="handleSearchInput"
      @invite="handleInviteUser"
    />
  </div>
</template>

<script>
import { api } from '../api';
import PostHeader from '@/Components/post/PostHeader.vue';
import PostContent from '@/Components/post/PostContent.vue';
import InteractionBar from '@/Components/post/InteractionBar.vue';
import CommentsSection from '@/Components/comment/CommentsSection.vue';
import CommentInput from '@/Components/comment/CommentInput.vue';
import AlertDialog from '@/Components/AlertDialog.vue';
import LinkPreview from '@/Components/post/LinkPreview.vue';
import ContentBlock from '@/Components/post/ContentBlock.vue';
import NotesList from '@/Components/post/NotesList.vue';
import RecommendList from '@/Components/post/RecommendList.vue';
import InviteModal from '@/Components/post/InviteModal.vue';

export default {
  name: 'ShareLinkPage',
  components: {
    PostHeader,
    PostContent,
    InteractionBar,
    CommentsSection,
    CommentInput,
    AlertDialog,
    LinkPreview,
    ContentBlock,
    NotesList,
    RecommendList,
    InviteModal
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
      loadingUsers: false,
      notesList: [],
      recommendList: [],
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
  methods: {
    async onScreen() {
      this.$refs.loading.show({
        text: '加载中'
      });
      const id = window.webf.hybridHistory.state.id;
      this.id = id;
      await this.fetchShareLinkDetail();
      this.$refs.loading.hide();
      await Promise.all([
        this.fetchComments(id),
        this.fetchNotes(id),
        this.fetchRecommendations(id),
      ]);
      api.news.viewCount({ id });
    },
    async offScreen() {
      // Reset data to initial state to prevent flashing when re-entering the page
      this.id = '';
      this.shareLink = {
        user: {}
      };
      this.comments = [];
      this.invitedUsers = [];
      this.searchKeyword = '';
      this.loadingUsers = false;
      this.notesList = [];
      this.recommendList = [];
    },
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
    async fetchComments(id) {
      // TODO: mock data
      const res = await api.comments.getList({ resourceId: id });
      const comments = res.data.comments;
      for (const comment of comments) {
        const subRes = await api.comments.getList({ resourceId: comment.id, resourceType: 'Comment' });
        comment.subComments = subRes.data.comments;
      }
      this.comments = comments;
    },
    async fetchNotes(id) {
      if (!this.shareLink.notes) return;
      
      try {
        const res = await api.news.getNotes(id);
        this.notesList = res.data.notes;
      } catch (error) {
        this.$refs.alertRef.show({
          message: '获取相关问题失败'
        });
      }
    },
    async fetchRecommendations(id) {
      try {
        const res = await api.news.getRecommendations(id);
        this.recommendList = res.data.share_links;
      } catch (error) {
        this.$refs.alertRef.show({
          message: '获取相关分享失败'
        });
      }
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
    },
    async handleNoteClick(note) {
      console.log('handleNoteClick', JSON.stringify(note));
      if (note.comment_id) {
        // TODO：如果有关联的评论，滚动到评论点
      } else {
        // TODO: 否则直接发起评论
        const res = await api.news.createByNote({ noteId: note.id });
        if (res.success) {
          // TODO: 刷新评论列表，滚动到评论列表的第一项
        }
      }
    },
    handleRecommendClick(item) {
      window.webf.hybridHistory.pushState(
        { id: item.id },
        '/share_link'
      );
    },
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
</style>