import { io } from "socket.io-client";

const socket = io("https://culturegoat-back.onrender.com", { autoConnect: true });

export default socket;
