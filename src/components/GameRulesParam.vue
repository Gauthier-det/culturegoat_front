<script setup>
import { ref, defineEmits } from "vue";

const emit = defineEmits(["submit"]);
const rulesOption = ref("FixedQuestions");
const scoreMax = ref(5);
const questionMax = ref(5);
const qcmTimeLimit = ref(8);
const openTimeLimit = ref(12);
const rules = ref({});

function submitRules() {
  emit("submit", {
    rules: rulesOption.value,
    scoreMax: scoreMax.value,
    questionMax: questionMax.value,
    qcmTimeLimit: qcmTimeLimit.value,
    openTimeLimit: openTimeLimit.value,
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
            <input type="radio" v-model="rules" value="FixedQuestions" />
            Nombre de questions fixe
          </label>
          <input
            v-if="rules === 'FixedQuestions'"
            type="number"
            v-model="questionMax"
            min="1"
            placeholder="Nombre de questions"
          />
        </div>
        <div>
          <label>
            <input type="radio" v-model="rules" value="ScoreMax" />
            Score maximum
          </label>
          <input
            v-if="rules === 'ScoreMax'"
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
        <button type="submit" @click="submitRules">Valider</button>
      </form>
    </div>
  </div>
</template>

<style scoped>
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
}
.modal-content {
  background: white;
  padding: 20px;
  border-radius: 8px;
  width: 300px;
}
.modal-content input {
  margin: 5px 0;
  width: 100%;
}
</style>
