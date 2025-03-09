<template>
    <div v-if="recommendList.length > 0" class="content-block recommend-block">
      <div class="block-title">相关分享</div>
      <div class="recommend-list">
        <div 
          v-for="item in recommendList" 
          :key="item.id"
          class="recommend-item"
          @click="$emit('recommend-click', item)"
        >
          <div class="recommend-title">{{ item.title }}</div>
          <div v-if="item.linkDescription" class="recommend-desc">{{ item.linkDescription }}</div>
        </div>
      </div>
    </div>
  </template>
  
  <script>
  export default {
    name: 'RecommendList',
    props: {
      recommendList: {
        type: Array,
        default: () => []
      }
    },
    emits: ['recommend-click']
  }
  </script>
  
  <style lang="scss" scoped>
  .recommend-block {
    margin: 16px 0;

    .block-title {
      font-size: 16px;
      font-weight: 600;
      color: #1C1C1E;
      margin-bottom: 8px;
    }
    .recommend-list {
      .recommend-item {
        padding: 12px 0;
        cursor: pointer;
        
        &:not(:last-child) {
          border-bottom: 1px solid rgba(60, 60, 67, 0.1);
        }
        
        &:active {
          opacity: 0.7;
        }
        
        .recommend-title {
          font-size: 14px;
          font-weight: 500;
          line-height: 1.4;
          color: #1C1C1E;
          margin-bottom: 4px;
        }
        
        .recommend-desc {
          font-size: 13px;
          line-height: 1.3;
          color: #8E8E93;
          display: -webkit-box;
          -webkit-line-clamp: 2;
          line-clamp: 2;
          -webkit-box-orient: vertical;
          overflow: hidden;
        }
      }
    }
  }
  </style>