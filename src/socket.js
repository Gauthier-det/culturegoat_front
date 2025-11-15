import { io } from "socket.io-client";

const BACKEND_URL = import.meta.env.VITE_BACKEND_URL || "http://localhost:3001";

// Récupérer le token du localStorage
function getAuthToken() {
  return localStorage.getItem('auth_token');
}

// Créer la connexion socket avec le token
const socket = io(BACKEND_URL, { 
  autoConnect: true,
  auth: {
    token: getAuthToken()
  }
});

// Mettre à jour le token si nécessaire
export function updateSocketAuth(token) {
  if (token) {
    localStorage.setItem('auth_token', token);
    socket.auth = { token };
    
    // Reconnecter avec le nouveau token
    if (socket.connected) {
      socket.disconnect();
      socket.connect();
    }
  } else {
    localStorage.removeItem('auth_token');
    socket.auth = {};
  }
}

// Déconnexion (supprimer le token)
export function logout() {
  updateSocketAuth(null);
  sessionStorage.clear();
}

export default socket;
