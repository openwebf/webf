<template>
    <div v-if="notes && notesList.length > 0" class="content-block notes-block">
      <div class="block-title">相关问题</div>
      <div class="notes-list">
        <div 
          v-for="note in notesList" 
          :key="note.id"
          class="note-item"
          @click="$emit('note-click', note)"
        >
          <div class="note-content">{{ note.content }}</div>
          <flutter-cupertino-icon type="chevron_right" class="note-arrow" />
        </div>
      </div>
    </div>
  </template>
  
  <script>
  export default {
    name: 'NotesList',
    props: {
      notes: Boolean,
      notesList: {
        type: Array,
        default: () => []
      }
    },
    emits: ['note-click']
  }
  </script>
  
  <style lang="scss" scoped>
  .notes-block {
    margin: 16px 0;

    .block-title {
      font-size: 16px;
      font-weight: 600;
      color: #1C1C1E;
      margin-bottom: 8px;
    }
    .notes-list {
      .note-item {
        display: flex;
        align-items: center;
        padding: 12px 0;
        cursor: pointer;
        
        &:not(:last-child) {
          border-bottom: 1px solid rgba(60, 60, 67, 0.1);
        }
        
        &:active {
          opacity: 0.7;
        }
        
        .note-content {
          flex: 1;
          font-size: 14px;
          line-height: 1.4;
          color: #1C1C1E;
          margin-right: 8px;
        }
        
        .note-arrow {
          color: #8E8E93;
          font-size: 16px;
        }
      }
    }
  }
  </style>