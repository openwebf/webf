<template>
    <flutter-shimmer>
      <div style="border-radius: 8px; padding: 16px; margin-bottom: 12px;">
        <!-- 内容预览骨架 -->
        <div style="display: flex; justify-content: space-between; margin-bottom: 16px;">
          <!-- 左侧内容 -->
          <div style="flex: 1; margin-right: 16px;">
            <flutter-shimmer-text style="width: 80%; height: 24px; margin-bottom: 12px;" />
            <flutter-shimmer-text style="width: 100%; height: 16px; margin-bottom: 8px;" />
            <flutter-shimmer-text style="width: 60%; height: 16px;" />
          </div>
          
          <!-- 右侧图片占位 -->
          <flutter-shimmer-button style="width: 80px; height: 80px; border-radius: 4px;" />
        </div>
        
        <!-- 底部信息骨架 -->
        <div style="display: flex; align-items: center; padding-top: 12px;">
          <flutter-shimmer-text style="width: 60px; height: 16px; margin-right: 12px;" />
          <flutter-shimmer-text style="width: 40px; height: 16px; margin-right: 12px;" />
          <div style="display: flex; gap: 12px; margin-left: auto;">
            <flutter-shimmer-text style="width: 30px; height: 16px;" />
            <flutter-shimmer-text style="width: 30px; height: 16px;" />
            <flutter-shimmer-text style="width: 30px; height: 16px;" />
          </div>
        </div>
      </div>
    </flutter-shimmer>
  </template>