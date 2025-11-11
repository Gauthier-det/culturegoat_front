<script setup>
import { ref, onMounted } from "vue";
import { useRouter } from "vue-router";
import socket from "@/socket";

const router = useRouter();

const questions = ref([]);

onMounted(() => {
  socket.emit("getTempQuestions");

  socket.on("tempQuestions", (data) => {
    questions.value = data
  })

  socket.on("questionValidated", (id) => {
    questions.value = questions.value.filter(q => q.id !== id)
  })

  socket.on("questionDeleted", (id) => {
    questions.value = questions.value.filter(q => q.id !== id)
  })
})

function accept(id) {
  socket.emit("validateQuestion", id)
}

function reject(id) {
  socket.emit("deleteQuestion", id)
}
</script>


<template>
  <div class="p-6">
    <h2 class="text-xl font-bold mb-4">📝 Validation des questions en attente</h2>
    <div v-if="questions.length === 0" class="text-gray-500">Aucune question en attente</div>

    <div v-for="q in questions" :key="q.id" class="p-4 mb-4 border rounded shadow bg-white">
      <h3 class="font-semibold">{{ q.question }}</h3>
      <p class="text-sm text-gray-600">{{ q.desc }}</p>
      <p><b>Type :</b> {{ q.type.label }}</p>
      <p><b>Topic :</b> {{ q.topic.label }}</p>

      <ul v-if="q.options.length > 0" class="list-disc ml-6 my-2">
        <li v-for="opt in q.options" :key="opt" :class="{'text-green-600 font-bold': opt === q.response}">
          {{ opt }}
        </li>
      </ul>

      <div class="flex gap-2 mt-3">
        <button @click="accept(q.id)" class="bg-green-500 text-white px-3 py-1 rounded hover:bg-green-600">✅ Accepter</button>
        <button @click="reject(q.id)" class="bg-red-500 text-white px-3 py-1 rounded hover:bg-red-600">❌ Rejeter</button>
      </div>
    </div>
  </div>
</template>

