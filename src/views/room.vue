<script setup>
import { ref } from "vue";
import { useRoute, useRouter } from "vue-router";
import socket from "@/socket";
import AppHeader from "@/components/AppHeader.vue";
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

socket.on("gameAlreadyStarted", () => {
  console.log("La partie a déjà commencé, redirection vers le jeu...");
  router.push(`/game/${roomId}`);
});

function startGame() {
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
  <div class="page-container">
    <AppHeader :roomId="roomId" />
    
    <div class="content-wrapper">
      <div class="room-content">
        <div class="players-section">
          <h3>Dans cette room</h3>
          <ul class="players-list">
            <li v-for="(p, id) in players" :key="id">
              <span class="player-name">{{ p.name }}</span>
              <span v-if="p.disconnected" class="status-dot">●</span>
            </li>
          </ul>
        </div>
        
        <div class="vertical-divider"></div>
        <div class="horizontal-divider"></div>
        
        <div class="actions-section">
          <button @click="showRulesParam = true" v-if="isHost" class="btn-rules">
            Règles de la game
          </button>
          <button v-if="isHost" @click="startGame" class="btn-start">
            C'est parti !
          </button>
          <p v-else class="waiting-text">En attente de l'host...</p>
        </div>
      </div>
    </div>
    
    <GameRulesParam v-if="showRulesParam" @submit="updateRules" />
  </div>
</template>

<style scoped>
.room-content {
  display: flex;
  align-items: flex-start;
  justify-content: center;
  gap: 0;
  width: 100%;
  max-width: 900px;
}

.players-section {
  flex: 1;
  min-width: 180px;
  padding: 0 1.5rem;
}

.players-section h3 {
  text-align: center;
  margin-bottom: 0.8rem;
  color: var(--accent-gold);
  font-size: 0.9rem;
}

.players-list {
  background: var(--secondary-bg);
  border: 1px solid var(--border-gold);
  border-radius: 6px;
  padding: 0.4rem;
}

.players-list li {
  padding: 0.4rem 0.6rem;
  border-bottom: 1px solid var(--divider-gold);
  font-size: 0.85rem;
  transition: background 0.2s;
}

.players-list li:hover {
  background: rgba(212, 165, 116, 0.1);
}

.players-list li:last-child {
  border-bottom: none;
}

.player-name {
  color: var(--accent-gold);
  font-weight: 500;
}

.status-dot {
  color: orange;
  font-size: 0.9rem;
  animation: blink 1.5s infinite;
}

@keyframes blink {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.3; }
}

.actions-section {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
  align-items: center;
  justify-content: center;
  padding: 0 1.5rem;
}

.btn-rules,
.btn-start {
  width: 100%;
  max-width: 280px;
}

.waiting-text {
  color: var(--text-muted);
  font-style: italic;
  text-align: center;
  padding: 2rem;
  font-size: 0.95rem;
}

@media (max-width: 768px) {
  .room-content {
    flex-direction: column;
    align-items: center;
  }
  
  .players-section,
  .actions-section {
    width: 100%;
    max-width: 400px;
    padding: 1rem;
  }
  
  .players-section h3 {
    text-align: center;
  }
  
  .btn-rules,
  .btn-start {
    max-width: 100%;
  }
}
</style>
