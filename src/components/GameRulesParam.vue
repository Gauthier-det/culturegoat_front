<script setup>
import { ref, onMounted } from "vue";
import socket from "../socket";

const emit = defineEmits(["submit"]);
const rulesOption = ref("FixedQuestions");
const scoreMax = ref(5);
const questionMax = ref(5);
const qcmTimeLimit = ref(8);
const openTimeLimit = ref(12);
const topics = ref([]);
const selectedTopics = ref([]);

onMounted(() => {
  socket.emit("getTopicsAndTypes");
  
  socket.on("topicsAndTypes", (data) => {
    topics.value = data.topics; 
    selectedTopics.value = topics.value.map(t => t.id);
  });
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
        <div>
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
        <div>
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
        <div>
          <label>Temps pour les QCM (secondes) :</label>
          <input type="number" v-model="qcmTimeLimit" min="5" />
        </div>
        <div>
          <label>Temps pour les questions ouvertes (secondes) :</label>
          <input type="number" v-model="openTimeLimit" min="5" />
        </div>

        <div class="topics-section">
          <label>Thèmes souhaités :</label>
          <div class="topics-list">
            <div 
              v-for="topic in topics" 
              :key="topic.id"
              class="topic-item"
            >
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
          <p v-if="selectedTopics.length === 0" class="warning">
            ⚠️ Sélectionnez au moins un thème
          </p>
        </div>
        <button type="submit">Valider</button>
      </form>
    </div>
  </div>
</template>
