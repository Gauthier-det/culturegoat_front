<script setup>
import { ref } from "vue";
import { useRouter } from "vue-router";
import AppHeader from "@/components/AppHeader.vue";

const pseudo = ref("");
const roomId = ref("");
const router = useRouter();

if(sessionStorage.getItem("pseudo") != null){
  pseudo.value = sessionStorage.getItem("pseudo");
}

function createRoom() {
  let id = Math.random().toString(36).substr(2, 4);
  if(pseudo.value.trim() === ""){
    pseudo.value = "Jeune Goat "+Math.floor(Math.random()*1000);
  }
  sessionStorage.setItem("pseudo", pseudo.value);
  sessionStorage.setItem("isHost", true);
  router.push(`/room/${id}`);
}

function joinRoom() {
  if(pseudo.value.trim() === ""){
    pseudo.value = "Jeune Goat "+Math.floor(Math.random()*1000);
  }
  sessionStorage.setItem("pseudo", pseudo.value);
  sessionStorage.setItem("isHost", false);
  router.push(`/room/${roomId.value}`);
}
</script>

<template>
  <div class="page-container">
    <AppHeader subtitle="Culture ou coup dur ?" />
    
    <div class="content-wrapper">
      <div class="home-content">
        <div class="input-section">
          <label>Ton super pseudo :</label>
          <input v-model="pseudo" placeholder="Entre ton pseudo ici..." />
        </div>
        
        <div class="home-actions">
          <div class="action-left">
            <button @click="createRoom" class="btn-create">Crée ta room</button>
          </div>
          
          <div class="vertical-divider"></div>
          <div class="horizontal-divider"></div>
          
          <div class="action-right">
            <label>Code de Room</label>
            <input v-model="roomId" placeholder="XXXX" class="code-input" maxlength="4" />
            <button @click="joinRoom" class="btn-join">Rejoins une game</button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.home-content {
  width: 100%;
  max-width: 900px;
}

.input-section {
  margin-bottom: 3rem;
  text-align: center;
  width: 100%;
}

.input-section label {
  display: block;
  margin-bottom: 0.8rem;
  color: var(--text-white);
  font-size: 1rem;
}

.input-section input {
  max-width: 450px;
  margin: 0 auto;
}

.home-actions {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0;
  margin-top: 3rem;
  width: 100%;
}

.action-left,
.action-right {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 1.2rem;
  align-items: center;
  padding: 0 1rem;
}

.action-right label {
  font-size: 0.95rem;
  color: var(--text-muted);
  margin-bottom: 0.3rem;
}

.code-input {
  max-width: 200px;
  text-align: center;
  font-weight: bold;
  letter-spacing: 3px;
  text-transform: uppercase;
}

.btn-create,
.btn-join {
  width: 100%;
  max-width: 280px;
}

@media (max-width: 768px) {
  .home-actions {
    flex-direction: column;
    gap: 0;
  }
  
  .action-left,
  .action-right {
    width: 100%;
    max-width: 400px;
    padding: 1rem;
  }
  
  .btn-create,
  .btn-join {
    max-width: 100%;
  }
  
  .code-input {
    max-width: 100%;
  }
}

@media (max-width: 480px) {
  .input-section {
    margin-bottom: 2rem;
  }
  
  .input-section input {
    max-width: 100%;
  }
  
  .home-actions {
    margin-top: 2rem;
  }
}
</style>
