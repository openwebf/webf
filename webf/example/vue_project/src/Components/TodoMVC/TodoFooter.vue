<script setup>
import { computed, defineProps, defineEmits } from 'vue';

const props = defineProps(['todos', 'currentView']);
const remaining = computed(() => props.todos.filter(todo => !todo.completed).length);
const emit = defineEmits(['deleteCompleted', 'changeView']);
</script>

<template>
    <footer class="footer" v-show="props.todos.length > 0">
        <span class="todo-count">
            <strong>{{ remaining }}</strong> {{ remaining === 1 ? "item" : "items" }} left
        </span>
        <ul class="filters">
            <li><a href="#" @click.prevent="emit('changeView', 'all')" :class="{ selected: currentView === 'all' }">All</a></li>
            <li><a href="#" @click.prevent="emit('changeView', 'active')" :class="{ selected: currentView === 'active' }">Active</a></li>
            <li><a href="#" @click.prevent="emit('changeView', 'completed')" :class="{ selected: currentView === 'completed' }">Completed</a></li>
        </ul>
        <button class="clear-completed" v-show="todos.some(todo => todo.completed)" @click="$emit('delete-completed')">Clear Completed</button>
    </footer>
</template>