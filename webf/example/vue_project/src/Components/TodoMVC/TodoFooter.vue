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
@import "tailwindcss";

.footer {
	@apply h-[50px] bottom-[10px] px-4 py-2.5 text-center text-sm border-t border-gray-200;
	@apply before:content-[''] before:absolute before:right-0 before:bottom-0 before:left-0 before:h-[50px] before:overflow-hidden before:shadow-[0_1px_1px_rgba(0,0,0,0.2),0_8px_0_-3px_#f6f6f6,0_9px_1px_-3px_rgba(0,0,0,0.2),0_16px_0_-6px_#f6f6f6];

    .todo-count {
        @apply flex justify-between;

        strong {
            @apply font-light;
        }

        .clear-completed {
            @apply leading-[19px] no-underline cursor-pointer;
            @apply hover:underline;
        }
    }

    .filters {
        @apply absolute right-0 left-0 m-0 p-0 list-none;

        li {
            @apply inline;

            a {
                @apply m-[3px] py-[3px] px-[7px] no-underline border border-transparent rounded-[3px];
                @apply hover:border-[#DB7676];

                &.selected {
                    @apply border-[#CE4646];
                }
            }
        }
    }
}
</style>