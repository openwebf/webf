<template>
    <div class="interaction-bar">
      <div class="stats">
        <span class="views">
          <flutter-cupertino-icon type="eye" class="icon" />{{ viewsCount }}
        </span>
        <span class="likes">
          <flutter-cupertino-icon type="hand_thumbsup" class="icon" />{{ likesCount }}
        </span>
        <span class="comments">
          <flutter-cupertino-icon type="ellipsis_circle" class="icon" />{{ commentsCount }}
        </span>
      </div>
      <div class="actions">
        <flutter-cupertino-button @click="$emit('discuss')" class="action-button">
          <div class="button-content">
            <flutter-cupertino-icon type="chat_bubble" class="icon" />
            <span>邀请讨论</span>
          </div>
        </flutter-cupertino-button>
        <flutter-cupertino-button @click="$emit('share')" class="action-button">
          <div class="button-content">
            <flutter-cupertino-icon type="share" class="icon" />
            <span>分享</span>
          </div>
        </flutter-cupertino-button>
      </div>
    </div>
  </template>
  
  <script>
  export default {
    name: 'InteractionBar',
    props: {
      viewsCount: Number,
      likesCount: Number,
      commentsCount: Number
    }
  }
  </script>
  <style lang="scss" scoped>
  .interaction-bar {
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    align-items: center;
  
    .stats {
      display: flex;
  
      span {
        margin-left: 12px;
        display: flex;
        align-items: center;
      }
  
      .icon {
        margin-right: 4px;
      }
    }
    .actions {
      margin-top: 12px;
      display: flex;

      .action-button {
        margin-right: 16px;
        text-align: center;
        border-radius: 8px;
        .button-content {
          display: flex;
          justify-content: center;
          align-items: center;
          text-align: center;
          color: var(--button-primary-text, #fff); 
          
          .icon {
            margin-right: 4px;
            color: var(--button-primary-text, #fff); 
          }
        }
      }
    }
  }
  </style>