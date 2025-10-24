<script>
import Home from "./views/home.vue";
import Game from "./views/game.vue";

export default {
  components: {
    Home,
    Game
  }
};
</script>

<template>
  <div id="app">
      <router-view />
  </div>
</template>
