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
        <div class="comment-text">{{ parseContent(comment.content || comment.richContent) }}</div>
      </div>
  
      <div class="comment-actions">
        <div class="left-actions">
          <button class="action-btn" @click="handleLike">
            <flutter-cupertino-icon :type="isLiked ? 'hand_thumbsup_fill' : 'hand_thumbsup'" class="icon" />
            <span>{{ likesCount }}</span>
          </button>
          <button class="action-btn" @click="handleReply">
            <flutter-cupertino-icon type="chat_bubble" class="icon" />
            <span>回复</span>
          </button>
          <button v-if="showEditBtn" class="action-btn" @click="handleEdit">
            <flutter-cupertino-icon type="pencil" class="icon" />
            <span>编辑</span>
          </button>
        </div>
        <div class="right-actions">
          <button class="action-btn">
            <flutter-cupertino-icon type="share" class="icon" />
          </button>
        </div>
      </div>
      <flutter-cupertino-modal-popup 
        :show="showModal" 
        height="400"
        @close="onModalClose"
      >
        <div class="comment-modal-content">
          <flutter-cupertino-input 
            :placeholder="isEditing ? '请编辑评论内容' : '请输入评论内容'" 
            class="comment-input" 
            :value="editContent"
            @input="handleInput"
          />
          <flutter-cupertino-button 
            type="primary" 
            class="comment-confirm-btn"
            @click="confirmAction"
          >
            {{ isEditing ? '保存' : '回复' }}
          </flutter-cupertino-button>
        </div>
      </flutter-cupertino-modal-popup>
    </div>
  </template>
  
  <script>
  import { useUserStore } from '@/stores/userStore'
  import formatAvatar from '@/utils/formatAvatar';
  import { api } from '@/api';
  export default {
    name: 'BaseCommentItem',
    props: {
      comment: {
        type: Object,
        required: true
      },
    },
    setup() {
      const userStore = useUserStore();
      return {
        userStore,
      }
    },
    data() {
      return {
        likesCount: this.comment?.likesCount || 0,
        isLiked: this.comment?.currentUserLike === 'like',
        showModal: false,
        isEditing: false,
        editContent: '',
      }
    },
    computed: {
      formattedAvatar() {
        return formatAvatar(this.comment.user.avatar);
      },
      formattedTime() {
        const time = new Date(this.comment.createdAt).toLocaleString();
        return time;
      },
      showEditBtn() {
        return this.comment.user.id === this.userStore?.userInfo.id;
      }
    },
    methods: {
      parseContent(content) {
          try {
              const parsed = JSON.parse(content);
              // TODO: simple parse for text content
              return parsed.map(block => {
                  if (block.type === 'paragraph') {
                      return block.children.map(child => child.text).join('');
                  }
                  return '';
              }).join('\n');
          } catch (e) {
              return content;
          }
      },
      async handleLike() {
        let res;
        if (this.isLiked) {
          res = await api.comments.unlike(this.comment.id);
          if (res.success) {
            this.likesCount--;
            this.isLiked = false;
          }
        } else {
          res = await api.comments.like(this.comment.id);
          if (res.success) {
            this.likesCount++;
            this.isLiked = true;
          }
        }
      },
      handleReply() {
        this.isEditing = false;
        this.editContent = '';
        this.showModal = true;
      },
      handleEdit() {
        this.isEditing = true;
        this.editContent = this.parseContent(this.comment.content || this.comment.richContent);
        this.showModal = true;
      },
      handleInput(e) {
        this.editContent = e.detail;
      },
      onModalClose() {
        this.showModal = false;
      },
      async confirmAction() {
        if (this.isEditing) {
          // 处理编辑评论的逻辑
          console.log('保存编辑的评论:', this.editContent);
          // 这里可以添加调用API保存编辑评论的代码
          // await api.comments.update(this.comment.id, this.editContent);
        } else {
          // 处理回复评论的逻辑
          console.log('回复评论:', this.editContent);
          // 这里可以添加调用API回复评论的代码
          // await api.comments.reply(this.comment.id, this.editContent);
        }
        this.showModal = false;
        this.editContent = '';
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

    .comment-modal-content {
      padding: 12px;
      display: flex;
      flex-direction: column;

      .comment-input {
        margin-bottom: 12px;
      }
      .comment-confirm-btn {
        color: var(--font-color-primary);
      }
    }
  }
  </style>