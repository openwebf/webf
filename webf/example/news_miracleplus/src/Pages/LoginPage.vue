<template>
  <div class="login-page" @onscreen="handleOnScreen" @offscreen="handleOnOffScreen">
    <logo-header></logo-header>
    <div class="login-page-content">
      <div class="slogon">
        <div class="slogon-title">奇绩创坛 | 齐思</div>
        <div class="slogon-description">最新最有趣的科技前沿内容</div>
      </div>
      <flutter-cupertino-segmented-tab class="login-tab">
        <flutter-cupertino-segmented-tab-item title="密码登录">
          <div class="login-form">
            <flutter-cupertino-input class="tel-input" placeholder="请输入手机号" @input="handlePhoneInput">
              <div slotName="prefix" class="country-code" @click="showCountryCodePicker">
                +{{ countryCode }}
              </div>
            </flutter-cupertino-input>
            <flutter-cupertino-input class="pwd-input" placeholder="请输入密码" type="password"
              @input="handlePasswordInput" />
            <flutter-cupertino-button type="primary" @click="handleLoginByPassword" class="login-button">
              登录
            </flutter-cupertino-button>
          </div>
          <div class="login-footer">
            <div class="login-footer-text" @click="goToResetPassword">忘记密码？</div>
            <div class="login-footer-link" @click="goToRegister">立即注册</div>
          </div>
        </flutter-cupertino-segmented-tab-item>
        <flutter-cupertino-segmented-tab-item title="短信登录">
          <div class="login-form">
            <flutter-cupertino-input class="tel-input" placeholder="请输入手机号" @input="handlePhoneInput">
              <div slotName="prefix" class="country-code" @click="showCountryCodePicker">
                +{{ countryCode }}
              </div>
            </flutter-cupertino-input>
            <flutter-cupertino-input 
              class="code-input"
              placeholder="请输入验证码"
              @input="handleVerifyCodeInput"
            >
              <div slotName="suffix" class="verify-code" @click="handleGetVerifyCode">
                <span class="verify-code-text" :class="{ 'disabled': countdown > 0 }">
                  {{ countdown > 0 ? `${countdown}秒后重试` : '获取验证码' }}
                </span>
              </div>
            </flutter-cupertino-input>
            <flutter-cupertino-button type="primary" @click="handleLoginByPhoneCode" class="login-button">
              登录
            </flutter-cupertino-button>
          </div>
        </flutter-cupertino-segmented-tab-item>
      </flutter-cupertino-segmented-tab>
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
import { useUserStore } from '@/stores/userStore';
import { getCountryCodeList } from '@/utils/getCountryCodeList';
import tabBarManager from '@/utils/tabBarManager';
export default {
  name: 'LoginPage',
  data() {
    return {
      phoneNumber: '',
      verifyCode: '',
      pwd: '',
      countryCode: '86',
      isSelectingCountryCode: false,
      countryCodeList: getCountryCodeList(),
      countdown: 0,
      timer: null,
    }
  },
  components: {
    LogoHeader,
    AlertDialog,
  },
  mounted() {
    console.log('LoginPage mounted');
  },
  methods: {
    handlePhoneInput(e) {
      this.phoneNumber = e.detail;
    },

    handleOnScreen(e) {
      console.log('on screen', e);
    },

    handleOnOffScreen(e) {
      console.log('on off screen', e);
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
        await api.auth.sendVerifyCode({
          phone: this.phoneNumber,
          countryCode: this.countryCode,
          useCase: 'login',
        });        
        this.countdown = 60;
        this.startCountdown();
      } catch (error) {
        console.error('发送验证码失败', error);
        this.$refs.alertRef.show({
          message: '发送验证码失败',
        });
      }
    },
    handleVerifyCodeInput(e) {
      this.verifyCode = e.detail;
    },
    handlePasswordInput(e) {
      this.pwd = e.detail;
    },
    async handleLoginByPassword() {
      if (!this.phoneNumber) {
        this.$refs.alertRef.show({
          message: '请输入正确的手机号',
        });
        return;
      }

      try {
        const res = await api.auth.loginByPhonePassword({
          country_code: this.countryCode,
          phone: this.phoneNumber,
          password: this.pwd,
        });
        if (res.success !== false && res.data.token) {
          const userStore = useUserStore();
          userStore.setUserInfo({
            ...res.data.user,
            token: res.data.token,
          });

          const wholeUserInfo = await this.getUserInfo();
          userStore.setUserInfo({
            ...userStore.userInfo,
            ...wholeUserInfo,
          });

          this.$refs.toast.show({
            type: 'success',
            content: '登录成功',
          });
          setTimeout(() => {
            tabBarManager.switchTab('/home');
          }, 2000);
 
        } else {
          this.$refs.alertRef.show({
            message: res.message,
          });
        }
      } catch (error) {
        console.error('登录失败', error);
      }
    },
    async handleLoginByPhoneCode() {
      if (!this.phoneNumber) {
        this.$refs.alertRef.show({
          message: '请输入正确的手机号',
        });
        return;
      }

      try {
        const res = await api.auth.loginByPhoneCode({
          phone: this.phoneNumber,
          country_code: this.countryCode,
          code: this.verifyCode,
        });
        if (res.success !== false && res.data.token) {
          const userStore = useUserStore();
          userStore.setUserInfo({
            ...res.data.user,
            token: res.data.token,
          });

          const wholeUserInfo = await this.getUserInfo();
          userStore.setUserInfo({
            ...res.data.user,
            ...wholeUserInfo,
          });

          this.$refs.toast.show({
            type: 'success',
            content: '登录成功',
          });
          setTimeout(() => {
            tabBarManager.switchTab('/home');
          }, 2000);
        } else {
          this.$refs.alertRef.show({
            message: res.message,
          });
        }
      } catch (error) {
        console.error('登录失败', error);
      }
    },
    async getUserInfo() {
      const userInfoRes = await api.auth.getUserInfo();
      return userInfoRes.data;
    },
    goToRegister() {
      window.webf.hybridHistory.pushState({}, '/register');
    },
    showCountryCodePicker() {
      console.log('showCountryCodePicker');
      this.isSelectingCountryCode = true;
    },
    onCountryCodePickerClose() {
      console.log('onCountryCodePickerClose');
      this.isSelectingCountryCode = false;
    },
    onCountryCodePickerChange(e) {
      console.log('onCountryCodePickerChange', e.detail);
      this.countryCode = e.detail;
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
    switchTab() {
      tabBarManager.switchTab('/home');
    },
    goToResetPassword() {
      window.webf.hybridHistory.pushState({}, '/reset_password');
    },
  },
  beforeUnmount() {
    // 组件销毁前清除定时器
    if (this.timer) {
      clearInterval(this.timer);
    }
  }
};
</script>
<style lang="scss" scoped>
.login-page {

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

  .login-tab {
    margin-top: 32px;
  }

  .login-form {
    padding-top: 12px;

    .tel-input,
    .code-input,
    .pwd-input {
      margin-top: 16px;
    }

    .tel-input {
      width: 100%;

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

      .verify-code {
        color: var(--link-color);
        width: 20%;
        border-radius: 4px;
        padding: 0 8px;
        height: 44px;
      }
    }
  }
    .login-button {
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

    .login-footer {
        margin-top: 16px;
        width: 100%;
        display: flex;
        justify-content: space-between;
        align-items: center;

        &-text {
            font-size: 14px;
            color: var(--secondary-font-color);
        }

        &-link {
            color: var(--link-color);
        }
    }

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
</style>
