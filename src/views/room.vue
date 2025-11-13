<script setup>
import { ref, onMounted } from "vue";
import { useRoute, useRouter } from "vue-router";
import socket from "@/socket";
import GameRulesParam from "@/components/GameRulesParam.vue";

const route = useRoute();
const router = useRouter();
const roomId = route.params.roomId;
const pseudo = sessionStorage.getItem("pseudo");
let isHost = ref(sessionStorage.getItem("isHost") === "true");

const players = ref({});
const rules = ref({});
const showRulesParam = ref(false);

socket.emit("joinRoom", { roomId, playerName: pseudo });

socket.on("updatePlayers", (data, newHostId) => {
  players.value = data.players;
  
  if (newHostId && socket.id === newHostId) {
    sessionStorage.setItem("isHost", "true");
    isHost.value = true;
  }
});

// Gérer le cas où la partie a déjà commencé
socket.on("gameAlreadyStarted", () => {
  console.log("La partie a déjà commencé, redirection vers le jeu...");
  router.push(`/game/${roomId}`);
});

function startGame() {
  console.log(rules.value);
  
  if (!rules.value || Object.keys(rules.value).length === 0) {
    rules.value = {
      rulesOption: "FixedQuestions",
      scoreMax: 0,
      questionMax: 5,
      qcmTimeLimit: 8,
      openTimeLimit: 12,
    };
  }
  
  try {
    socket.emit("prepareGame", { roomId, rules: rules.value });
  } catch (error) {
    console.error("Erreur lors de la préparation de la partie :", error);
    alert("Une erreur est survenue lors de la préparation de la partie. Veuillez réessayer.");
  }
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
      <li v-for="(p, id) in players" :key="id">
        {{ p.name }}
        <span v-if="p.disconnected" style="color: orange;"> (déconnecté)</span>
      </li>
    </ul>
    <button @click="showRulesParam = true" v-if="isHost">Configurer les règles</button>
    <button v-if="isHost" @click="startGame">Démarrer la partie</button>
    <p v-else>En attente de l'host...</p>
    <GameRulesParam v-if="showRulesParam" @submit="updateRules" />
  </div>
</template>