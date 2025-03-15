<template>
    <BaseShareLinkPage
      page-type="comment"
      :single-comment-id="commentId"
    >
      <template #view-all="{ commentsCount }">
        <div class="view-all-btn" @click="goToSharePage">
          查看全部 {{ commentsCount }} 条评论
        </div>
      </template>
    </BaseShareLinkPage>
  </template>
  
  <script>
  import BaseShareLinkPage from '@/Components/post/BaseShareLinkPage.vue';
  
  export default {
    name: 'CommentPage',
    components: {
      BaseShareLinkPage
    },
  
    data() {
      return {
        commentId: '',
        shareLinkId: '',
      }
    },
  
    methods: {
      async onScreen() {
        const { id, shareLinkId } = window.webf.hybridHistory.state;
        this.commentId = id;
        this.shareLinkId = shareLinkId;
      },
  
      async offScreen() {
        this.commentId = '';
        this.shareLinkId = '';
      },
  
      goToSharePage() {
        window.webf.hybridHistory.pushState(
          { id: this.shareLinkId },
          '/share_link'
        );
      }
    }
  }
  </script>
  
  <style lang="scss" scoped>
  .view-all-btn {
    text-align: center;
    font-size: 14px;
    color: #666666;
    padding: 16px 0;
    border-bottom: 1px solid var(--border-secondary);
  }
  </style>