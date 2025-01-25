<script setup>
import { ref, computed } from 'vue';

import TodoFooter from './TodoFooter.vue';
import TodoHeader from './TodoHeader.vue';
import TodoItem from './TodoItem.vue';

const todos = ref([]);
console.log(todos.value);
const currentView = ref('all');

const filters = {
    all: (todos) => todos,
    active: (todos) => todos.value.filter((todo) => !todo.completed),
    completed: (todos) => todos.value.filter((todo) => todo.completed),
};

const activeTodos = computed(() => filters.active(todos));
const completedTodos = computed(() => filters.completed(todos));
const filteredTodos = computed(() => {
    switch(currentView.value) {
        case "active":
            return activeTodos;
        case "completed":
            return completedTodos;
        default:
            return todos;
    }
});

const toggleAllModel = computed({
    get() {
        return activeTodos.value.length === 0;
    },
    set(value) {
        todos.value.forEach((todo) => {
            todo.completed = value;
        });
    },
});

function uuid() {
    let uuid = "";
    for (let i = 0; i < 32; i++) {
        let random = (Math.random() * 16) | 0;
        if (i === 8 || i === 12 || i === 16 || i === 20)
            uuid += "-";
        uuid += (i === 12 ? 4 : i === 16 ? (random & 3) | 8 : random).toString(16);
    }
    return uuid;
}

function addTodo(value) {
    todos.value.push({
        completed: false,
        title: value,
        id: uuid(),
    })
}

function deleteTodo(todo) {
    todos.value = todos.value.filter((t) => t !== todo);
}

function toggleTodo(todo, value) {
    todo.completed = value;
}

function editTodo(todo, value) {
    todo.title = value;
}

function deleteCompleted() {
    todos.value = todos.value.filter(todo => !todo.completed);
}
</script>

<template>
    <div class="todoapp">
        <TodoHeader @add-todo="addTodo" />
        <main class="main" v-show="todos.length > 0">
            <div class="toggle-all-container">
                <input type="checkbox" id="toggle-all-input" class="toggle-all" v-model="toggleAllModel" :disabled="filteredTodos.value.length === 0"/>
                <label class="placeholder:italic pointer-events-none" htmlFor="toggle-all-input"> Toggle All Input </label>
            </div>
            <ul class="todo-list">
                <TodoItem v-for="(todo, index) in filteredTodos.value" :key="todo.id" :todo="todo" :index="index"
                    @delete-todo="deleteTodo" @edit-todo="editTodo" @toggle-todo="toggleTodo" />
            </ul>
        </main>
        <TodoFooter :todos="todos" :current-view="currentView" @delete-completed="deleteCompleted" @change-view="currentView = $event" />
    </div>
</template>
<style lang="postcss">
@import "tailwindcss";

.todoapp {
    @apply bg-white mx-4 mt-[130px] mb-10 relative shadow-[0_2px_4px_0_rgba(0,0,0,0.2),0_25px_50px_0_rgba(0,0,0,0.1)];

    .main {
        @apply relative z-2 border-t border-gray-300;

        .toggle-all {
            @apply w-[40px] h-[60px] border-none opacity-0 absolute right-auto bottom-full;

            &:focus + label {
                @apply outline-none shadow-[0_0_2px_2px_#CF7D7D];
            }
        
            & + label {
                @apply flex items-center justify-center w-[45px] h-[65px] text-[0px] absolute -top-[65px] left-0;
                @apply before:inline-block before:text-[22px] before:text-[#949494] before:py-[10px] before:px-[27px] before:rotate-90 before:content-['❯'];   
            }
            &:checked + label {
                @apply before:text-[#484848];
            }
        }

        .todo-list {
            @apply m-0 p-0 list-none;

            li {
                @apply relative text-[24px] border-b border-[#ededed];
                @apply last:border-b-0;
                
                &.editing {
                    @apply border-b-0 p-0;
                    @apply last:mb-[-1px];

                    .edit {
                        @apply block w-[calc(100%-43px)] py-3 px-4 ml-[43px];
                    }
                    .view {
                        @apply hidden;
                    }
                }

                .toggle {
                    @apply text-center w-[40px] h-[40px] h-auto absolute top-0 bottom-0 my-auto mx-0 border-none appearance-none opacity-0;

                    &:focus + label {
                        @apply outline-none shadow-[0_0_2px_2px_#CF7D7D];
                    }

                    & + label {
                        @apply bg-[url('data:image/svg+xml;utf8,%3Csvg%20xmlns%3D%22http%3A//www.w3.org/2000/svg%22%20width%3D%2240%22%20height%3D%2240%22%20viewBox%3D%22-10%20-18%20100%20135%22%3E%3Ccircle%20cx%3D%2250%22%20cy%3D%2250%22%20r%3D%2250%22%20fill%3D%22none%22%20stroke%3D%22%23949494%22%20stroke-width%3D%223%22/%3E%3C/svg%3E')] bg-no-repeat bg-[center_left];
                    }

                    &:checked + label {
                        @apply bg-[url('data:image/svg+xml;utf8,%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20width%3D%2240%22%20height%3D%2240%22%20viewBox%3D%22-10%20-18%20100%20135%22%3E%3Ccircle%20cx%3D%2250%22%20cy%3D%2250%22%20r%3D%2250%22%20fill%3D%22none%22%20stroke%3D%22%2359A193%22%20stroke-width%3D%223%22%2F%3E%3Cpath%20fill%3D%22%233EA390%22%20d%3D%22M72%2025L42%2071%2027%2056l-4%204%2020%2020%2034-52z%22%2F%3E%3C%2Fsvg%3E')];
                    }
                }

                label {
                    @apply break-words py-[15px] pr-[15px] pl-[60px] block leading-[1.2] transition duration-400 font-normal text-[#484848];
                }

                &.completed label {
                    @apply text-[#949494] line-through;
                }

                .destroy {
                    @apply hidden absolute top-0 right-[10px] bottom-0 my-auto mx-0 w-[40px] h-[40px] text-[30px] text-[#949494] transition duration-200 ease-out;
                    @apply hover:text-[#C18585] focus:text-[#C18585];
                    @apply after:content-['×'] after:block after:h-[100%] after:leading-[1.1];
                }

                &:hover .destroy {
                    @apply block;
                }

                .edit {
                    @apply hidden;
                }
            }
        }
    }

    *:focus {
        @apply outline-none shadow-[0_0_2px_2px_#CF7D7D];
    }
}




</style>