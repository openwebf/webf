<script setup>
// TODO:点击 todos 跳转到 /
</script>
<template>
  <header class="header">
    <h1>todos</h1>
    <input type="text" class="new-todo" autofocus autocomplete="off" placeholder="What needs to be done?" @keyup.enter="
      // @ts-ignore
      $emit('add-todo', $event.target.value);
      console.log(11111111)
    // @ts-ignore
    $event.target.value = '';
    " />
  </header>
</template>