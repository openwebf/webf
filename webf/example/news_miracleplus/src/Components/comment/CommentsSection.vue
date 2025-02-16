<template>
    <div class="comments-section">
      <div class="comments-header">评论 {{ total }}</div>
      <div class="comment-list">
        <CommentItem 
          v-for="comment in comments" 
          :key="comment.id"
          :comment="comment"
        />
      </div>
    </div>
  </template>
  
  <script>
  import CommentItem from './CommentItem.vue';
  
  export default {
    name: 'CommentsSection',
    components: {
      CommentItem
    },
    props: {
      comments: {
        type: Array,
        default: () => []
      },
      total: {
        type: Number,
        default: 0
      }
    }
  }
  </script>

  <style lang="scss" scoped>
  .comments-section {
    margin-top: 20px;
  }
  </style>
