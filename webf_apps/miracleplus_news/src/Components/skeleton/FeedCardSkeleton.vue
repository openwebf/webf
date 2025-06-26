<template>
    <flutter-shimmer>
      <div style="border-radius: 8px; padding: 16px; margin-bottom: 12px;">
        <!-- 标题骨架 -->
        <flutter-shimmer-text style="width: 80%; height: 24px; margin-bottom: 12px;" />
        
        <!-- 描述骨架：两行 -->
        <flutter-shimmer-text style="width: 100%; height: 16px; margin-bottom: 8px;" />
        <flutter-shimmer-text style="width: 60%; height: 16px; margin-bottom: 16px;" />
        
        <!-- 底部信息骨架 -->
        <div style="display: flex; align-items: center; padding-top: 12px;">
          <flutter-shimmer-text style="width: 60px; height: 16px; margin-right: 12px;" />
          <flutter-shimmer-text style="width: 40px; height: 16px; margin-right: 12px;" />
          <flutter-shimmer-text style="width: 100px; height: 16px;" />
        </div>
      </div>
    </flutter-shimmer>
  </template>