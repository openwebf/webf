<script setup>
import { defineEmits } from 'vue';
const emit = defineEmits(['add-todo']);
const onKeyUp = (event) => {
  if (event.code === 'Enter') {
    emit('add-todo', event.target.value);
    event.target.value = '';
  }
}
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
      @keyup="onKeyUp"  
    />
  </header>
</template>

<style lang="postcss">
.title {
  position: absolute;
	top: -140px;
	width: 100%;
	font-size: 80px;
	font-weight: 200;
	text-align: center;
	color: #b83f45;
	-webkit-text-rendering: optimizeLegibility;
	-moz-text-rendering: optimizeLegibility;
	text-rendering: optimizeLegibility;
}

.new-todo {
    position: relative;
    margin: 0;
    width: 100%;
    font-size: 24px;
    font-family: inherit;
    font-weight: 300;
    line-height: 1.4em;
    color: inherit;

    border: 1px solid #999;
    box-shadow: inset 0 -1px 5px 0 rgba(0, 0, 0, 0.2);
    box-sizing: border-box;
    -webkit-font-smoothing: antialiased;
    -moz-osx-font-smoothing: grayscale;
    padding: 16px 16px 16px 60px;
    height: 65px;
    border: none;
    background: rgba(0, 0, 0, 0.003);
    box-shadow: inset 0 -2px 1px rgba(0,0,0,0.03);

    &::placeholder {
      font-style: italic;
      font-weight: 400;
      color: rgba(0, 0, 0, 0.4);
    }
}
</style>