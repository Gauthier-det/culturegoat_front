import { io } from "socket.io-client";

const socket = io("https://localhost:3001", { autoConnect: true });

export default socket;
