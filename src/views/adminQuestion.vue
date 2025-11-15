<script setup>
import { ref, onMounted } from "vue";
import { useRouter } from "vue-router";
import socket from "@/socket";
import AppHeader from "@/components/AppHeader.vue";

const router = useRouter();

const questions = ref([]);
const connected = ref(false);
const adminPassword = ref("");
const ADMIN_PASS = import.meta.env.VITE_ADMIN_PASS;

onMounted(() => {
  checkAuth();
  socket.emit("getTempQuestions");

  socket.on("tempQuestions", (data) => {
    questions.value = data;
  });

  socket.on("questionValidated", (id) => {
    questions.value = questions.value.filter(q => q.id !== id);
  });

  socket.on("questionDeleted", (id) => {
    questions.value = questions.value.filter(q => q.id !== id);
  });
});

function accept(id) {
  socket.emit("validateQuestion", id);
}

function reject(id) {
  socket.emit("deleteQuestion", id);
}

function checkAuth(){
  if(sessionStorage.getItem("adminValue")){
    if(sessionStorage.getItem("adminValue") === "1"){
      connected.value = true;
      return;
    }
  }
  if(adminPassword.value === ""){
    return;
  }
  if(adminPassword.value === ADMIN_PASS){
    sessionStorage.setItem("adminValue", "1");
    connected.value = true;
  } else {
    alert("Mot de passe incorrect");
  }
}
</script>

<template>
  <!-- Auth -->
  <div class="page-container" v-if="!connected">
    <AppHeader />
    
    <div class="auth-wrapper">
      <form @submit.prevent="checkAuth" class="auth-form">
        <h2>🔐 Authentification administrateur</h2>
        <div>
          <input type="text" name="username" autocomplete="username" style="display:none"/>
          <label for="adminPassword">Mot de passe :</label>
          <input 
            type="password" 
            id="adminPassword" 
            v-model="adminPassword" 
            autocomplete="new-password" 
            required 
          />
        </div>
        <button type="submit">Se connecter</button>
      </form>
    </div>
  </div>

  <!-- Admin panel -->
  <div class="page-container" v-else>
    <AppHeader />
    
    <div class="content-wrapper">
      <div class="admin-content">
        <h2>📝 Validation des questions en attente</h2>
        
        <div v-if="questions.length === 0" class="empty-message">
          Aucune question en attente
        </div>

        <div class="questions-list" v-else>
          <div v-for="q in questions" :key="q.id" class="question-card">
            <h3>{{ q.question }}</h3>
            <p class="desc" v-if="q.desc">{{ q.desc }}</p>
            <p><strong>Type :</strong> {{ q.type.label }}</p>
            <p><strong>Topic :</strong> {{ q.topic.label }}</p>

            <ul v-if="q.options.length > 0" class="options-list">
              <li 
                v-for="opt in q.options" 
                :key="opt" 
                :class="{ 'correct-answer': opt === q.response }">
                {{ opt }}
              </li>
            </ul>

            <div class="question-actions">
              <button @click="accept(q.id)" class="btn-validate">
                ✅ Accepter
              </button>
              <button @click="reject(q.id)" class="btn-delete">
                ❌ Rejeter
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.admin-content {
  max-width: 850px;
  width: 100%;
}

.admin-content h2 {
  color: var(--accent-gold);
  text-align: center;
  margin-bottom: 2rem;
  font-size: 1.5rem;
  font-weight: 300;
}

.questions-list {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.question-card {
  background: var(--secondary-bg);
  border: 2px solid var(--border-gold);
  border-radius: 10px;
  padding: 1.5rem;
  transition: transform 0.2s;
}

.question-card:hover {
  transform: translateY(-2px);
}

.question-card h3 {
  color: var(--accent-gold);
  margin-bottom: 0.8rem;
  font-size: 1.1rem;
  font-weight: 500;
}

.question-card p {
  color: var(--text-white);
  margin-bottom: 0.5rem;
  font-size: 0.95rem;
}

.question-card p.desc {
  color: var(--text-muted);
  font-style: italic;
  margin-bottom: 1rem;
}

.question-card p strong {
  color: var(--accent-gold);
}

.options-list {
  list-style: none;
  margin: 1rem 0;
  padding: 0;
}

.options-list li {
  color: var(--text-white);
  padding: 0.5rem 0.8rem;
  margin-bottom: 0.3rem;
  background: rgba(212, 165, 116, 0.05);
  border-radius: 5px;
  border-left: 3px solid var(--divider-gold);
}

.options-list li.correct-answer {
  color: var(--color-success);
  font-weight: bold;
  border-left-color: var(--color-success);
  background: rgba(74, 124, 89, 0.1);
}

.question-actions {
  display: flex;
  gap: 0.8rem;
  margin-top: 1.2rem;
  flex-wrap: wrap;
}

.question-actions button {
  flex: 1;
  min-width: 140px;
  padding: 0.7rem 1.2rem;
}

@media (max-width: 768px) {
  .admin-content {
    padding: 0;
  }
  
  .question-card {
    padding: 1.2rem;
  }
}

@media (max-width: 480px) {
  .admin-content h2 {
    font-size: 1.3rem;
  }
  
  .question-card {
    border-radius: 0;
    padding: 1rem;
  }
  
  .question-actions {
    flex-direction: column;
  }
  
  .question-actions button {
    width: 100%;
    min-width: auto;
  }
}
</style>
