<template>
    <div class="comments-section">
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
      }
    }
  }
  </script>

  <style lang="scss" scoped>
  .comments-section {
    margin-top: 20px;
  }
  </style>
