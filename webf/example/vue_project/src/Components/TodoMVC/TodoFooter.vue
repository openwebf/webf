<script setup>
import { computed, defineProps, defineEmits } from 'vue';

const props = defineProps(['todos', 'currentView']);
const remaining = computed(() => props.todos.filter(todo => !todo.completed).length);
const emit = defineEmits(['deleteCompleted', 'changeView']);
</script>

<template>
    <footer class="footer" v-show="props.todos.length > 0">
        <div class="todo-count">
            <span><strong>{{ remaining }}</strong> {{ remaining === 1 ? "item" : "items" }} left</span>
            <button class="clear-completed" v-show="todos.some(todo => todo.completed)" @click="$emit('delete-completed')">Clear Completed</button>
        </div>

        <ul class="filters">
            <li><a href="#" @click.prevent="emit('changeView', 'all')" :class="{ selected: currentView === 'all' }">All</a></li>
            <li><a href="#" @click.prevent="emit('changeView', 'active')" :class="{ selected: currentView === 'active' }">Active</a></li>
            <li><a href="#" @click.prevent="emit('changeView', 'completed')" :class="{ selected: currentView === 'completed' }">Completed</a></li>
        </ul>
    </footer>
</template>

<style lang="postcss">
.footer {
    position: relative;
    padding: 10px 15px;
	height: 50px;
	text-align: center;
	font-size: 15px;
	border-top: 1px solid #e6e6e6;

    &:before {
        content: '';
        position: absolute;
        right: 0;
        bottom: 0;
        left: 0;
        height: 50px;
        overflow: hidden;
        box-shadow: 0 1px 1px rgba(0, 0, 0, 0.2),
                    0 8px 0 -3px #f6f6f6,
                    0 9px 1px -3px rgba(0, 0, 0, 0.2),
                    0 16px 0 -6px #f6f6f6,
                    0 17px 2px -6px rgba(0, 0, 0, 0.2);
    }

    .todo-count {
        display: flex;
        justify-content: space-between;

        strong {
            font-weight: 300;
        }

        .clear-completed {
            line-height: 19px;
            text-decoration: none;
            cursor: pointer;

            margin: 0;
            padding: 0;
            border: 0;
            background-color: transparent;
            font-size: 100%;
            vertical-align: baseline;
            appearance: none;
            font-family: inherit;
            font-weight: inherit;
            color: inherit;

            &:hover {
                text-decoration: underline;
            }
        }
    }

    .filters {
        position: absolute;
        right: 0;
        left: 0;
        margin: 0;
        padding: 0;
        list-style: none;

        li {
            display: inline;

            a {
                color: inherit;
                margin: 3px;
                padding: 3px 7px;
                text-decoration: none;
                border: 1px solid transparent;
                border-radius: 3px;

                &:hover {
                    border-color: #DB7676;
                }

                &.selected {
                    border-color: #CE4646;
                }
            }
        }
    }
}
</style>