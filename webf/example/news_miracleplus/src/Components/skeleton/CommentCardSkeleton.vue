<template>
    <flutter-shimmer>
      <div style="border-radius: 8px; padding: 16px; margin-bottom: 12px;">
        <!-- 标题骨架 -->
        <flutter-shimmer-text style="width: 70%; height: 20px; margin-bottom: 12px;" />
        
        <!-- 描述骨架 -->
        <flutter-shimmer-text style="width: 100%; height: 16px; margin-bottom: 16px;" />
        
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