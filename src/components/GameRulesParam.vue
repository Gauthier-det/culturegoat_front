<script setup>
import { ref, onMounted, onUnmounted } from "vue";
import socket from "../socket";

const emit = defineEmits(["submit"]);
const rulesOption = ref("FixedQuestions");
const scoreMax = ref(5);
const questionMax = ref(5);
const qcmTimeLimit = ref(8);
const openTimeLimit = ref(12);
const topics = ref([]);
const selectedTopics = ref([]);

const handleTopicsAndTypes = (data) => {
  if (data && data.topics && Array.isArray(data.topics)) {
    topics.value = data.topics;
    selectedTopics.value = data.topics.map(t => t.id);
  }
};

onMounted(() => {
  socket.off("topicsAndTypes");
  socket.on("topicsAndTypes", handleTopicsAndTypes);
  socket.emit("getTopicsAndTypes");
});

onUnmounted(() => {
  socket.off("topicsAndTypes", handleTopicsAndTypes);
});

function toggleTopic(topicId) {
  const index = selectedTopics.value.indexOf(topicId);
  if (index > -1) {
    selectedTopics.value.splice(index, 1);
  } else {
    selectedTopics.value.push(topicId);
  }
}

function submitRules() {
  if (rulesOption.value == "FixedQuestions") {
    questionMax.value = questionMax.value || 5;
    scoreMax.value = 0;
  } else if (rulesOption.value == "ScoreMax") {
    scoreMax.value = scoreMax.value || 5;
    questionMax.value = 0;
  }
  
  emit("submit", {
    rulesOption: rulesOption.value,
    scoreMax: parseInt(scoreMax.value),
    questionMax: parseInt(questionMax.value),
    qcmTimeLimit: parseInt(qcmTimeLimit.value),
    openTimeLimit: parseInt(openTimeLimit.value),
    selectedTopics: selectedTopics.value
  });
}
</script>

<template>
  <div class="modal-overlay">
    <div class="modal-content">
      <h2>Configurer les règles</h2>
      <form @submit.prevent="submitRules">
        <div class="form-group">
          <label>
            <input type="radio" v-model="rulesOption" value="FixedQuestions" />
            Nombre de questions fixe
          </label>
          <input
            v-if="rulesOption === 'FixedQuestions'"
            type="number"
            v-model="questionMax"
            min="1"
            placeholder="Nombre de questions"
          />
        </div>
        
        <div class="form-group">
          <label>
            <input type="radio" v-model="rulesOption" value="ScoreMax" />
            Score maximum
          </label>
          <input
            v-if="rulesOption === 'ScoreMax'"
            type="number"
            v-model="scoreMax"
            min="1"
            placeholder="Score maximum"
          />
        </div>
        
        <div class="form-group">
          <label>Temps pour les QCM (secondes) :</label>
          <input type="number" v-model="qcmTimeLimit" min="5" />
        </div>
        
        <div class="form-group">
          <label>Temps pour les questions ouvertes (secondes) :</label>
          <input type="number" v-model="openTimeLimit" min="5" />
        </div>

        <div class="topics-section">
          <label>Thèmes souhaités :</label>
          <div v-if="topics.length > 0" class="topics-list">
            <div v-for="topic in topics" :key="topic.id" class="topic-item">
              <label>
                <input 
                  type="checkbox" 
                  :value="topic.id"
                  :checked="selectedTopics.includes(topic.id)"
                  @change="toggleTopic(topic.id)"
                />
                {{ topic.label }}
              </label>
            </div>
          </div>
          <div v-else class="loading-message">Chargement des thèmes...</div>
          <p v-if="selectedTopics.length === 0" class="warning">
            ⚠️ Sélectionnez au moins un thème
          </p>
        </div>
        
        <button type="submit" :disabled="selectedTopics.length === 0">
          Valider
        </button>
      </form>
    </div>
  </div>
</template>

<style scoped>
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.9);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
  padding: 1rem;
  overflow-y: auto;
}

.modal-content {
  background: var(--primary-bg);
  border: 2px solid var(--border-gold);
  border-radius: 10px;
  padding: 2.5rem;
  max-width: 550px;
  width: 100%;
  max-height: 90vh;
  overflow-y: auto;
}

.modal-content h2 {
  color: var(--accent-gold);
  text-align: center;
  margin-bottom: 2rem;
  font-size: 1.5rem;
}

.modal-content form {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.form-group label {
  color: var(--text-white);
  font-size: 0.95rem;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.form-group input[type="radio"],
.form-group input[type="checkbox"] {
  width: auto;
  margin-right: 0.5rem;
  accent-color: var(--accent-gold);
  min-width: 20px;
  min-height: 20px;
}

.topics-section {
  background: var(--secondary-bg);
  border: 1px solid var(--border-gold);
  border-radius: 8px;
  padding: 1rem;
}

.topics-section > label {
  font-weight: bold;
  margin-bottom: 0.75rem;
  display: block;
  color: var(--accent-gold);
}

.topics-list {
  display: flex;
  flex-direction: column;
  gap: 0.7rem;
  margin-top: 0.75rem;
  max-height: 250px;
  overflow-y: auto;
  overflow-x: hidden;
  padding-right: 0.5rem;
}

.topics-list::-webkit-scrollbar {
  width: 8px;
}

.topics-list::-webkit-scrollbar-track {
  background: rgba(139, 109, 62, 0.2);
  border-radius: 4px;
}

.topics-list::-webkit-scrollbar-thumb {
  background: var(--accent-gold);
  border-radius: 4px;
}

.topics-list::-webkit-scrollbar-thumb:hover {
  background: var(--border-gold);
}

.topics-list {
  scrollbar-width: thin;
  scrollbar-color: var(--accent-gold) rgba(139, 109, 62, 0.2);
}

.topic-item label {
  cursor: pointer;
  color: var(--text-white);
  padding: 0.6rem 0.8rem;
  border-radius: 5px;
  display: flex;
  align-items: center;
  gap: 0.8rem;
  transition: background 0.2s;
}

.topic-item label:hover {
  background: rgba(212, 165, 116, 0.1);
}

.warning {
  color: #ff6b6b;
  font-size: 0.85rem;
  margin-top: 0.5rem;
  text-align: center;
  font-weight: bold;
}

@media (max-width: 480px) {
  .modal-content {
    padding: 1.5rem 1rem;
    border-radius: 0;
    max-height: 100vh;
  }
  
  .modal-content h2 {
    font-size: 1.3rem;
  }
  
  .topics-list {
    max-height: 200px;
  }
}
</style>
