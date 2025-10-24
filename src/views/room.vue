<script setup>
import { ref } from "vue";
import { useRoute, useRouter } from "vue-router";
import socket from "@/socket";
import GameRulesParam from "@/components/GameRulesParam.vue";

const route = useRoute();
const router = useRouter();
const roomId = route.params.roomId;
const pseudo = sessionStorage.getItem("pseudo");
const isHost = sessionStorage.getItem("isHost");
const players = ref({});
const rules = ref({});
const showRulesParam = ref(false);

socket.emit("joinRoom", { roomId, playerName: pseudo });

socket.on("updatePlayers", (room) => {
  players.value = room.players;
});

function startGame() {
    if (!rules.value || Object.keys(rules.value).length === 0) {
    rules.value = {
      rules: "FixedQuestions",
      scoreMax: 5,
      questionMax: 5,
      qcmTimeLimit: 8,
      openTimeLimit: 12,
    };
  }
    console.log("Règles de la partie : ", rules.value);
    socket.emit("prepareGame", { roomId });
}

socket.on("gameStarting", () => {
  router.push(`/game/${roomId}`);
});

function updateRules(newRules) {
  showRulesParam.value = false;
  rules.value = newRules;   
}

</script>

<template>
  <div>
    <h1>Room {{ roomId }}</h1>
    <ul>
      <li v-for="(p, id) in players" :key="id">{{ p.name }}</li>
    </ul>

    <button @click="showRulesParam = true" v-if="isHost">Configurer les règles</button>

    <button v-if="isHost" @click="startGame">Démarrer la partie</button>
    <p v-else>En attente de l'host...</p>

    <GameRulesParam
      v-if="showRulesParam"
      @submit="updateRules"
    />
  </div>
</template>
