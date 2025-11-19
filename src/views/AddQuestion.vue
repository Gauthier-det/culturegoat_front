<script setup>
import { ref, onMounted, watch } from "vue";
import { useRouter } from "vue-router";
import socket from "@/socket";
import { loginCreator, isAuthenticated, getUserRole } from "@/utils/auth";
import AppHeader from "@/components/AppHeader.vue";

const router = useRouter();

const loading = ref(true);
const topics = ref([]);
const types = ref([]);
const selectedTopic = ref("");
const selectedType = ref("");
const questionText = ref("");
const desc = ref("");
const imageLink = ref("");
const imageCredit = ref("");
const options = ref(["", "", "", ""]); 
const response = ref("");
const error = ref("");
const connected = ref(false);
const createurPassword = ref("");
const authLoading = ref(false);

onMounted(() => {
  // Vérifier si déjà authentifié
  if (isAuthenticated() && getUserRole() === 'creator') {
    connected.value = true;
  }
  
  loadTopicsAndTypes();
});

function loadTopicsAndTypes() {
  socket.emit("getTopicsAndTypes");
  socket.on("topicsAndTypes", (data) => {
    topics.value = data.topics || [];
    types.value = data.types || [];
    loading.value = false;
  });
}

watch(selectedType, (newType) => {
  if (!newType) return;

  if (newType.label === "qcm") {
    const firstFour = options.value.slice(0, 4).map(v => v || ""); 
    while (firstFour.length < 4) firstFour.push(""); 
    options.value = firstFour;
    if (!options.value.includes(response.value)) response.value = "";
  }

  if (newType.label === "open") {
    const cleaned = options.value.map(v => v || "").filter(v => v.trim() !== "");
    options.value = cleaned.length ? cleaned : [""];
    response.value = "1"; 
  }
});

function addOption() {
  if (selectedType.value && selectedType.value.label === "open") {
    options.value.push("");
  }
}

function removeOption(index) {
  options.value.splice(index, 1);
  if (selectedType.value && selectedType.value.label === "open" && options.value.length === 0) {
    options.value.push("");
  }
}

async function sendQuestion() {
  error.value = "";
  
  if (!questionText.value || !selectedType.value || !selectedTopic.value) {
    error.value = "Veuillez remplir tous les champs obligatoires.";
    return;
  }

  if (selectedType.value.label === "qcm") {
    if (!options.value.includes(response.value)) {
      error.value = "La réponse doit être l'une des options proposées.";
      return;
    }     
    if (!response.value) {
      error.value = "Veuillez indiquer la bonne réponse.";
      return;
    }
    if(options.value.length != 4){
      error.value = "Veuillez entrer le bon nombre de réponses";
      return;
    }
    for (let opt of options.value) {
      if (!opt || opt.trim() === "") {
        error.value = "Veuillez remplir toutes les options.";
        return;
      }
    }
  } else if (selectedType.value.label === "open") {
    response.value = "1";
  }

  const questionData = {
    question: questionText.value,
    options: options.value,
    response: response.value,
    desc: desc.value,
    topic: selectedTopic.value,
    type: selectedType.value,
    image_link: imageLink.value || null,
    image_credit: imageCredit.value || null
  };

  socket.emit("addQuestion", questionData, (res) => {
    if (res?.success) {
      alert("Question ajoutée avec succès !");
      selectedTopic.value = "";
      selectedType.value = "";
      questionText.value = "";
      desc.value = "";
      imageLink.value = "";
      imageCredit.value = "";
      options.value = ["", "", "", ""];
      response.value = "";
      error.value = "";
    } else {
      error.value = res.error || "Erreur lors de l'ajout de la question.";
    }
  });
}

async function checkAuth() {
  if (!createurPassword.value) return;
  
  authLoading.value = true;
  error.value = "";
  
  try {
    await loginCreator(createurPassword.value);
    connected.value = true;
  } catch (err) {
    error.value = "Mot de passe incorrect";
  } finally {
    authLoading.value = false;
  }
}
</script>

<template>
  <!-- Auth -->
  <div class="page-container" v-if="!connected">
    <AppHeader />
    
    <div class="auth-wrapper">
      <form @submit.prevent="checkAuth" class="auth-form">
        <h2>🔐 Authentification créateur</h2>
        <div>
          <input type="text" name="username" autocomplete="username" style="display:none"/>
          <label for="createurPassword">Mot de passe :</label>
          <input 
            type="password" 
            id="createurPassword" 
            v-model="createurPassword" 
            autocomplete="new-password" 
            :disabled="authLoading"
            required 
          />
        </div>
        <p v-if="error" class="error-message">{{ error }}</p>
        <button type="submit" :disabled="authLoading">
          {{ authLoading ? 'Connexion...' : 'Se connecter' }}
        </button>
      </form>
    </div>
  </div>

  <!-- Form -->
  <div class="page-container" v-else>
    <AppHeader />
    
    <div class="content-wrapper">
      <div class="form-wrapper">
        <h1>Ajouter une question</h1>

        <div v-if="loading" class="loading-message">
          Chargement des topics...
        </div>

        <form v-else @submit.prevent="sendQuestion" class="question-form">
          <div class="form-group">
            <label>Question :</label>
            <input v-model="questionText" type="text" required />
          </div>

          <div class="form-group">
            <label>Description (facultatif) :</label>
            <textarea v-model="desc" />
          </div>

          <div class="form-group">
            <label>Lien image (facultatif) :</label>
            <input v-model="imageLink" type="text" />
          </div>

          <div class="form-group">
            <label>Crédit de l'image (ou lien vers la page où l'image a été trouvée) (facultatif) :</label>
            <input v-model="imageCredit" type="text" />
          </div>

          <div class="form-group">
            <label>Sujet :</label>
            <select v-model="selectedTopic" required>
              <option value="" disabled>Choisir un sujet</option>
              <option v-for="topic in topics" :key="topic.id" :value="topic">
                {{ topic.label }}
              </option>
            </select>
          </div>

          <div class="form-group">
            <label>Type :</label>
            <select v-model="selectedType" required>
              <option value="" disabled>Choisir un type</option>
              <option v-for="type in types" :key="type.id" :value="type">
                {{ type.label }}
              </option>
            </select>
          </div>

          <div v-if="selectedType.label === 'qcm'" class="form-group">
            <label>Options (4 fixes) :</label>
            <div class="options-container">
              <div v-for="(opt, i) in options.slice(0, 4)" :key="i" class="option-row">
                <span>{{ i + 1 }}.</span>
                <input v-model="options[i]" type="text" placeholder="Option" required />
              </div>
            </div>
          </div>

          <div v-else-if="selectedType.label === 'open'" class="form-group">
            <label>Propositions possibles :</label>
            <div class="options-container">
              <div v-for="(opt, i) in options" :key="i" class="option-row">
                <input v-model="options[i]" type="text" placeholder="Proposition" />
                <button
                  type="button"
                  @click="removeOption(i)"
                  v-if="options.length > 1"
                  class="btn-remove"
                >
                  ✕
                </button>
              </div>
            </div>
            <button type="button" class="btn-add" @click="addOption">
              + Ajouter une option
            </button>
          </div>

          <div v-if="selectedType.label === 'qcm'" class="form-group">
            <label>Bonne réponse :</label>
            <input v-model="response" type="text" required />
          </div>

          <p v-if="error" class="error-message">{{ error }}</p>

          <button type="submit">Enregistrer la question</button>
        </form>
      </div>
    </div>
  </div>
</template>

<style scoped>
.form-wrapper h1 {
  color: var(--accent-gold);
  text-align: center;
  margin-bottom: 2rem;
  font-size: 1.8rem;
  font-weight: 300;
}

.question-form {
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
  color: var(--accent-gold);
  font-weight: 500;
  font-size: 0.95rem;
}

.form-group textarea {
  min-height: 80px;
  resize: vertical;
}

.options-container {
  display: flex;
  flex-direction: column;
  gap: 0.8rem;
}

.option-row {
  display: flex;
  gap: 0.8rem;
  align-items: center;
}

.option-row span {
  color: var(--accent-gold);
  font-weight: bold;
  min-width: 25px;
}

.option-row input {
  flex: 1;
}

.btn-remove {
  background: var(--color-error);
  padding: 0.5rem 1rem;
  min-width: auto;
  flex-shrink: 0;
}

.btn-remove:hover:not(:disabled) {
  background: var(--color-error-dark);
}

.btn-add {
  background: var(--color-success);
  margin-top: 0.5rem;
}

.btn-add:hover:not(:disabled) {
  background: var(--color-success-dark);
}

@media (max-width: 768px) {
  .form-wrapper {
    padding: 2rem 1.5rem;
  }
  
  .form-wrapper h1 {
    font-size: 1.5rem;
  }
}

@media (max-width: 480px) {
  .form-wrapper {
    padding: 1.5rem 1rem;
    border-radius: 0;
  }
  
  .form-wrapper h1 {
    font-size: 1.3rem;
  }
  
  .option-row {
    flex-direction: column;
    align-items: stretch;
  }
  
  .option-row button {
    width: 100%;
  }
}
</style>
