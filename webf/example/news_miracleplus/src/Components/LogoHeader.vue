<template>
  <div class="header">
    <img class="logo" src="../assets/img/logo.png" alt="logo" />
  </div>
</template>
<script>
export default {
  name: 'LogoHeader',
};
</script>
<style scoped>
.header {
  height: 56px;
  width: 100%;
  padding: 0 16px;
  background-color: var(--background-primary);
  display: flex;
  justify-content: flex-start;
  align-items: center;
}
.logo {
  height: 32px;
  width: 32px;
}
</style>
