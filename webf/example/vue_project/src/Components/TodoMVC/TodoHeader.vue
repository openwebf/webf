<script setup>
// TODO:点击 todos 跳转到 /
</script>
<template>
  <header>
    <h1 class="title">todos</h1>
    <input 
      type="text" 
      class="new-todo" 
      autofocus 
      autocomplete="off" 
      placeholder="What needs to be done?" 
      @keyup.enter="
        // @ts-ignore
        $emit('add-todo', $event.target.value);
        // @ts-ignore
        $event.target.value = '';
      "
    />
  </header>
</template>

<style lang="postcss">
@import "tailwindcss";

.title {
  @apply absolute -top-140 w-full text-7xl font-extralight text-center text-red-400;
}

.new-todo {
    @apply relative box-border m-0 w-full h-65 pt-16 pr-16 pb-16 pl-60 text-2xl font-light border-none bg-gray-50 inset-shadow-xs placeholder:italic placeholder:text-gray-400 placeholder:font-normal placeholder:text-black/40;
}
</style>