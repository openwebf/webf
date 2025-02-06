<template>
  <div class="register-page">
    <logo-header></logo-header>
    <div class="register-page-content">
      <div class="slogon">
        <div class="slogon-title">奇绩创坛 | 齐思</div>
        <div class="slogon-description">最新最有趣的科技前沿内容</div>
      </div>
      <div class="register-form">
        <flutter-cupertino-button>
          <div class="register-form-button">注册</div>
        </flutter-cupertino-button>
      </div>
    </div>
  </div>
</template>
<script>
import LogoHeader from '../Components/LogoHeader.vue';
export default {
  name: 'RegisterPage',
  components: {
    LogoHeader,
  },
  mounted() {
    console.log('RegisterPage mounted');
  },
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
.register-form-button {
  width: 100%;
  font-size: 16px;
  font-weight: 600;
  color: var(--button-primary-text, #fff); 
  display: flex;
  justify-content: center;
  align-items: center;
  text-align: center;
}
</style>
