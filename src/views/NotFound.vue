<script setup>
import { useRouter } from 'vue-router';

const router = useRouter();

function goHome() {
  router.push('/');
}
</script>

<template>
  <div class="page-container">
    <div class="content-wrapper">
      <div class="not-found-content">
        <div class="error-code">404</div>
        <h1>Oups ! Page introuvable</h1>
        <p class="error-message">
          La page que tu cherches n'existe pas ou a été déplacée.
        </p>
        
        <div class="error-actions">
          <button @click="goHome" class="btn-primary">
            🏠 Retour à l'accueil
          </button>
          <button @click="router.back()" class="btn-secondary">
            ← Page précédente
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.not-found-content {
  text-align: center;
  padding: 3rem 1rem;
  max-width: 600px;
  margin: 0 auto;
}

.error-code {
  font-size: 8rem;
  font-weight: bold;
  color: var(--accent-gold);
  line-height: 1;
  margin-bottom: 1rem;
  text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.3);
}

.not-found-content h1 {
  color: var(--text-white);
  font-size: 2rem;
  margin-bottom: 1rem;
  font-weight: 300;
}

.error-message {
  color: var(--text-muted);
  font-size: 1.1rem;
  margin-bottom: 2.5rem;
  line-height: 1.6;
}

.error-actions {
  display: flex;
  gap: 1rem;
  justify-content: center;
  flex-wrap: wrap;
  margin-bottom: 3rem;
}

.error-actions button {
  min-width: 180px;
}

.btn-primary {
  background: var(--accent-gold);
  color: var(--primary-bg);
}

.btn-secondary {
  background: transparent;
  border: 2px solid var(--border-gold);
  color: var(--accent-gold);
}

.btn-secondary:hover:not(:disabled) {
  background: rgba(212, 165, 116, 0.1);
}

.suggestions {
  background: var(--secondary-bg);
  border: 2px solid var(--border-gold);
  border-radius: 10px;
  padding: 2rem;
  margin-top: 3rem;
}

.suggestions p {
  color: var(--accent-gold);
  font-weight: 500;
  margin-bottom: 1rem;
}

.suggestions ul {
  list-style: none;
  padding: 0;
  display: flex;
  flex-direction: column;
  gap: 0.8rem;
}

.suggestions li {
  padding: 0;
}

.suggestions a {
  color: var(--text-white);
  text-decoration: none;
  transition: color 0.2s;
}

.suggestions a:hover {
  color: var(--accent-gold);
  text-decoration: underline;
}

@media (max-width: 768px) {
  .error-code {
    font-size: 6rem;
  }
  
  .not-found-content h1 {
    font-size: 1.5rem;
  }
  
  .error-message {
    font-size: 1rem;
  }
  
  .error-actions {
    flex-direction: column;
  }
  
  .error-actions button {
    width: 100%;
  }
}

@media (max-width: 480px) {
  .error-code {
    font-size: 4rem;
  }
  
  .not-found-content {
    padding: 2rem 1rem;
  }
  
  .suggestions {
    padding: 1.5rem;
  }
}
</style>
