<template>
    <div class="share-link-card" @click="viewDetail">
      <!-- 标题 -->
      <text class="title">{{ data.title }}</text>
      
      <!-- 内容预览 -->
      <text class="content" :numberOfLines="3">{{ data.content }}</text>
      
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
    background-color: #FFFFFF;
    margin-bottom: 8px;

    .title {
      font-size: 16px;
      font-weight: 500;
      color: #333333;
      margin-bottom: 8px;
    }

    .content {
      font-size: 14px;
      color: #666666;
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
          color: #999999;
        }
      }
    }
  }
</style>