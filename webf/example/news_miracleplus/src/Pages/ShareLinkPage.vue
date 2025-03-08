<template>
    <div class="share-link-page">
      <webf-listview class="webf-listview">
        <PostHeader :user="shareLink.user" />
        <PostContent :post="shareLink" />
        <InteractionBar 
            :views-count="shareLink.viewsCount"
          :likes-count="shareLink.likesCount"
          :comments-count="shareLink.commentsCount"
        />
        <CommentsSection 
          :comments="comments" 
          :total="shareLink.commentsCount" 
        />
        <!-- <CommentInput @submit="handleCommentSubmit" /> -->
      </webf-listview>
      <flutter-cupertino-loading ref="loading" />
    </div>
  </template>
  
  <script>
  import { api } from '../api';
  import PostHeader from '@/Components/post/PostHeader.vue';
  import PostContent from '@/Components/post/PostContent.vue';
  import InteractionBar from '@/Components/post/InteractionBar.vue';
  import CommentsSection from '@/Components/comment/CommentsSection.vue';
  // import AlertDialog from '@/Components/AlertDialog.vue';
  
  export default {
    name: 'ShareLinkPage',
    components: {
      PostHeader,
      PostContent,
      InteractionBar,
      CommentsSection,
      // AlertDialog,
    },
    data() {
      return {
        id: '',
        shareLink: {},
        comments: []
      }
    },
    async mounted() {
      console.log('share link page mounted');
      this.$refs.loading.show({
        text: '加载中'
      });
      const id = window.webf.hybridHistory.state.id || '59251';
      console.log('id: ', id);
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
      handleCommentSubmit() {
        // Handle new comment submission
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
  </style>