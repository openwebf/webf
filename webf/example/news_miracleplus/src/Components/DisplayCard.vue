<template>
    <div class="display-card">
        <display-content :item="item" />
        <card-bottom-info 
          :userName="item.user.name"
          :createdAt="item.createdAt"
          :viewsCount="item.viewsCount"
          :likesCount="item.likesCount"
          :commentsCount="item.commentsCount"
        />
    </div>
  </template>
  
<script>
  import DisplayContent from './DisplayContent.vue'
  import CardBottomInfo from './CardBottomInfo.vue'
  export default {
    name: 'DisplayCard',
    components: {
      DisplayContent,
      CardBottomInfo
    },
    props: {
      item: {
        type: Object,
        required: true
      }
    },
    computed: {
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
  
  <style lang="scss" scoped>
.display-card {
  background: var(--background-primary);
  border-radius: 8px;
  padding: 16px;
  margin-bottom: 12px;
}
</style> 