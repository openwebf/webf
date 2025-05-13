<template>
    <div style="display: flex; align-items: center; font-size: 12px; color: var(--secondary-font-color); padding-top: 12px;">
      <span style="margin-right: 12px;">{{ userName }}</span>
      <span style="margin-right: 12px;">{{ computedCreatedAt }}</span>
      <share-link-count :viewsCount="viewsCount" :likesCount="likesCount" :commentsCount="commentsCount" />
    </div>
  </template>
  
  <script>  
  import ShareLinkCount from './ShareLinkCount.vue';
  export default {
    name: 'CardBottomInfo',
    components: {
        ShareLinkCount,
    },
    props: {
      userName: {
        type: String,
        required: true
      },
      createdAt: {
        type: String,
        required: true
      },
      viewsCount: {
        type: Number,
        default: 0
      },
      likesCount: {
        type: Number,
        default: 0
      },
      commentsCount: {
        type: Number,
        default: 0
      }
    },
    computed: {
      computedCreatedAt() {
        const now = new Date();
        const createdAt = new Date(this.createdAt);
        const diffTime = Math.abs(now - createdAt);
        const diffMinutes = Math.floor(diffTime / (1000 * 60));
        const diffHours = Math.floor(diffTime / (1000 * 60 * 60));
        const diffDays = Math.floor(diffTime / (1000 * 60 * 60 * 24));
        
        if (diffHours < 1) {
          return `${diffMinutes}分钟前`;
        } else if (diffDays < 1) {
          return `${diffHours}小时前`;
        } else {
          return `${diffDays}天前`;
        }
      }
    }
  }
  </script>