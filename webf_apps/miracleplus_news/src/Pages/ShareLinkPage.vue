<template>
  <div class="share-link-page" @onscreen="onScreen" @offscreen="offScreen">
    <BaseShareLinkPage page-type="shareLink">
      <template #comment-input="{ handleCommentSubmit }">
        <CommentInput @submit="handleCommentSubmit" />
      </template>
    </BaseShareLinkPage>
  </div>
</template>

<script>
import BaseShareLinkPage from '@/Components/post/BaseShareLinkPage.vue';
import CommentInput from '@/Components/comment/CommentInput.vue';

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
</style>