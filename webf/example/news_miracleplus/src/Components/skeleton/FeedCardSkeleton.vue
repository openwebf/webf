<template>
    <flutter-shimmer>
      <div class="feed-card-skeleton">
        <!-- 标题骨架 -->
        <flutter-shimmer-text class="title" />
        
        <!-- 描述骨架：两行 -->
        <flutter-shimmer-text class="description" />
        <flutter-shimmer-text class="description second-line" />
        
        <!-- 底部信息骨架 -->
        <div class="bottom-info">
          <flutter-shimmer-text class="source" />
          <flutter-shimmer-text class="time" />
          <flutter-shimmer-text class="count" />
        </div>
      </div>
    </flutter-shimmer>
  </template>
  
  <style lang="scss">
  .feed-card-skeleton {
    border-radius: 8px;
    padding: 16px;
    margin-bottom: 12px;
  
    .title {
      width: 80%;
      height: 24px;
      margin-bottom: 12px;
    }
  
    .description {
      width: 100%;
      height: 16px;
      margin-bottom: 8px;
  
      &.second-line {
        width: 60%;
        margin-bottom: 16px;
      }
    }
  
    .bottom-info {
      display: flex;
      align-items: center;
      padding-top: 12px;
  
      .source {
        width: 60px;
        height: 16px;
        margin-right: 12px;
      }
  
      .time {
        width: 40px;
        height: 16px;
        margin-right: 12px;
      }
  
      .count {
        width: 100px;
        height: 16px;
      }
    }
  }
  </style>