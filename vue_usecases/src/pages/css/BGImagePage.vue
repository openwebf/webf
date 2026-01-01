<script setup lang="ts">
const flower = new URL('../../resource/bg_flower.gif', import.meta.url).href;
const webfPng = new URL('../../resource/webf.png', import.meta.url).href;

const containerBase = {
  margin: '5px',
  textAlign: 'center',
  borderColor: 'red',
  borderWidth: '5px',
  padding: '5px',
  borderStyle: 'solid',
  width: '50%',
  height: '100px',
} as const;
</script>

<template>
  <div id="main">
    <webf-list-view class="p-5 m-0 bg-[#f8f9fa]" :style="{ height: '480px', flexDirection: 'column' }">
      <div
        :style="{
          ...containerBase,
          backgroundImage: `url(${flower})`,
          backgroundOrigin: 'content-box',
          backgroundPosition: 'left top',
          backgroundRepeat: 'no-repeat',
        }"
      />

      <div
        :style="{
          ...containerBase,
          backgroundImage: `url(${flower})`,
          backgroundOrigin: 'padding-box',
          backgroundPosition: '50% 50%',
          backgroundRepeat: 'repeat-x',
        }"
      />

      <div
        :style="{
          ...containerBase,
          backgroundImage: `url(${flower})`,
          backgroundOrigin: 'border-box',
          backgroundPosition: '30px 40px',
          backgroundRepeat: 'repeat',
        }"
      />

      <div
        :style="{
          ...containerBase,
          backgroundImage: `url(${flower}), url(${webfPng})`,
          backgroundOrigin: 'content-box, border-box',
          backgroundPosition: '50% 40px, right bottom',
          backgroundRepeat: 'repeat-y, repeat-x',
        }"
      />
    </webf-list-view>
  </div>
</template>
