<template>
  <div class="comment-item">
    <BaseCommentItem 
      :comment="comment"
      :root-id="rootId" 
    />
    <div v-if="hasSubComments" class="sub-comments">
      <div 
        v-for="subComment in comment.subComments" 
        :key="subComment.id" 
        class="sub-comment-item"
      >
        <CommentItem 
          :comment="subComment"
          :root-id="isTopLevel ? String(subComment.id) : rootId"
          :is-sub-comment="true"
        />

      </div>
    </div>
  </div>
</template>

<script>
import BaseCommentItem from './BaseCommentItem.vue';
export default {
  name: 'CommentItem',
  components: {
    BaseCommentItem
  },
  props: {
    comment: {
      type: Object,
      required: true
    },
    rootId: {
      type: String,
      default: ''
    },
    isTopLevel: {
      type: Boolean,
      default: false
    },
  },
  computed: {
    hasSubComments() {
      return this.comment.subComments && this.comment.subComments.length > 0;
    },
  }
}
</script>

<style lang="scss" scoped>
.comment-item {
  background: var(--background-primary);
  border-radius: 8px;
  padding: 4px;
  margin-bottom: 8px;

  .sub-comments {
    margin-top: 12px;
    margin-left: 5px;
    padding-left: 4px;

    .sub-comment-item {
      background: var(--background-secondary);
      border-radius: 8px;
      padding: 4px;
      margin-bottom: 8px;
    }
  }
}
</style>