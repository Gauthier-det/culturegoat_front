<script setup>
import { ref, onMounted } from "vue";
import { useRoute, useRouter } from "vue-router";
import socket from "@/socket";
import { normalizeWord, isCloseMatch } from "@/tools.js";

const route = useRoute();
const router = useRouter();
const roomId = route.params.roomId;
const pseudo = sessionStorage.getItem("pseudo");

const currentQuestion = ref(null);
const options = ref([]);
const timeLeft = ref(0);
const players = ref({});
const gameOver = ref(false);
const clickedOption = ref(null);
const type = ref(null);
const response = ref(null);
const desc = ref(null);
const image_link = ref(null);
const goToDetails = ref(false);
const rematchCountdown = ref(null);

let timerInterval;
let answered = ref(false);

onMounted(() => {
  // Rejoindre la room (en cas de reconnexion)
  socket.emit("joinRoom", { roomId, playerName: pseudo });
  
  // Si la partie a déjà commencé, récupérer l'état
  socket.on("gameAlreadyStarted", (data) => {
    console.log("Reconnexion à une partie en cours");
    if (data.question) {
      currentQuestion.value = data.question.question;
      options.value = data.question.options;
      type.value = data.question.type;
      response.value = data.question.response;
      desc.value = data.question.desc;
      image_link.value = data.question.image_link;
    }
    players.value = data.players;
  });
  
  // Joueur prêt
  socket.emit("ready", roomId);
  
  // Réception des questions
  socket.on("newQuestion", (q) => {
    goToDetails.value = false;
    currentQuestion.value = q.question;
    options.value = q.options;
    timeLeft.value = q.time;
    type.value = q.type;
    response.value = q.response;
    desc.value = q.desc;
    image_link.value = q.image_link;
    answered.value = false;
    clickedOption.value = null;
    startTimer();
  });
  
  socket.on("updatePlayers", (data) => {
    players.value = data.players;
  });
  
  socket.on("gameOver", (finalPlayers) => {
    goToDetails.value = false;
    gameOver.value = true;
    players.value = finalPlayers;
    sessionStorage.setItem("isHost", "false");
    clearInterval(timerInterval);
  });
  
  socket.on("showAnswer", () => {
    answered.value = true;
    clearInterval(timerInterval);
    goToDetails.value = true;
  });

  // Gestion du rematch
  socket.on("rematchStarting", (data) => {
    console.log("Rematch en cours...");
    gameOver.value = false;
    goToDetails.value = false;
    rematchCountdown.value = data.countdown;
    players.value = data.players;
    currentQuestion.value = null;
    clickedOption.value = null;
    answered.value = false;
  });

  socket.on("rematchCountdown", (countdown) => {
    rematchCountdown.value = countdown;
  });
});

function sendAnswer(answer) {
  let opt_regex = [];
  for (let i = 0; i < options.value.length; i++) {
    opt_regex.push(normalizeWord(options.value[i]));
  }
  
  answer = normalizeWord(answer);
  
  if(type.value === 'qcm'){
    clickedOption.value = answer;
    answered.value = true;
  } else {
    if(isCloseMatch(answer, opt_regex)){
      answered.value = true;
      answer = "1";
    } else {
      answer = "0";
      return;
    }
  }
  
  socket.emit("answer", { roomId, answer });
}

function startTimer(){
  clearInterval(timerInterval);
  timerInterval = setInterval(() => {
    if (timeLeft.value > 0) {
      timeLeft.value--;
    } else {
      clearInterval(timerInterval);
      answered.value = true;
    }
  }, 1000);
}

function backToMenu(){
  router.push("/");
}

function requestRematch(){
  socket.emit("requestRematch", roomId);
}
</script>

<template>
  <div>
    <h1>Partie - Room {{ roomId }}</h1>
    
    <!-- Compte à rebours du rematch -->
    <div v-if="rematchCountdown !== null && rematchCountdown > 0">
      <h2>🔄 Nouvelle partie dans {{ rematchCountdown }}s...</h2>
      <p>Préparez-vous !</p>
      <ul>
        <li v-for="(p, id) in players" :key="id">{{ p.name }} - Score réinitialisé</li>
      </ul>
    </div>
    
    <!-- Réponse détaillée -->
    <div v-else-if="(timeLeft <= 4 && !gameOver) || goToDetails">
      <h2 v-if="type == 'qcm'">{{ response }}</h2>
      <h2 v-else>La réponse était : {{ options[0] }}</h2>
      <p v-if="desc"><em>{{ desc }}</em></p>
      <div v-if="image_link">
        <img :src="image_link" alt="Image associée à la question" style="max-width: 300px; max-height: 300px;" />
      </div>
    </div>
    
    <!-- Question en cours -->
    <div v-else-if="(!gameOver && timeLeft > 4) && !goToDetails">
      <h2>{{ currentQuestion }}</h2>
      <p>Temps restant : {{ timeLeft-4 }}s</p>
      
      <div class="qcmQuest" v-if="type === 'qcm'">
        <div class="game-options">
          <button 
            v-for="opt in options" 
            :key="opt" 
            @click="sendAnswer(opt)" 
            :disabled="answered"
            :class="{ clicked: clickedOption == opt }">
            {{ opt }}
          </button>
        </div>
      </div>
      
      <div class="openQuest" v-else-if="type === 'open'">
        <div class="game-options">
          <input 
            type="text" 
            v-model="clickedOption" 
            :disabled="answered" 
            placeholder="Votre réponse"
            @keyup.enter="sendAnswer(clickedOption)" />
          <button 
            @click="sendAnswer(clickedOption)" 
            :disabled="answered || !clickedOption">
            Valider
          </button>
        </div>
      </div>
    </div>
    
    <!-- Fin de partie -->
    <div v-else-if="gameOver && !goToDetails && rematchCountdown === null">
      <h2>Fin de la partie 🎉</h2>
      <h3>Scores finaux :</h3>
      <ul>
        <li v-for="(p, id) in players" :key="id">{{ p.name }} - {{ p.score }}</li>
      </ul>
      <div style="margin-top: 20px;">
        <button @click="requestRematch()" style="margin-right: 10px; background-color: #4CAF50;">
          🔄 Rejouer
        </button>
        <button @click="backToMenu()">
          🏠 Menu
        </button>
      </div>
    </div>
  </div>
</template>

<style>
button.clicked {
  background-color: green !important;
  color: white !important;
  border: 2px solid #444;
}
</style>