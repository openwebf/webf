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
          <flutter-cupertino-textarea
            class="comment-input" 
            :placeholder="isEditing ? '请编辑评论内容' : '请输入评论内容'"
            minLines="3"
            autoSize="true"
            maxLength="1000"
            :val="editContent"
            @input="handleInput"
          />
          <flutter-cupertino-button 
            type="primary" 
            class="comment-confirm-btn"
            @click="confirmAction"
            :disabled="submitStatus !== 'idle'"
          >
            <template v-if="submitStatus === 'idle'">
              {{ isEditing ? '保存' : '回复' }}
            </template>
            <flutter-cupertino-icon
              class="comment-confirm-btn-icon"
              v-else-if="submitStatus === 'submitting'"
              type="rays"
            />
            <flutter-cupertino-icon 
              class="comment-confirm-btn-icon"
              v-else-if="submitStatus === 'success'"
              type="check_mark_circled"
            />
            <flutter-cupertino-icon 
              class="comment-confirm-btn-icon"
              v-else-if="submitStatus === 'error'"
              type="clear_circled"
            />
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
    inject: ['updateComment', 'addCommentReply'],
    props: {
      comment: {
        type: Object,
        required: true
      },
      rootId: {
        type: String,
        default: ''
      }
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
        submitStatus: 'idle', // 'idle' | 'submitting' | 'success' | 'error'
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
        if (this.submitStatus === 'submitting') {
          return;
        }
        this.showModal = false;
        this.submitStatus = 'idle';
      },
      formatToRichContent(text) {
        const paragraphs = text.split('\n').filter(p => p.trim());

        const richContent = paragraphs.map(paragraph => ({
          type: 'paragraph',
          children: [{
            type: 'text',
            text: paragraph
          }]
        }));

        return JSON.stringify(richContent);
      },
      async confirmAction() {
        const richContent = this.formatToRichContent(this.editContent);
        
        if (this.isEditing) {
          try {
            this.submitStatus = 'submitting';
            const res = await api.comments.update({
              id: this.comment.id,
              content: richContent,
              richContent: richContent,
            });
            
            if (res.success) {
              this.submitStatus = 'success';
              this.updateComment(this.comment.id, {
                content: richContent,
                richContent: richContent,
              });

              setTimeout(() => {
                this.showModal = false;
                this.editContent = '';
                this.submitStatus = 'idle';  // 重置状态
              }, 1000);
            } else {
              this.submitStatus = 'error';
              setTimeout(() => {
                this.submitStatus = 'idle';  // 重置状态
              }, 1000);
            }
          } catch (error) {
            this.submitStatus = 'error';
            setTimeout(() => {
              this.submitStatus = 'idle';
            }, 1000);
          }
        } else {
          try {
            this.submitStatus = 'submitting';
            console.log('reply comment.id', this.comment.id);
            console.log('reply rootId', this.rootId);
            console.log('reply richContent', richContent);
            const res = await api.comments.reply({
              id: this.comment.id,
              richContent: richContent,
              rootId: this.rootId || undefined,
            });
            console.log('reply res', JSON.stringify(res));
            
            if (res.success) {
              this.submitStatus = 'success';
              const commentRes = await api.comments.getSingleComment(res['comment_id']);
              this.addCommentReply(this.comment.id, commentRes.data.comment);
              
              setTimeout(() => {
                this.showModal = false;
                this.editContent = '';
                this.submitStatus = 'idle';
              }, 1000);
            } else {
              this.submitStatus = 'error';
              setTimeout(() => {
                this.submitStatus = 'idle';
              }, 1000);
            }
          } catch (error) {
            this.submitStatus = 'error';
            setTimeout(() => {
              this.submitStatus = 'idle';
            }, 1000);
          }
        }
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
        width: 100%;
        margin-bottom: 12px;
      }
      .comment-confirm-btn {
        color: var(--font-color-primary);
        min-width: 60px;
        display: flex;
        justify-content: center;
        align-items: center;

        .comment-confirm-btn-icon {
          font-size: 20px;
        }
      }
    }
  }
  </style>