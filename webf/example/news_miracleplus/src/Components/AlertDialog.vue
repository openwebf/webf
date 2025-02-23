<template>
    <flutter-cupertino-alert
      ref="alertRef"
      :title="title"
      :message="message"
      :confirm-text="confirmText"
      :cancel-text="cancelText"
      :cancel-destructive="cancelDestructive"
      @confirm="handleConfirm"
      @cancel="handleCancel"
    ></flutter-cupertino-alert>
  </template>
  
  <script>
  export default {
    name: 'AlertDialog',
    props: {
      title: {
        type: String,
        default: ''
      },
      message: {
        type: String,
        default: ''
      },
      confirmText: {
        type: String,
        default: '确定'
      },
      cancelText: {
        type: String,
        default: ''
      },
      cancelDestructive: {
        type: Boolean,
        default: false
      }
    },
    methods: {
      show() {
        this.$refs.alertRef.show();
      },
      hide() {
        this.$refs.alertRef.hide();
      },
      handleConfirm() {
        this.$emit('confirm');
        this.hide();
      },
      handleCancel() {
        this.$emit('cancel');
        this.hide();
      }
    }
  }
  </script>