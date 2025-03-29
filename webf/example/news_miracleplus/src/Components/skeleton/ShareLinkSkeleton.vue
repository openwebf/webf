<template>
    <div class="share-link-skeleton">
      <!-- 用户信息区域 -->
      <div class="user-info">
        <flutter-shimmer>
          <flutter-shimmer-avatar width="40" height="40" />
          <div class="user-meta">
            <flutter-shimmer-text style="width: 80px; height: 16px; margin-bottom: 4px;" />
            <flutter-shimmer-text style="width: 120px; height: 14px;" />
          </div>
        </flutter-shimmer>
      </div>
  
      <!-- 分享链接内容区域 -->
      <div class="content">
        <flutter-shimmer>
          <!-- 标题 -->
          <flutter-shimmer-text style="width: 90%; height: 20px; margin-bottom: 12px;" />
          <!-- 描述 -->
          <flutter-shimmer-text style="width: 100%; height: 16px; margin-bottom: 8px;" />
          <flutter-shimmer-text style="width: 95%; height: 16px; margin-bottom: 8px;" />
          <flutter-shimmer-text style="width: 60%; height: 16px;" />
        </flutter-shimmer>
      </div>
  
      <!-- 链接预览区域 -->
      <div class="link-preview">
        <flutter-shimmer>
          <div class="preview-box">
            <flutter-shimmer-text style="width: 100%; height: 120px; margin-bottom: 8px;" />
            <flutter-shimmer-text style="width: 80%; height: 16px;" />
          </div>
        </flutter-shimmer>
      </div>
  
      <!-- 底部操作栏 -->
      <div class="actions">
        <flutter-shimmer>
          <div class="action-buttons">
            <flutter-shimmer-button width="60" height="28" />
            <flutter-shimmer-button width="60" height="28" />
            <flutter-shimmer-button width="60" height="28" />
          </div>
        </flutter-shimmer>
      </div>
    </div>
  </template>
  
  <style lang="scss" scoped>
  .share-link-skeleton {
    padding: 16px;
    background: var(--background-primary);
  
    .user-info {
      display: flex;
      align-items: center;
      margin-bottom: 16px;
  
      .user-meta {
        margin-left: 12px;
      }
    }
  
    .content {
      margin-bottom: 16px;
    }
  
    .link-preview {
      margin-bottom: 16px;
      
      .preview-box {
        border-radius: 8px;
        overflow: hidden;
      }
    }
  
    .actions {
      .action-buttons {
        display: flex;
        gap: 12px;
      }
    }
  }
  </style>