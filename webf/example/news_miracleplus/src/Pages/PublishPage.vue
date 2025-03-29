<template>
  <div class="publish-page">
    <div class="publish-form">
      <div class="form-item">
        <flutter-cupertino-input
          placeholder="标题"
          class="title-input"
          @input="handleTitleInput"
        />
      </div>

      <div class="form-item">
        <flutter-cupertino-input
          placeholder="标签（选填），多标签以空格分隔"
          class="tags-input"
          @input="handleTagsInput"
        />
      </div>

      <div class="form-item">
        <flutter-cupertino-textarea
          placeholder="内容"
          class="content-input"
          minLines="9"
          autoSize="true"
          transparent="true"
          @input="handleContentInput"
        />
      </div>

      <div class="form-item">
        <flutter-cupertino-input
          placeholder="分享链接（选填）"
          class="link-input"
          @input="handleLinkInput"
        />
      </div>

      <div class="form-item" v-if="link.trim() !== ''">
        <flutter-cupertino-input
          placeholder="链接描述（选填）"
          class="link-input"
          @input="handleLinkDescInput"
        />
      </div>

      <flutter-cupertino-button 
        class="publish-btn" 
        :type="isFormValid ? 'primary' : 'secondary'"
        :disabled="!isFormValid" 
        @click="handlePublish"
      >
        发布
      </flutter-cupertino-button>
    </div>

    <flutter-cupertino-loading ref="loading" />
    <flutter-cupertino-toast ref="toast" />
    <alert-dialog
      ref="alertRef"
      title="提示"
      confirm-text="确定"
    />
  </div>
</template>

<script>
import AlertDialog from '@/Components/AlertDialog.vue';
import { api } from '@/api';
import tabBarManager from '@/utils/tabBarManager';

export default {
  name: 'PublishPage',
  components: {
    AlertDialog
  },
  data() {
    return {
      title: '',
      tags: '',
      content: '',
      link: '',
      linkDesc: '',
      isSubmitting: false
    };
  },
  computed: {
    isFormValid() {
      // 标题和内容为必填项
      return this.title.trim() !== '' && this.content.trim() !== '';
    },
    formattedTags() {
      // 将空格分隔的标签转换为数组
      if (!this.tags) return [];
      return this.tags.split(' ').filter(tag => tag.trim() !== '');
    }
  },
  methods: {
    handleBack() {
      // 返回上一页
      window.webf.hybridHistory.back();
    },
    handleTitleInput(e) {
      this.title = e.detail;
    },
    handleTagsInput(e) {
      this.tags = e.detail;
    },
    handleContentInput(e) {
      this.content = e.detail;
    },
    handleLinkInput(e) {
      this.link = e.detail;
    },
    handleLinkDescInput(e) {
      this.linkDesc = e.detail;
    },
    
    async handlePublish() {
      if (!this.isFormValid || this.isSubmitting) {
        return;
      }

      try {
        this.isSubmitting = true;
        this.$refs.loading.show({
          text: '发布中'
        });
        const publishData = {
          title: this.title,
          content: this.content,
          tags: this.formattedTags,
          anonymous: false,
          summarize: true,
        };

        // 如果有分享链接，添加到请求数据中
        if (this.link.trim() !== '') {
          publishData.link = this.link;
        }
        if (this.linkDesc.trim() !== '') {
          publishData.link_desc = this.linkDesc;
        }

        const result = await api.news.publish(publishData);
        console.log('publish result', result);
        if (result.success) {
          this.$refs.toast.show({
            type: 'success',
            content: '发布成功'
          });
          // 发布成功后返回首页或详情页
          setTimeout(() => {
            if (result.share_link_id) {
              // 如果返回了文章ID，跳转到详情页
              window.webf.hybridHistory.pushState({
                id: result.share_link_id
              }, '/share_link');
            } else {
              // 否则返回首页
              tabBarManager.switchTab('/home');
            }
          }, 1500);
        } else {
          this.$refs.alertRef.show({
            message: result.message || '发布失败，请重试'
          });
        }
      } catch (error) {
        console.error('发布失败:', error);
        this.$refs.alertRef.show({
          message: '发布失败，请检查网络连接后重试'
        });
      } finally {
        this.isSubmitting = false;
        this.$refs.loading.hide();
      }
    }
  }
};
</script>

<style lang="scss" scoped>
.publish-page {
  width: 100%;
  height: 100%;
  display: flex;
  flex-direction: column;
  background-color: var(--background-secondary);
}

.publish-header {
  background-color: var(--background-primary);
  padding: 12px 16px;
  border-bottom: 1px solid var(--border-primary);
  
  .header-content {
    display: flex;
    align-items: center;
    justify-content: space-between;
    
    .back-btn {
      padding: 0;
    }
    
    .title {
      font-size: 18px;
      font-weight: 500;
    }
    
    .placeholder {
      width: 24px; // 与返回按钮宽度相同，保持标题居中
    }
  }
}

.publish-form {
  flex: 1;
  padding: 16px;
  overflow-y: auto;

  .form-item {
    margin-bottom: 16px;
    background-color: var(--background-primary);
    border-radius: 8px;
    overflow: hidden;
  }

  .title-input {
    font-size: 18px;
    font-weight: 500;
    padding: 12px;
  }

  .tags-input {
    font-size: 14px;
    padding: 12px;
  }

  .content-input {
    font-size: 16px;
    padding: 12px;
    min-height: 200px;
  }

  .link-input {
    font-size: 14px;
    padding: 12px;
  }
  
  .publish-btn {
    width: 100%;
    height: 44px;
    margin-top: 24px;
    font-size: 16px;
    font-weight: 500;
    
    &:disabled {
      opacity: 0.5;
    }
  }
}
</style>