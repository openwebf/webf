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
    const id = uuid();
    todos.value.push({
        completed: false,
        title: value,
        id: id,
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
        todo-list 长度是：{{todos.length}}
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
.todoapp {
    background: #fff;
	margin: 130px 0 40px 0;
	position: relative;
	box-shadow: 0 2px 4px 0 rgba(0, 0, 0, 0.2),0 25px 50px 0 rgba(0, 0, 0, 0.1);

    .main {
        position: relative;
        z-index: 2;
        border-top: 1px solid #e6e6e6;

        .toggle-all {
            width: 40px;
            height: 60px;
            border: none; 
            opacity: 0;
            position: absolute;
            right: auto;
            bottom: 100%;

            &:focus + label {
                outline: none;
                box-shadow: 0 0 2px 2px #CF7D7D;
            }
        
            & + label {
                display: flex;
                align-items: center;
                justify-content: center;
                width: 45px;
                height: 65px;
                font-size: 0;
                position: absolute;
                top: -65px;
                left: -0;
            }
            & + label:before {
                content: '❯';
                display: inline-block;
                font-size: 22px;
                color: #949494;
                padding: 10px 27px 10px 27px;
                -webkit-transform: rotate(90deg);
                transform: rotate(90deg);
            }
            &:checked + label {
                color: #484848;
            }
        }

        .todo-list {
            margin: 0;
            padding: 0;
            list-style: none;

            li {
                position: relative;
                font-size: 24px;
                border-bottom: 1px solid #ededed;

                &:last-child {
                    border-bottom: none;
                }
                
                &.editing {
                    border-bottom: none;
                    padding: 0;

                    .edit {
                        display: block;
                        width: calc(100% - 43px);
                        padding: 12px 16px;
                        margin: 0 0 0 43px;
                    }
                    .view {
                        display: none;
                    }

                    &:last-child {
                        margin-bottom: -1px;
                    }
                }

                .toggle {
                    text-align: center;
                    width: 40px;
                    height: auto;
                    position: absolute;
                    top: 0;
                    bottom: 0;
                    margin: auto 0;
                    border: none;
                    appearance: none;
                    opacity: 0;

                    &:focus + label {
                        outline: none;
                        box-shadow: 0 0 2px 2px #CF7D7D;
                    }

                    & + label {
                        background-image: url('data:image/svg+xml;utf8,%3Csvg%20xmlns%3D%22http%3A//www.w3.org/2000/svg%22%20width%3D%2240%22%20height%3D%2240%22%20viewBox%3D%22-10%20-18%20100%20135%22%3E%3Ccircle%20cx%3D%2250%22%20cy%3D%2250%22%20r%3D%2250%22%20fill%3D%22none%22%20stroke%3D%22%23949494%22%20stroke-width%3D%223%22/%3E%3C/svg%3E');
                        background-repeat: no-repeat;
                        background-position: center left;
                    }

                    &:checked + label {
                        background-image: url('data:image/svg+xml;utf8,%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20width%3D%2240%22%20height%3D%2240%22%20viewBox%3D%22-10%20-18%20100%20135%22%3E%3Ccircle%20cx%3D%2250%22%20cy%3D%2250%22%20r%3D%2250%22%20fill%3D%22none%22%20stroke%3D%22%2359A193%22%20stroke-width%3D%223%22%2F%3E%3Cpath%20fill%3D%22%233EA390%22%20d%3D%22M72%2025L42%2071%2027%2056l-4%204%2020%2020%2034-52z%22%2F%3E%3C%2Fsvg%3E');
                    }
                }

                label {
                    overflow-wrap: break-word;
                    padding: 15px 15px 15px 60px;
                    display: block;
                    line-height: 1.2;
                    transition: color 0.4s;
                    font-weight: 400;
                    color: #484848;
                }

                &.completed label {
                    color: #949494;
                    text-decoration: line-through;
                }

                .destroy {
                    padding: 0;
                    border: 0;
                    background-color: transparent;
                    vertical-align: baseline;
                    appearance: none;
                    font-family: inherit;
                    font-weight: inherit;
                    display: none;
                    position: absolute;
                    top: 0;
                    right: 10px;
                    bottom: 0;
                    width: 40px;
                    height: 40px;
                    margin: auto 0;
                    font-size: 30px;
                    color: #949494;
                    transition: color 0.2s ease-out;


                    &:hover {
                        color: #C18585;
                    }

                    &:focus {
                        color: #C18585;
                    }

                    &:after {
                        content: '×';
                        display: block;
                        height: 100%;
                        line-height: 1.1;
                    }
                }

                &:hover .destroy {
                    display: block;
                }

                .edit {
                    display: none;
                }
            }
        }
    }

    *:focus {
        outline: none;
        box-shadow: 0 0 2px 2px #CF7D7D;
    }
}




</style>