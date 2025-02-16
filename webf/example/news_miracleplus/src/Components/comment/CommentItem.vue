<template>
  <div class="comment-item">
    <BaseCommentItem :comment="comment" />
    <div v-if="hasSubComments" class="sub-comments">
      <div 
        v-for="subComment in comment.subComments" 
        :key="subComment.id" 
        class="sub-comment-item"
      >
        <CommentItem 
          :comment="subComment"
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
    }
  },
  computed: {
    hasSubComments() {
      return this.comment.subComments && this.comment.subComments.length > 0;
    }
  }
}
</script>

<style lang="scss" scoped>
.comment-item {
  background: #fff;
  border-radius: 8px;
  padding: 4px;
  margin-bottom: 8px;

  .sub-comments {
    margin-top: 12px;
    margin-left: 5px;
    padding-left: 4px;

    .sub-comment-item {
      background: #f8f8f8;
      border-radius: 8px;
      padding: 4px;
      margin-bottom: 8px;
    }
  }
}
</style>