<script setup lang="ts">
defineProps<{
  name: string;
  id?: string;
}>();
</script>

<template>
  <div :id="id" :slotName="name" class="m-0 p-0">
    <slot />
  </div>
</template>

