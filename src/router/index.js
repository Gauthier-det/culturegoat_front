import { createRouter, createWebHistory } from "vue-router";
import Accueil from "../views/Home.vue";
import Room from "../views/room.vue";
import Game from "../views/game.vue";
import AddQuestion from "../views/addQuestion.vue";
import AdminQuestion from "../views/adminQuestion.vue";

const routes = [
    { path: "/", component: Accueil },
    { path: "/room/:roomId", component: Room },
    { path: "/game/:roomId", component: Game },
    { path: "/add-question", component: AddQuestion },
    { path: "/admin-question", component: AdminQuestion }
];

const router = createRouter({
    history: createWebHistory(),
    routes,
});

export default router;