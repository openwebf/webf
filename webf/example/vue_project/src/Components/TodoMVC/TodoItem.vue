<script setup>
import { ref, nextTick, computed, defineProps, defineEmits } from 'vue'

const props = defineProps(['todo', 'index']);
const emit = defineEmits(['delete-todo', 'edit-todo']);

const editing = ref(false);
const editInput = ref(null);
const editText = ref("");

const editModel = computed({
    get() {
        return props.todo.title;
    },
    set(value) {
        editText.value = value;
    },
});

const toggleModel = computed({
    get() {
        return props.todo.completed;
    },
    set(value) {
        emit("toggle-todo", props.todo, value);
    },
});

function startEdit() {
    editing.value = true;
    nextTick(() => {
        editInput.value.focus();
    });
}

function finishEdit() {
    editing.value = false;
     if (editText.value.trim().length === 0)
        deleteTodo();
    else
        updateTodo();
}

function cancelEdit() {
    editing.value = false;
}

function deleteTodo() {
    emit("delete-todo", props.todo);
}

function updateTodo() {
    emit("edit-todo", props.todo, editText.value);
    editText.value = "";
}
</script>

<template>
    <li
        :class="{
            completed: todo.completed,
            editing: editing,
        }"
    >
        <div class="view">
            <input type="checkbox" class="toggle" v-model="toggleModel" />
            <label @dblclick="startEdit">{{ todo.title }}</label>
            <button class="destroy" @click.prevent="deleteTodo"></button>
        </div>
        <div class="input-container">
            <input id="edit-todo-input" ref="editInput" type="text" class="edit placeholder:italic placeholder:text-gray-400 placeholder:font-normal placeholder:font-weight-400" v-model="editModel" @keyup.enter="finishEdit" @blur="cancelEdit"/>
            <label class="visually-hidden" for="edit-todo-input">Edit Todo Input</label>
        </div>
    </li>
</template>

<style lang="postcss">
@import "tailwindcss";

.visually-hidden {
    @apply border-0 h-[1px] w-[1px] m-[-1px] p-0 overflow-hidden absolute whitespace-nowrap;
    clip: rect(0 0 0 0);
    clip-path: inset(50%);
}

.edit {
    @apply relative m-0 w-full text-2xl leading-[1.4em] p-1.5 border border-[#999] shadow-[inset_0_-1px_5px_0_rgba(0,0,0,0.2)] box-border;
	font-family: inherit;
	font-weight: inherit;
	color: inherit;
}
</style>