<template>
    <div class="feed-card" @click="viewDetail">
      <!-- Top link -->
      <div class="top-link" v-if="isPinned">置顶</div>
      
      <template v-if="item.item.link">
        <div class="description">{{ item.item.content }}</div>
        <display-content :item="item.item" />
      </template>

      <template v-else>
        <!-- Title -->
        <div class="title">{{ truncatedTitle }}</div>

        <!-- Description -->
        <p class="description">{{ truncatedContent }}</p>
      </template>
      <!-- Bottom info -->
      <card-bottom-info 
          :userName="item.account.name"
          :createdAt="item.createdAt"
          :viewsCount="item.item.viewsCount"
          :likesCount="item.item.likesCount"
          :commentsCount="item.item.commentsCount"
      />
    </div>
  </template>
  
  <script>
  import CardBottomInfo from './CardBottomInfo.vue'
  import DisplayContent from './DisplayContent.vue'
  export default {
    name: 'FeedCard',
    components: {
      CardBottomInfo,
      DisplayContent
    },
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
    },
    methods: {
      viewDetail() {
        window.webf.hybridHistory.pushState({
            id: this.item.item.id
        }, '/share_link');
      }
    }
  }
</script>

<style lang="scss" scoped>
.feed-card {
  background: var(--background-primary);
  border-radius: 8px;
  padding: 16px;
  margin-bottom: 12px;

  .top-link {
    color: var(--link-color);
    font-size: 12px;
    margin-bottom: 8px;
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
}
</style>
  
