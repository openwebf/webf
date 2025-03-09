<template>
    <flutter-cupertino-alert ref="alert" :title="title" :message="message" :confirm-text="confirmText"
        :cancel-text="cancelText" :cancel-destructive="cancelDestructive" @confirm="handleConfirm"
        @cancel="handleCancel" />
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
        show(options = {}) {
            this.$refs.alert.show(options);
        },
        hide() {
            this.$refs.alert.hide();
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