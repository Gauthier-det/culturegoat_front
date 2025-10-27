<script setup>
import { ref } from "vue";

const emit = defineEmits(["submit"]);
const rulesOption = ref("FixedQuestions");
const scoreMax = ref(5);
const questionMax = ref(5);
const qcmTimeLimit = ref(8);
const openTimeLimit = ref(12);

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
    openTimeLimit: parseInt(openTimeLimit.value)
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
        <button type="submit">Valider</button>
      </form>
    </div>
  </div>
</template>
