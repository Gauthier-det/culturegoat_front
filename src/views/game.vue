<script setup>
import { ref, onMounted } from "vue";
import { useRoute, useRouter } from "vue-router";
import socket from "@/socket";
import AppHeader from "@/components/AppHeader.vue";
import { normalizeWord, isCloseMatch } from "@/utils/tools.js";

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
const showFeedback = ref(false);
const isCorrect = ref(false);

let timerInterval;
let answered = ref(false);

onMounted(() => {
  socket.emit("joinRoom", { roomId, playerName: pseudo });
  
  socket.on("gameAlreadyStarted", (data) => {
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
  
  socket.emit("ready", roomId);
  
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
    showFeedback.value = false;
    isCorrect.value = false;
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

  socket.on("rematchStarting", (data) => {
    gameOver.value = false;
    goToDetails.value = false;
    rematchCountdown.value = data.countdown;
    players.value = data.players;
    currentQuestion.value = null;
    clickedOption.value = null;
    answered.value = false;
    showFeedback.value = false;
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
    
    const correctAnswer = normalizeWord(response.value);
    isCorrect.value = (answer === correctAnswer);
    showFeedback.value = true;
    
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

function getOptionClass(opt) {
  const normalizedOpt = normalizeWord(opt);
  const normalizedResponse = normalizeWord(response.value);
  
  if (!showFeedback.value) return '';
  
  if (clickedOption.value === normalizedOpt) {
    return isCorrect.value ? 'correct' : 'incorrect';
  }
  
  if (!isCorrect.value && normalizedOpt === normalizedResponse) {
    return 'show-correct';
  }
  
  return '';
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
  <div class="page-container">
    <AppHeader :roomId="roomId" />
    
    <div class="content-wrapper">
      <!-- Rematch countdown -->
      <div v-if="rematchCountdown !== null && rematchCountdown > 0" class="rematch-section">
        <h2>🔄 Nouvelle partie dans {{ rematchCountdown }}s...</h2>
        <p>Préparez-vous !</p>
      </div>
      
      <!-- Réponse -->
      <div v-else-if="(timeLeft <= 4 && !gameOver) || goToDetails" class="answer-section">
        <h2 v-if="type == 'qcm'">{{ response }}</h2>
        <h2 v-else>La réponse était : {{ options[0] }}</h2>
        <p v-if="desc"><em>{{ desc }}</em></p>
        <img v-if="image_link" :src="image_link" alt="Image" />
      </div>
      
      <!-- Question -->
      <div v-else-if="(!gameOver && timeLeft > 4) && !goToDetails" class="question-section">
        <h2>{{ currentQuestion }}</h2>
        <div class="timer">⏱️ {{ timeLeft-4 }}s</div>
        
        <div class="qcmQuest" v-if="type === 'qcm'">
          <div class="game-options">
            <button 
              v-for="opt in options" 
              :key="opt" 
              @click="sendAnswer(opt)" 
              :disabled="answered"
              :class="getOptionClass(opt)">
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
      
      <!-- Game Over -->
      <div v-else-if="gameOver && !goToDetails && rematchCountdown === null" class="gameover-section">
        <h2>Fin de la partie 🎉</h2>
        <h3>Scores finaux :</h3>
        <ul class="scores-list">
          <li v-for="(p, id) in players" :key="id">
            <span>{{ p.name }}</span>
            <span>{{ p.score }}</span>
          </li>
        </ul>
        <div class="gameover-actions">
          <button @click="requestRematch()" class="btn-rematch">
            🔄 Rejouer
          </button>
          <button @click="backToMenu()">
            🏠 Menu
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.question-section {
  text-align: center;
  padding: 0 1rem;
  width: 100%;
  max-width: 800px;
}

.question-section h2 {
  font-size: 1.4rem;
  color: var(--text-white);
  margin-bottom: 1.5rem;
  line-height: 1.4;
}

.timer {
  display: inline-block;
  background: var(--secondary-bg);
  border: 2px solid var(--border-gold);
  border-radius: 8px;
  padding: 0.6rem 1.8rem;
  color: var(--accent-gold);
  font-weight: bold;
  font-size: 1.1rem;
  margin-bottom: 1.5rem;
}

.qcmQuest .game-options {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 1.2rem;
  margin-top: 2rem;
}

.qcmQuest .game-options button {
  padding: 1.8rem 1rem;
  font-size: 1rem;
  border-radius: 15px;
  min-height: 80px;
  word-wrap: break-word;
  transition: all 0.3s ease;
}

.qcmQuest .game-options button.correct {
  background: var(--color-success) !important;
  color: white !important;
  border: 3px solid var(--color-success-dark) !important;
  box-shadow: 0 0 20px rgba(74, 124, 89, 0.5);
}

.qcmQuest .game-options button.incorrect {
  background: var(--color-error) !important;
  color: white !important;
  border: 3px solid var(--color-error-dark) !important;
  box-shadow: 0 0 20px rgba(166, 77, 77, 0.5);
}

.qcmQuest .game-options button.show-correct {
  background: var(--color-success) !important;
  color: white !important;
  border: 3px solid var(--color-success-dark) !important;
  animation: pulse 0.6s ease-in-out;
}

@keyframes pulse {
  0%, 100% { transform: scale(1); }
  50% { transform: scale(1.05); }
}

.openQuest .game-options {
  display: flex;
  flex-direction: column;
  gap: 1rem;
  max-width: 500px;
  margin: 2rem auto 0;
}

.answer-section {
  text-align: center;
  padding: 2rem 1rem;
  max-width: 800px;
}

.answer-section h2 {
  color: var(--accent-gold);
  margin-bottom: 1rem;
  font-size: 1.5rem;
}

.answer-section p {
  color: var(--text-muted);
  font-style: italic;
  margin: 1rem 0;
  line-height: 1.6;
}

.answer-section img {
  max-width: 100%;
  max-height: 350px;
  border-radius: 10px;
  margin-top: 1.5rem;
  border: 2px solid var(--border-gold);
}

.gameover-section {
  text-align: center;
  padding: 2rem 1rem;
  max-width: 600px;
}

.gameover-section h2 {
  color: var(--text-white);
  margin-bottom: 2rem;
  font-size: 2rem;
  font-weight: 300;
}

.gameover-section h3 {
  color: var(--text-white);
  margin: 2rem 0 2.5rem;
  font-size: 1.3rem;
  font-weight: 300;
}

.scores-list {
  background: transparent;
  border: none;
  padding: 0;
  margin: 2rem auto;
  max-width: 500px;
  position: relative;
}

.scores-list::before {
  content: '';
  position: absolute;
  left: 50%;
  top: 0;
  bottom: 0;
  width: 2px;
  background: linear-gradient(
    to bottom,
    transparent,
    var(--accent-gold),
    var(--accent-gold),
    var(--accent-gold),
    transparent
  );
  transform: translateX(-50%);
}

.scores-list li {
  padding: 1rem 0;
  border-bottom: none;
  font-size: 1.1rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
  position: relative;
  background: transparent;
  transition: transform 0.2s;
}

.scores-list li:hover {
  transform: scale(1.02);
}

.scores-list li span:first-child {
  color: var(--accent-gold);
  font-weight: 400;
  text-align: right;
  flex: 1;
  padding-right: 2.5rem;
}

.scores-list li span:last-child {
  color: var(--text-white);
  font-weight: 400;
  font-size: 1.2rem;
  text-align: left;
  flex: 1;
  padding-left: 2.5rem;
}

.gameover-actions {
  display: flex;
  gap: 1rem;
  justify-content: center;
  margin-top: 3rem;
}

.gameover-actions button {
  flex: 1;
  min-width: 150px;
  max-width: 200px;
}

.rematch-section {
  text-align: center;
  padding: 3rem 2rem;
}

.rematch-section h2 {
  font-size: 2rem;
  color: var(--accent-gold);
  margin-bottom: 1rem;
}

@media (max-width: 768px) {
  .qcmQuest .game-options {
    gap: 1rem;
  }
  
  .qcmQuest .game-options button {
    padding: 1.5rem 0.8rem;
    font-size: 0.95rem;
    min-height: 70px;
  }
  
  .scores-list li span:first-child {
    padding-right: 2rem;
  }
  
  .scores-list li span:last-child {
    padding-left: 2rem;
  }
}

@media (max-width: 480px) {
  .qcmQuest .game-options {
    grid-template-columns: 1fr;
  }
  
  .qcmQuest .game-options button {
    padding: 1.3rem 1rem;
    min-height: 60px;
  }
  
  .scores-list li {
    font-size: 1rem;
  }
  
  .scores-list li span:first-child {
    padding-right: 1.5rem;
  }
  
  .scores-list li span:last-child {
    font-size: 1.1rem;
    padding-left: 1.5rem;
  }
  
  .gameover-actions {
    flex-direction: column;
  }
  
  .gameover-actions button {
    max-width: 100%;
    width: 100%;
  }
}
</style>
