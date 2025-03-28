<template>
    <flutter-shimmer>
      <div class="comment-card">
        <!-- 标题骨架 -->
        <flutter-shimmer-text class="title" />
        
        <!-- 描述骨架 -->
        <flutter-shimmer-text class="description" />
        
        <!-- 底部信息骨架 -->
        <div class="bottom-info">
          <flutter-shimmer-text class="source" />
          <flutter-shimmer-text class="time" />
          <div class="stats">
            <flutter-shimmer-text class="stat" />
            <flutter-shimmer-text class="stat" />
            <flutter-shimmer-text class="stat" />
          </div>
        </div>
      </div>
    </flutter-shimmer>
  </template>
  
  <style lang="scss" scoped>
  .comment-card {
    border-radius: 8px;
    padding: 16px;
    margin-bottom: 12px;
  
    .title {
      width: 70%;
      height: 20px;
      margin-bottom: 12px;
    }
  
    .description {
      width: 100%;
      height: 16px;
      margin-bottom: 16px;
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
  
      .stats {
        display: flex;
        gap: 12px;
        margin-left: auto;
  
        .stat {
          width: 30px;
          height: 16px;
        }
      }
    }
  }
  </style>