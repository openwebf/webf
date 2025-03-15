<template>
  <div @onscreen="onScreen" @offscreen="offScreen">
    <BaseShareLinkPage page-type="shareLink">
      <template #comment-input>
        <CommentInput @submit="handleCommentSubmit" />
      </template>
    </BaseShareLinkPage>
  </div>
</template>

<script>
import BaseShareLinkPage from '@/Components/post/BaseShareLinkPage.vue';
import CommentInput from '@/Components/comment/CommentInput.vue';
import { api } from '../api';

export default {
  name: 'ShareLinkPage',
  components: {
    BaseShareLinkPage,
    CommentInput,
  },

  methods: {
    async onScreen() {
      const id = window.webf.hybridHistory.state.id;
      this.id = id;
    },
    
    async offScreen() {
      this.id = '';
    },

    async handleCommentSubmit(content) {
      // 处理评论提交
      const structuredContent = JSON.stringify([{
        type: 'paragraph',
        children: [{ text: content }]
      }]);
      
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
      }
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