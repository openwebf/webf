<template>
    <div class="share-link-preview-card" @click="viewDetail">
      <div v-if="data.link" class="preview-box">
        <img 
          v-if="data.logoUrl" 
          class="logo" 
          :src="data.logoUrl"
          mode="aspectFill"
        />
        <text class="link" :numberOfLines="1">{{ data.title }}</text>
      </div>
      <div class="footer">
        <share-link-count :viewsCount="data.viewsCount" :likesCount="data.likesCount" :commentsCount="data.commentsCount" />
      </div>
    </div>
  </template>
  
  <script>
  import ShareLinkCount from '../ShareLinkCount.vue';
  export default {
    name: 'ShareLinkPreviewCard',
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
        window.webf.hybridHistory.pushState({
          id: this.data.id
        }, '/share_link');
      }
    }
  }
  </script>
  
  <style scoped>
  .share-link-preview-card {
    padding: 16px;
    background-color: #FFFFFF;
    margin-bottom: 8px;

    .preview-box {
      display: flex;
      flex-direction: row;
      align-items: center;
      padding: 12px;
      background-color: #F5F5F5;
      border-radius: 6px;
      margin-bottom: 12px;

      .logo {
        width: 20px;
        height: 20px;
        border-radius: 4px;
        margin-right: 8px;
      }

      .link {
        flex: 1;
        font-size: 14px;
        color: #666666;
      }
    }
  }
  </style>