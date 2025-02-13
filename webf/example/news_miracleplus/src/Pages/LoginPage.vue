<template>
  <div class="login-page">
    <logo-header></logo-header>
    <div class="login-page-content">
      <div class="slogon">
        <div class="slogon-title">奇绩创坛 | 齐思</div>
        <div class="slogon-description">最新最有趣的科技前沿内容</div>
      </div>
    <flutter-cupertino-segmented-tab class="login-tab">
      <flutter-cupertino-segmented-tab-item title="密码登录">
        <div class="login-form">
          <flutter-cupertino-input
            class="tel-input"
            placeholder="请输入手机号"
            icon="phone" 
            @input="handlePhoneInput"
          />
          <flutter-cupertino-input
            class="pwd-input"
            placeholder="请设置密码"
            icon="lock"
            type="password"
            @input="handlePasswordInput"
          />
          <flutter-cupertino-button @press="handleLogin" class="login-button">
            <div>登录</div>
          </flutter-cupertino-button>
        </div>
        <div class="login-footer">
          <div class="login-footer-text">忘记密码？</div>
          <a class="login-footer-link" @click="goToRegister">立即注册</a>
        </div>
        </flutter-cupertino-segmented-tab-item>
        <flutter-cupertino-segmented-tab-item title="短信登录">
          <div class="login-form">
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
            <flutter-cupertino-button @press="handleLogin" class="login-button">
              <div>登录</div>
            </flutter-cupertino-button>
          </div>
        </flutter-cupertino-segmented-tab-item>
      </flutter-cupertino-segmented-tab>

    </div>
  </div>
</template>
<script>
import LogoHeader from '../Components/LogoHeader.vue';
import { api } from '../api';

export default {
  name: 'LoginPage',
  data() {
    return {
      phoneNumber: '',
      verifyCode: '',
      pwd: '',
      countryCode: '86',
    }
  },
  components: {
    LogoHeader,
  },
  mounted() {
    console.log('LoginPage mounted');
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
      this.pwd = e.detail;

    },
    async handleLogin() {
      try {
        console.log('this.phoneNumber', this.phoneNumber);
        console.log('this.countryCode', this.countryCode);
        console.log('this.pwd', this.pwd);
        const res = await api.auth.loginByPhonePassword({
          // TODO: 用户选择 countryCode
          country_code: this.countryCode,
          phone: this.phoneNumber,
          password: this.pwd,
        });
        console.log('res', res);
        await this.$store.dispatch('user/login', {
          token: res.data.token,
          user: res.data.user,
        });
        window.webf.hybridHistory.pushState({}, '/home');
      } catch (error) {
        console.error('登录失败', error);
        this.$store.dispatch('setError', '登录失败，请检查账号密码');
      }
    },
    goToRegister() {
      window.webf.hybridHistory.pushState({}, '/register');
    }
  }
};
</script>
<style scoped>
.login-page {
  height: 100vh;
}
.login-page-content {
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
.login-tab {
  margin-top: 32px;
}
.login-form {
  margin-top: 32px;
}
.tel-input, .code-input, .pwd-input, .confirm-pwd-input {
  margin-top: 16px;
}
.login-button {
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
.login-footer {
  margin-top: 16px;
  width: 100%;
  display: flex;
  justify-content: center;
  align-items: center;
}
.login-footer-text {
  font-size: 14px;
  color: var(--secondary-font-color);
}
.login-footer-link {
  color: var(--link-color);
}
</style>
