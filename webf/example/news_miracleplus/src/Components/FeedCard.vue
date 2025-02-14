<template>
    <div class="feed-card">
      <!-- Top link -->
      <div class="top-link" v-if="isPinned">置顶</div>
      
      <template v-if="item.item.introduction">
        <!-- Description -->
        <p class="description">{{ truncatedContent }}</p>

        <!-- Title -->
        <img class="logo" :src="item.item.logoUrl" />
        <h2 class="title">{{ truncatedTitle }}</h2>

        <!-- Introduction -->
        <p class="introduction">{{ truncatedIntroduction }}</p>
      </template>

      <template v-else>
        <!-- Title -->
        <h2 class="title">{{ truncatedTitle }}</h2>

        <!-- Description -->
        <p class="description">{{ truncatedContent }}</p>
      </template>
      <!-- Bottom info -->
      <div class="bottom-info">
        <span class="source">{{ item.account.name }}</span>
        <span class="time">{{ computedCreatedAt }}</span>
        <div class="stats">
          <span class="views"><flutter-cupertino-icon type="eye" class="icon" />{{ item.item.viewsCount }}</span>
          <span class="likes"><flutter-cupertino-icon type="hand_thumbsup" class="icon" />{{ item.item.likesCount }}</span>
          <span class="comments"><flutter-cupertino-icon type="ellipsis_circle" class="icon" />{{ item.item.commentsCount }}</span>
        </div>
      </div>
    </div>
  </template>
  
  <script>
  export default {
    name: 'FeedCard',
    props: {
      item: {
        type: Object,
        default: () => ({
          item: {
            title: '',
            content: '',
            introduction: '',
            link: '',
            logoUrl: '',
            viewsCount: 0,
            likesCount: 0, 
            commentsCount: 0
          },
          account: {
            name: '',
            avatar: ''
          },
          createdAt: '',
          pinnedAt: null,
        })
      },
      account: Object,
      anoymous: Boolean,
      createdAt: String,
      pinnedAt: String,
      id: Number,
      actionType: String,
    },
    computed: {
      isPinned() {
        return this.item.pinnedAt !== null;
      },
      truncatedTitle() {
        return this.item.item.title.length > 50 ? this.item.item.title.slice(0, 50) + '...' : this.item.item.title;
      },
      truncatedContent() {
        // Truncate content to 100 characters and add ellipsis
        const content = this.item.item.content || '';
        return content.length > 100 ? content.slice(0, 100) + '...' : content;
      },
      truncatedIntroduction() {
        const introduction = this.item.item.introduction || '';
        return introduction.length > 100 ? introduction.slice(0, 100) + '...' : introduction;
      },
      computedCreatedAt() {
        const now = new Date();
        const createdAt = new Date(this.item.createdAt);
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
  
  <style scoped>
  .feed-card {
    background: var(--background-primary);
    border-radius: 8px;
    padding: 16px;
    margin-bottom: 12px;
  }
  
  .top-link {
    color: var(--link-color);
    /* background-color: #E5F2FF; */
    font-size: 12px;
  }
  
  .title {
    font-size: 16px;
    font-weight: bold;
    margin-bottom: 8px;
    color: var(--font-color);
  }
  
  .description {
    font-size: 14px;
    color: var(--secondary-font-color);
    margin-bottom: 12px;
    line-height: 1.5;
  }
  
  .bottom-info {
    display: flex;
    align-items: center;
    font-size: 12px;
    color: var(--secondary-font-color);
  }
  
  .source, .time {
    margin-right: 12px;
  }
  
  .stats {
    display: flex;
  }
  
  .stats span {
    margin-left: 12px;
    display: flex;
    align-items: center;
  }
  
  .stats .icon {
    margin-right: 4px;
  }
  </style>