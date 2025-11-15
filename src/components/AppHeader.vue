<script setup>
import { computed } from 'vue';

const props = defineProps({
  title: {
    type: String,
    default: 'CultureGoat'
  },
  subtitle: {
    type: String,
    default: null
  },
  roomId: {
    type: String,
    default: null
  }
});
</script>

<template>
  <div class="app-header">
    <h1>{{ title }}</h1>
    <p v-if="subtitle">{{ subtitle }}</p>
    <div v-if="roomId" class="room-badge">Room n°{{ roomId }}</div>
  </div>
</template>
