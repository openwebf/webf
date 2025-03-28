<template>
    <flutter-shimmer>
      <div class="display-card">
        <!-- 内容预览骨架 -->
        <div class="content-preview">
          <!-- 左侧内容 -->
          <div class="content-left">
            <flutter-shimmer-text class="title" />
            <flutter-shimmer-text class="description" />
            <flutter-shimmer-text class="description short" />
          </div>
          
          <!-- 右侧图片占位 -->
          <flutter-shimmer-button class="logo" />
        </div>
        
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
  .display-card {
    border-radius: 8px;
    padding: 16px;
    margin-bottom: 12px;
  
    .content-preview {
      display: flex;
      justify-content: space-between;
      margin-bottom: 16px;
  
      .content-left {
        flex: 1;
        margin-right: 16px;
  
        .title {
          width: 80%;
          height: 24px;
          margin-bottom: 12px;
        }
  
        .description {
          width: 100%;
          height: 16px;
          margin-bottom: 8px;
  
          &.short {
            width: 60%;
          }
        }
      }
  
      .logo {
        width: 80px;
        height: 80px;
        border-radius: 4px;
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