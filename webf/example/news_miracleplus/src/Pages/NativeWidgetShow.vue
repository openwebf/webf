<template>
    <div id="main">
        <div>Cupertino 组件展示</div>
        <div>Cupertino Picker</div>
        <flutter-cupertino-picker height="200" item-height="32" @change="onPickerChange">
            <flutter-cupertino-picker-item label="选项1"></flutter-cupertino-picker-item>
            <flutter-cupertino-picker-item label="选项2"></flutter-cupertino-picker-item>
            <flutter-cupertino-picker-item label="选项3"></flutter-cupertino-picker-item>
        </flutter-cupertino-picker>
        <div>Cupertino Date Picker</div>
        <flutter-cupertino-date-picker mode="date" height="200" minimum-date="2024-01-01" maximum-date="2025-12-31"
            value="2024-03-14" use-24h="true" @change="onDateChange" />
        <div>Cupertino Switch</div>
        <flutter-cupertino-switch :selected="switchValue" @change="onSwitchChange" active-color="#FF0000"
            inactive-color="#CCCCCC" />
        <div @click="showModalPopup">点我展示 modal</div>
            <flutter-cupertino-modal-popup 
            :show="showModal" 
            height="400"
            @close="onModalClose"
            >
            <div class="modal-content">
                <h1>这是一个底部弹出框</h1>
                <p>这里是内容区域</p>
            </div>
        </flutter-cupertino-modal-popup>
        <div>Cupertino Segmented Tabs</div>
        <flutter-cupertino-segmented-tab>
            <flutter-cupertino-segmented-tab-item title="标签1">
                <div>内容1</div>
            </flutter-cupertino-segmented-tab-item>
            <flutter-cupertino-segmented-tab-item title="标签2">
                <div>内容2</div>
            </flutter-cupertino-segmented-tab-item>
        </flutter-cupertino-segmented-tab>
    </div>

</template>

<script>
import { api } from '@/api';

export default {
    components: {},
    computed: {},
    async mounted() {
    },
    updated() {
    },
    data: () => {
        return {
            switchValue: false,
            showModal: false,
        }
    },
    methods: {
        onSwitchChange(e) {
            console.log('onSwitchChange', e.detail);
            this.switchValue = e.detail;
        },
        showModalPopup() {
            this.showModal = true;
            console.log('showModalPopup', this.showModal);
        },
        onModalClose() {
            console.log('onModalClose');
            this.showModal = false;
        },
    }
}
</script>


<style scoped>
</style>