<template>
    <div class="share-link-card" @click="viewDetail">
      <!-- 标题 -->
      <div class="title">{{ data.title }}</div>
      
      <!-- 内容预览 -->
      <div class="content" :numberOfLines="3">{{ data.content }}</div>
      
      <!-- 底部数据统计 -->
      <div class="footer">
        <share-link-count :viewsCount="data.viewsCount" :likesCount="data.likesCount" :commentsCount="data.commentsCount" />
      </div>
    </div>
</template>
  
<script>
import ShareLinkCount from '../ShareLinkCount.vue';
export default {
name: 'ShareLinkCard',
components: {
    ShareLinkCount,
},
props: {
    data: {
      type: Object,
      required: true
    }
},
methods: {
    viewDetail() {
        console.log('viewDetail');
        window.webf.hybridHistory.pushState({
            id: this.data.id
        }, '/share_link');
    }
}
}
</script>
  
<style lang="scss" scoped>
  .share-link-card {
    padding: 16px;
    background-color: var(--background-primary);
    border-radius: 8px;
    margin-top: 8px;

    .title {
      font-size: 16px;
      font-weight: 500;
      color: var(--font-color-primary);
      margin-bottom: 8px;
    }

    .content {
      font-size: 14px;
      color: var(--font-color-secondary);
      line-height: 20px;
      margin-bottom: 12px;
    }

    .footer {
      flex-direction: row;
      align-items: center;

      .stat-item {
        flex-direction: row;
        align-items: center;
        margin-right: 16px;

        .icon {
          width: 16px;
          height: 16px;
          margin-right: 4px;
        }

        .count {
          font-size: 12px;
          color: var(--font-color-secondary);
        }
      }
    }
  }
</style>