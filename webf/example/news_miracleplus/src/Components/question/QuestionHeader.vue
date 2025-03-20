<template>
  <div class="question-header">
    <QuestionSection :question="question" @answer="$emit('answer')" @follow="$emit('follow', $event)"
      @invite="$emit('invite')" />
  </div>
</template>

<script>
import QuestionSection from './QuestionSection.vue';

export default {
  name: 'QuestionHeader',
  components: {
    QuestionSection
  },
  props: {
    question: {
      type: Object,
      required: true
    }
  },
  emits: ['answer', 'follow', 'invite']
}
</script>