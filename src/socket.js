import { io } from "socket.io-client";

const socket = io("https://culturegoat-back.onrender.com:3001", { autoConnect: true });

export default socket;
