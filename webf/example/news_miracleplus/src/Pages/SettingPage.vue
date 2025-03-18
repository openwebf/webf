<template>
    <div class="setting-page">
        <div class="setting-header">设置</div>
        
        <!-- Setting items list -->
        <div class="setting-list">
            <!-- <div class="setting-item" @click="handleNotificationSetting">
                <span>通知设置</span>
                <i class="arrow-right"></i>
            </div> -->
            
            <div class="setting-item" @click="handleUserAgreement">
                <span>用户服务协议</span>
                <i class="arrow-right"></i>
            </div>
            
            <div class="setting-item" @click="handlePrivacyPolicy">
                <span>隐私政策</span>
                <i class="arrow-right"></i>
            </div>
            
            <div class="setting-item logout" @click="handleLogout">
                <span>退出登录</span>
                <i class="arrow-right"></i>
            </div>
        </div>
    </div>
</template>

<script>
import { api } from '@/api';
import { useUserStore } from '@/stores/userStore';
import tabBarManager from '@/utils/tabBarManager';
export default {
    name: 'SettingPage',
    components: {},
    methods: {
        handleNotificationSetting() {
            // Handle notification settings navigation
            console.log('Navigate to notification settings')
        },
        handleUserAgreement() {
            // Handle user agreement navigation
            window.webf.hybridHistory.pushState({}, '/user_agreement');
        },
        handlePrivacyPolicy() {
            // Handle privacy policy navigation
            window.webf.hybridHistory.pushState({}, '/privacy_policy');
        },
        async handleLogout() {
            // Handle account logout
            // TODO: 增加一个弹窗
            await api.auth.logout();
            const userStore = useUserStore();
            userStore.clearUserInfo();
            tabBarManager.switchTab('/my');
        }
    }
}
</script>

<style scoped>
.setting-page {
    padding: 16px;
    background-color: var(--background-color);
    min-height: 100vh;
}

.setting-header {
    font-size: 20px;
    font-weight: bold;
    margin-bottom: 20px;
    color: var(--font-color);
}

.setting-list {
    background-color: var(--background-primary);
    border-radius: 8px;
}

.setting-item {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 16px;
    border-bottom: 1px solid #f0f0f0;
    cursor: pointer;
    color: var(--font-color);
}

.setting-item:last-child {
    border-bottom: none;
}

.arrow-right {
    border: solid #999;
    border-width: 0 2px 2px 0;
    display: inline-block;
    padding: 3px;
    transform: rotate(-45deg);
}

.logout span {
    color: #ff4d4f;
}
</style>