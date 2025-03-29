<template>
  <div class="reset-password-page">
    <logo-header></logo-header>
    <div class="reset-password-page-content">
      <div class="slogon">
        <div class="slogon-title">奇绩创坛 | 齐思</div>
        <div class="slogon-description">最新最有趣的科技前沿内容</div>
      </div>
      <div class="reset-password-form">
        <flutter-cupertino-input class="tel-input" placeholder="请输入手机号" @input="handlePhoneInput">
          <div slotName="prefix" class="country-code" @click="showCountryCodePicker">
            +{{ countryCode }}
          </div>
        </flutter-cupertino-input>
        <flutter-cupertino-input class="code-input" placeholder="请输入验证码" @input="handleVerifyCodeInput">
          <div slotName="suffix" class="verify-code" @click="handleGetVerifyCode">
            <span class="verify-code-text" :class="{ 'disabled': countdown > 0 }">
              {{ countdown > 0 ? `${countdown}秒后重试` : '获取验证码' }}
            </span>
          </div>
        </flutter-cupertino-input>
        <flutter-cupertino-input class="pwd-input" placeholder="输入新密码" icon="lock" type="password"
          @input="handlePasswordInput" />
        <flutter-cupertino-button type="primary" @click="handleResetPassword" class="reset-password-button">
          重置密码
        </flutter-cupertino-button>
      </div>
    </div>
    <flutter-cupertino-modal-popup :show="isSelectingCountryCode" height="400" @close="onCountryCodePickerClose">
      <flutter-cupertino-picker height="200" item-height="32" @change="onCountryCodePickerChange">
        <flutter-cupertino-picker-item v-for="item in countryCodeList" :key="item.code"
          :label="`+${item.code} (${item.name})`" :val="item.code"></flutter-cupertino-picker-item>
      </flutter-cupertino-picker>
    </flutter-cupertino-modal-popup>
    <alert-dialog
      ref="alertRef"
      title="提示"
      confirm-text="确定"
    />
    <flutter-cupertino-toast ref="toast" />
  </div>
</template>
<script>
import LogoHeader from '@/Components/LogoHeader.vue';
import AlertDialog from '@/Components/AlertDialog.vue';
import { api } from '@/api';
import { getCountryCodeList } from '@/utils/getCountryCodeList';
import { useUserStore } from '@/stores/userStore';

export default {
  name: 'RegisterPage',
  data() {
    return {
      phoneNumber: '',
      countryCode: '86',
      isSelectingCountryCode: false,
      countryCodeList: getCountryCodeList(),
      countdown: 0,
      timer: null,
      verifyCode: '',
      setPwd: '',
    }
  },
  components: {
    LogoHeader,
    AlertDialog,
  },
  methods: {
    handlePhoneInput(e) {
      this.phoneNumber = e.detail;
    },

    async handleGetVerifyCode() {
      if (this.countdown > 0) return;
      
      if (!this.phoneNumber) {
        this.$refs.alertRef.show({
          message: '请输入正确的手机号',
        });
        return;
      }
      
      try {
        console.log(this.phoneNumber, this.countryCode);
        await api.auth.sendVerifyCode({
          phone: this.phoneNumber,
          countryCode: this.countryCode,
          useCase: 'resetPassword'
        });
        
        this.countdown = 60;
        this.startCountdown();
      } catch (error) {
        this.$refs.alertRef.show({
          message: '发送验证码失败',
        });
      }
    },

    startCountdown() {
      if (this.timer) {
        clearInterval(this.timer);
      }
      
      this.timer = setInterval(() => {
        if (this.countdown > 0) {
          this.countdown--;
        } else {
          clearInterval(this.timer);
        }
      }, 1000);
    },

    handleVerifyCodeInput(e) {
      this.verifyCode = e.detail;
    },
    handlePasswordInput(e) {
      this.setPwd = e.detail;

    },
    async handleResetPassword() {
      if (!this.phoneNumber) {
        this.$refs.alertRef.show({
          message: '请输入正确的手机号',
        });
        return;
      }
      if (!this.verifyCode) {
        this.$refs.alertRef.show({
          message: '请输入验证码',
        });
        return;
      }
      if (!this.setPwd) {
        this.$refs.alertRef.show({
          message: '请输入新密码',
        });
        return;
      }
      
      const res = await api.auth.resetPassword({
        code: this.verifyCode,
        countryCode: this.countryCode,
        phone: this.phoneNumber,
        newPassword: this.setPwd,
      });
      if (res.code === 200) {
        this.$refs.toast.show({
          type: 'success',
          content: '重置密码成功',
        });
        const userStore = useUserStore();
        userStore.clearUserInfo();
        setTimeout(() => {
          window.webf.hybridHistory.pushState({}, '/login');
        }, 2000);
      } else {
        this.$refs.alertRef.show({
          message: res.message,
        });
      }
        
    },
    onCountryCodePickerClose() {
      this.isSelectingCountryCode = false;
    },
    onCountryCodePickerChange(e) {
      this.countryCode = e.detail;
    },
    goToLogin() {
      window.webf.hybridHistory.pushState({}, '/login');
    },
    goToHome() {
      window.webf.hybridHistory.pushState({}, '/index');
    }
  },
  beforeUnmount() {
    if (this.timer) {
      clearInterval(this.timer);
    }
  }
};
</script>
<style lang="scss" scoped>
.reset-password-page {
  height: 100vh;

  &-content {
    padding: 0 16px;
  }

  .slogon {
    margin-top: 56px;
    width: 100%;
    display: flex;
    flex-direction: column;
    align-items: left;

    &-title {
      font-size: 24px;
      font-weight: 600;
      color: var(--font-color-primary);
    }

    &-description {
      margin-top: 8px;
      font-size: 16px;
      color: var(--secondary-font-color);
    }
  }

  .reset-password-form {
    margin-top: 32px;

    .tel-input,
    .code-input,
    .pwd-input,
    .confirm-pwd-input {
      margin-top: 16px;
    }

    .tel-input {
      .country-code {
        width: 20%;
        background-color: var(--background-primary);
        border-radius: 4px;
        padding: 0 8px;
        height: 44px;

        display: flex;
        align-items: center;
        justify-content: center;
      }
    }

    .code-input {
      .verify-code {
        height: 44px;
        display: flex;
        align-items: center;
        justify-content: center;
        
        &-text {
          color: var(--link-color);
          font-size: 14px;
          
          &.disabled {
            color: var(--secondary-font-color);
            opacity: 0.5;
          }
        }
      }
    }
    
    
  }

  .reset-password-button {
    margin-top: 16px;
    width: 100%;
    font-size: 16px;
    font-weight: 600;
    color: var(--button-primary-text);
    display: flex;
    justify-content: center;
    align-items: center;
    text-align: center;
  }
}
</style>
