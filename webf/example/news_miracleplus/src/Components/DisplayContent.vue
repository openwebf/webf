<template>
    <div class="display-content">
      <!-- Title -->
      <h2 class="title">{{ truncatedTitle }}</h2>
  
      <div class="content-wrapper">
        <!-- Logo Image -->
        <img v-if="item.logoUrl" :src="item.logoUrl" class="logo-image" />
        
        <div class="text-content">
          <!-- Description -->
          <p class="description">{{ truncatedContent }}</p>
        </div>
      </div>
    </div>
  </template>
  
  <script>
  export default {
    name: 'DisplayContent',
    props: {
      item: {
        type: Object,
        required: true
      }
    },
    computed: {
      truncatedTitle() {
        const title = this.item.title;
        return title.length > 50 ? title.slice(0, 50) + '...' : title ;
      },
      truncatedContent() {
        const content = this.item.linkDescription;
        return content.length > 100 ? content.slice(0, 100) + '...' : content;
      }
    }
  }
  </script>
  
  <style lang="scss" scoped>
  .display-content {
    border: 1px solid #F3F4F6;
    border-radius: 8px;
    padding: 4px 10px;
    
    .title {
      font-size: 16px;
      font-weight: bold;
      margin-bottom: 5px;
      color: var(--font-color);
    }
  
    .content-wrapper {
      display: flex;
      gap: 10px;
      margin-bottom: 12px;
      align-items: flex-start;
    }
  
    .logo-image {
      width: 40px;
      height: 40px;
      object-fit: cover;
      border-radius: 8px;
      flex-shrink: 0;
      margin-right: 10px;
    }
  
    .text-content {
      flex: 1;
      min-width: 0;
    }
  
    .description {
      font-size: 14px;
      color: var(--secondary-font-color);
      line-height: 1.5;
      margin: 0;
      display: -webkit-box;
      -webkit-line-clamp: 3;
      line-clamp: 3;
      -webkit-box-orient: vertical;
      overflow: hidden;
    }
  }
  </style>