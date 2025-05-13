<template>
    <div class="question-skeleton">
      <!-- 问题头部信息 -->
      <div class="question-header">
        <!-- 用户信息 -->
        <flutter-shimmer>
          <div class="user-info">
            <flutter-shimmer-avatar width="40" height="40" />
            <div class="user-meta">
              <flutter-shimmer-text style="width: 80px; height: 16px; margin-bottom: 4px;" />
              <flutter-shimmer-text style="width: 120px; height: 14px;" />
            </div>
          </div>
        </flutter-shimmer>
  
        <!-- 问题标题 -->
        <flutter-shimmer>
          <flutter-shimmer-text style="width: 95%; height: 24px; margin: 16px 0;" />
        </flutter-shimmer>
        
        <!-- 问题描述 -->
        <flutter-shimmer>
          <flutter-shimmer-text style="width: 100%; height: 16px; margin-bottom: 8px;" />
          <flutter-shimmer-text style="width: 95%; height: 16px; margin-bottom: 8px;" />
          <flutter-shimmer-text style="width: 80%; height: 16px; margin-bottom: 16px;" />
        </flutter-shimmer>
  
        <!-- 标签 -->
        <flutter-shimmer>
          <div class="tags">
            <flutter-shimmer-button width="60" height="24" radius="12" />
            <flutter-shimmer-button width="80" height="24" radius="12" />
          </div>
        </flutter-shimmer>
  
        <!-- 操作按钮 -->
        <flutter-shimmer>
          <div class="actions">
            <flutter-shimmer-button width="70" height="32" />
            <flutter-shimmer-button width="70" height="32" />
          </div>
        </flutter-shimmer>
      </div>
  
      <!-- 回答列表 -->
      <div class="answers">
        <div class="answer-item" v-for="i in 3" :key="i">
          <flutter-shimmer>
            <div class="answer-user">
              <flutter-shimmer-avatar width="32" height="32" />
              <flutter-shimmer-text style="width: 80px; height: 16px; margin-left: 8px;" />
            </div>
          </flutter-shimmer>
          
          <flutter-shimmer>
            <flutter-shimmer-text style="width: 100%; height: 16px; margin: 8px 0;" />
            <flutter-shimmer-text style="width: 95%; height: 16px; margin-bottom: 8px;" />
            <flutter-shimmer-text style="width: 60%; height: 16px;" />
          </flutter-shimmer>
        </div>
      </div>
    </div>
  </template>
  
  <style lang="scss" scoped>
  .question-skeleton {
    padding: 16px;
    background: var(--background-primary);
  
    .question-header {
      margin-bottom: 24px;
  
      .user-info {
        display: flex;
        align-items: center;
        margin-bottom: 16px;
  
        .user-meta {
          margin-left: 12px;
        }
      }
  
      .tags {
        display: flex;
        gap: 8px;
        margin-bottom: 16px;
      }
  
      .actions {
        display: flex;
        gap: 12px;
      }
    }
  
    .answers {
      .answer-item {
        padding: 16px 0;
        border-bottom: 1px solid var(--border-color);
  
        .answer-user {
          display: flex;
          align-items: center;
          margin-bottom: 12px;
        }
      }
    }
  }
  </style>