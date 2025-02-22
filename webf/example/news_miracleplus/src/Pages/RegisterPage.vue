<template>
  <div class="register-page">
    <logo-header></logo-header>
    <div class="register-page-content">
      <div class="slogon">
        <div class="slogon-title">奇绩创坛 | 齐思</div>
        <div class="slogon-description">最新最有趣的科技前沿内容</div>
      </div>
      <div class="register-form">
        <flutter-cupertino-input
          class="tel-input"
          placeholder="请输入手机号"
          icon="phone" 
          @input="handlePhoneInput"
        />
        <flutter-cupertino-input
          class="code-input"
          placeholder="请输入验证码"
          icon="shield"
          suffix-text="获取验证码"
          @suffix-click="handleGetVerifyCode"
          @input="handleVerifyCodeInput"
        />
        <flutter-cupertino-input
          class="pwd-input"
          placeholder="请设置密码"
          icon="lock"
          type="password"
          @input="handlePasswordInput"
        />
      <flutter-cupertino-input
        class="confirm-pwd-input"
        placeholder="请确认密码"
        icon="lock"
        type="password"
        @input="handleConfirmPasswordInput"
      />
      <flutter-cupertino-button @press="handleRegister" class="register-button">
        <div>注册</div>
      </flutter-cupertino-button>
      </div>
      <div class="register-footer">
        <div class="register-footer-text">已有账号？</div>
        <a class="register-footer-link" @click="goToLogin">立即登录</a>
      </div>
      <div @click="goToHome">去首页</div>
    </div>
  </div>
</template>
<script>
import LogoHeader from '../Components/LogoHeader.vue';
import { api } from '../api';

export default {
  name: 'RegisterPage',
  data() {
    return {
      phoneNumber: '',
      verifyCode: '',
      setPwd: '',
      confirmedPwd: '',
    }
  },
  components: {
    LogoHeader,
  },
  mounted() {
    console.log('RegisterPage mounted');
  },
  methods: {
    handlePhoneInput(e) {
      console.log('handlePhoneInput', e.detail);
      this.phoneNumber = e.detail;
    },

    handleGetVerifyCode() {
      console.log('啊哟，有人在艾特我哟');
    },
    handleVerifyCodeInput(e) {
      console.log('handleVerifyCodeInput', e);
      this.verifyCode = e.detail;
    },
    handlePasswordInput(e) {
      console.log('handlePasswordInput', e);
      this.setPwd = e.detail;

    },
    handleConfirmPasswordInput(e) {
      this.confirmedPwd = e.detail;
    },
    async handleRegister() {
      console.log('123123');
      console.log('this.phoneNumber', this.phoneNumber);
      const res = await api.auth.register({
        phone: this.phoneNumber,
        password: this.setPwd,
      });
      console.log('res', res);
    },
    goToLogin() {
      window.webf.hybridHistory.pushState({}, '/login');
    },
    goToHome() {
      window.webf.hybridHistory.pushState({}, '/index');
    }
  }
};
</script>
<style scoped>
.register-page {
  height: 100vh;
}
.register-page-content {
  padding: 0 16px;
}
.slogon {
  margin-top: 56px;
  width: 100%;
  display: flex;
  flex-direction: column;
  align-items: left;
}
.slogon-title {
  font-size: 24px;
  font-weight: 600;
  color: var(--font-color);
}
.slogon-description {
  margin-top: 8px;
  font-size: 16px;
  color: var(--secondary-font-color);
}
.register-form {
  margin-top: 32px;
}
.tel-input, .code-input, .pwd-input, .confirm-pwd-input {
  margin-top: 16px;
}
.register-button {
  margin-top: 16px;
  width: 100%;
  font-size: 16px;
  font-weight: 600;
  color: var(--button-primary-text, #fff); 
  display: flex;
  justify-content: center;
  align-items: center;
  text-align: center;
}
.register-footer {
  width: 100%;
  margin-top: 16px;
  display: flex;
  justify-content: center;
  align-items: center;
}
.register-footer-text {
  font-size: 14px;
  color: var(--secondary-font-color);
}
.register-footer-link {
  color: var(--link-color);
}
</style>
