<template>
    <div class="edit-page" @onscreen="onScreen">
        <div class="avatar-section">
            <div class="avatar-wrapper">
                <smart-image :src="formattedAvatar" class="avatar" />
            </div>
        </div>

        <div class="form-section">
            <div class="input-group">
                <div class="label">用户名</div>
                <flutter-cupertino-input @input="handleNameInput" :val="formData.name" placeholder="请输入用户名"
                    class="input" />
            </div>
            <div class="input-group">
                <div class="label">邮箱</div>
                <flutter-cupertino-input @input="handleEmailInput" :val="formData.email" placeholder="请输入邮箱"
                    class="input" />
            </div>
            <div class="input-group">
                <div class="label">公司/机构/学校</div>
                <flutter-cupertino-input @input="handleCompanyInput" :val="formData.company" placeholder="请输入公司/机构/学校"
                    class="input" />
            </div>
            <div class="input-group">
                <div class="label">职位</div>
                <flutter-cupertino-input @input="handleJobTitleInput" :val="formData.jobTitle" placeholder="请输入职位"
                    class="input" />
            </div>

            <div class="input-group">
                <div class="label">个性签名</div>
                <flutter-cupertino-input @input="handleDescInput" :val="formData.desc" placeholder="请输入个性签名"
                    class="input" type="textarea" :rows="3" />
            </div>
        </div>

        <div class="button-section">
            <flutter-cupertino-button class="save-button" @click="handleSave">
                保存
            </flutter-cupertino-button>
        </div>

        <flutter-cupertino-loading ref="loading" />
        <flutter-cupertino-toast ref="toast" />
    </div>
</template>

<script>
import SmartImage from '@/Components/SmartImage.vue';
import { useUserStore } from '@/stores/userStore';
import formatAvatar from '@/utils/formatAvatar';
import tabBarManager from '@/utils/tabBarManager';
import { api } from '@/api';

export default {
    name: 'EditPage',
    components: {
        SmartImage
    },
    setup() {
        const userStore = useUserStore();
        return {
            userStore
        }
    },
    data() {
        return {
            userId: '',
            formData: {
                name: '',
                email: '',
                company: '',
                jobTitle: '',
                desc: '',
            },
        }
    },
    computed: {
        formattedAvatar() {
            return formatAvatar(this.userInfo?.avatar);
        },
        userInfo() {
            return this.userStore.userInfo || {};
        },
    },
    methods: {
        async onScreen() {
            await this.loadUserInfo();
        },
        async loadUserInfo() {
            try {
                this.showLoading('加载中')
                const res = await api.auth.getUserInfo();
                if (res.data && res.data.object) {
                    const userInfo = res.data.object;
                    this.userId = userInfo.id;
                    this.formData.name = userInfo.name || ''
                    this.formData.email = userInfo.email || ''
                    this.formData.company = userInfo.company || ''
                    this.formData.jobTitle = userInfo.jobTitle || ''
                    this.formData.desc = userInfo.desc || ''
                }
            } catch (error) {
                console.error('获取用户信息失败:', error)
                this.showToast('获取用户信息失败', 'error')
            } finally {
                this.hideLoading()
            }
        },

        handleNameInput(e) {
            this.formData.name = e.detail;
        },

        handleEmailInput(e) {
            this.formData.email = e.detail;
        },

        handleCompanyInput(e) {
            this.formData.company = e.detail;
        },

        handleJobTitleInput(e) {
            this.formData.jobTitle = e.detail;
        },

        handleDescInput(e) {
            this.formData.desc = e.detail;
        },

        async handleSave() {
            if (!this.formData.name.trim()) {
                this.showToast('请输入用户名', 'warning')
                return
            }

            try {
                this.showLoading('保存中')
                const res = await api.auth.updateUserInfo(this.userId, {
                    name: this.formData.name,
                    email: this.formData.email,
                    company: this.formData.company,
                    job_title: this.formData.jobTitle,
                    desc: this.formData.desc
                })

                if (res.success) {
                    await this.userStore.setUserInfo({
                        ...this.userStore.userInfo,
                        ...this.formData
                    });
                    this.showToast('保存成功', 'success')
                    setTimeout(() => {
                        tabBarManager.switchTab('/my');
                    }, 2000);
                }
            } catch (error) {
                console.error('保存用户信息失败:', error)
                this.showToast('保存失败', 'error')
            } finally {
                this.hideLoading()
            }
        },

        showLoading(text = '加载中') {
            this.$refs.loading.show({
                text
            })
        },

        hideLoading() {
            this.$refs.loading.hide()
        },

        showToast(content, type = 'info') {
            this.$refs.toast.show({
                content,
                type
            })
        }
    }
}
</script>

<style scoped>
.edit-page {
    min-height: 100vh;
    background-color: var(--background-primary);
    padding: 20px;
}

.avatar-section {
    display: flex;
    justify-content: center;
    margin: 20px 0 40px;
}

.avatar-wrapper {
    display: flex;
    flex-direction: column;
    align-items: center;
    cursor: pointer;
}

.avatar {
    width: 100px;
    height: 100px;
    border-radius: 50%;
    object-fit: cover;
}

.avatar-placeholder {
    width: 100px;
    height: 100px;
    border-radius: 50%;
    background-color: var(--background-secondary);
    display: flex;
    align-items: center;
    justify-content: center;
}

.avatar-hint {
    margin-top: 8px;
    font-size: 14px;
    color: var(--font-color-secondary);
}

.form-section {
    margin-bottom: 40px;
}

.input-group {
    margin-bottom: 20px;
}

.label {
    font-size: 16px;
    color: var(--font-color-primary);
    margin-bottom: 8px;
}

.input {
    width: 100%;
    background-color: var(--background-secondary);
    border-radius: 8px;
}

.button-section {
    padding: 0 20px;
}

.save-button {
    width: 100%;
    height: 44px;
    background-color: var(--button-primary-default);
    color: var(--button-primary-text);
    border-radius: 8px;
    font-size: 16px;
}
</style>