<template>
    <div class="bottom-info">
      <span class="source">{{ userName }}</span>
      <span class="time">{{ computedCreatedAt }}</span>
      <div class="stats">
        <span class="views">
          <flutter-cupertino-icon type="eye" class="icon" />{{ viewsCount }}
        </span>
        <span class="likes">
          <flutter-cupertino-icon type="hand_thumbsup" class="icon" />{{ likesCount }}
        </span>
        <span class="comments">
          <flutter-cupertino-icon type="ellipsis_circle" class="icon" />{{ commentsCount }}
        </span>
      </div>
    </div>
  </template>
  
  <script>
  export default {
    name: 'CardBottomInfo',
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
  
  <style lang="scss" scoped>
  .bottom-info {
    display: flex;
    align-items: center;
    font-size: 12px;
    color: var(--secondary-font-color);
    padding-top: 12px;
  
    .source, .time {
      margin-right: 12px;
    }
  
    .stats {
      display: flex;
      margin-left: auto;
  
      span {
        margin-left: 12px;
        display: flex;
        align-items: center;
      }
  
      .icon {
        margin-right: 4px;
      }
    }
  }
  </style>