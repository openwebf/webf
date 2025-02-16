<template>
    <div class="base-comment-item">
      <div class="comment-header">
        <div class="user-info">
          <img :src="formattedAvatar" class="avatar" />
          <div class="user-meta">
            <span class="username">{{ comment.user.name }}</span>
            <span class="time">{{ formattedTime }}</span>
          </div>
        </div>
      </div>
      
      <div class="comment-content">
        <div class="comment-text" v-html="formattedContent"></div>
      </div>
  
      <div class="comment-actions">
        <div class="left-actions">
          <button class="action-btn">
            <flutter-cupertino-icon type="hand_thumbsup" class="icon" />
            <span>{{ comment.likesCount }}</span>
          </button>
          <button class="action-btn">
            <flutter-cupertino-icon type="chat_bubble" class="icon" />
            <span>回复</span>
          </button>
        </div>
        <div class="right-actions">
          <button class="action-btn">
            <flutter-cupertino-icon type="share" class="icon" />
          </button>
        </div>
      </div>
  
    </div>
  </template>
  
  <script>
  import formatAvatar from '@/utils/formatAvatar';
  export default {
    name: 'BaseCommentItem',
    props: {
      comment: {
        type: Object,
        required: true
      }
    },
    computed: {
      formattedAvatar() {
        return formatAvatar(this.comment.user.avatar);
      },
      formattedContent() {
        if (this.comment.richContent) {
          try {
            const parsedContent = JSON.parse(this.comment.richContent);
            return parsedContent.map(block => {
              if (block.type === 'paragraph') {
                return `<p>${block.children.map(child => child.text).join('')}</p>`;
              }
              return '';
            }).join('');
          } catch (e) {
            return this.comment.content || '';
          }
        }
        return this.comment.content || '';
      },
      formattedTime() {
        return new Date(this.comment.createdAt).toLocaleString();
      }
    }
  }
  </script>
  
  <style lang="scss" scoped>
  .base-comment-item {
    background: #fff;
    border-radius: 8px;
    margin-bottom: 8px;
  
    .comment-header {
      margin-bottom: 12px;
  
      .user-info {
        display: flex;
        align-items: center;
        gap: 12px;
  
        .avatar {
          width: 40px;
          height: 40px;
          border-radius: 50%;
          object-fit: cover;
          margin-right: 10px;
        }
  
        .user-meta {
          display: flex;
          flex-direction: column;
          gap: 4px;
  
          .username {
            font-size: 16px;
            font-weight: 500;
            color: #333;
          }
  
          .time {
            font-size: 14px;
            color: #999;
          }
        }
      }
    }
  
    .comment-content {
      margin-bottom: 12px;
      
      .comment-text {
        font-size: 15px;
        line-height: 1.5;
        color: #333;
      }
    }
  
    .comment-actions {
      display: flex;
      justify-content: space-between;
      align-items: center;
      
      .left-actions {
        display: flex;
        gap: 16px;
      }
  
      .action-btn {
        display: flex;
        align-items: center;
        gap: 4px;
        background: none;
        border: none;
        padding: 4px 8px;
        color: #999;
        font-size: 14px;
        cursor: pointer;
      }
  
      .icon {
        margin-right: 4px;
      }
    }
  }
  </style>