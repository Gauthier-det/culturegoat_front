import socket, { updateSocketAuth } from '@/socket';

/**
 * Connexion admin
 */
export async function loginAdmin(password) {
  return new Promise((resolve, reject) => {
    socket.emit('adminLogin', password, (response) => {
      if (response.success) {
        updateSocketAuth(response.token);
        sessionStorage.setItem('role', 'admin');
        resolve(true);
      } else {
        reject(new Error(response.error || 'Authentication failed'));
      }
    });
  });
}

/**
 * Connexion créateur
 */
export async function loginCreator(password) {
  return new Promise((resolve, reject) => {
    socket.emit('creatorLogin', password, (response) => {
      if (response.success) {
        updateSocketAuth(response.token);
        sessionStorage.setItem('role', 'creator');
        resolve(true);
      } else {
        reject(new Error(response.error || 'Authentication failed'));
      }
    });
  });
}

/**
 * Vérifier si l'utilisateur est authentifié
 */
export function isAuthenticated() {
  return !!localStorage.getItem('auth_token');
}

/**
 * Obtenir le rôle de l'utilisateur
 */
export function getUserRole() {
  return sessionStorage.getItem('role') || 'guest';
}

/**
 * Déconnexion
 */
export function logout() {
  localStorage.removeItem('auth_token');
  sessionStorage.removeItem('role');
  updateSocketAuth(null);
}
