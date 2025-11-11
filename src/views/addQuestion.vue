<script setup>
import { ref, onMounted } from "vue";
import { useRouter } from "vue-router";
import socket from "@/socket";

const router = useRouter();

const loading = ref(true);
const topics = ref([]);
const types = ref([]);
const selectedTopic = ref("");
const selectedType = ref("");
const questionText = ref("");
const desc = ref("");
const imageLink = ref("");
const options = ref(["", "", "", ""]); 
const response = ref("");
const error = ref("");

onMounted(() => {
  socket.emit("getTopicsAndTypes");
  socket.on("topicsAndTypes", (data) => {
    topics.value = data.topics || [];
    types.value = data.types || [];
    loading.value = false;
  });
});

function addOption() {
  options.value.push("");
}
function removeOption(index) {
  options.value.splice(index, 1);
}

function sendQuestion() {
  if (!questionText.value || !selectedType.value || !selectedTopic.value) {
    error.value = "Veuillez remplir tous les champs obligatoires.";
    return;
  }

  if (selectedType.value.label === "qcm") {
    if (!options.value.includes(response.value)) {
      error.value = "La réponse doit être l'une des options proposées.";
      return;
    }     
    if (!response.value) {
      error.value = "Veuillez indiquer la bonne réponse.";
      return;
    }
  } else if (selectedType.value.label === "open") {
    response.value = "1";
  }

  const questionData = {
    question: questionText.value,
    options: options.value,
    response: response.value,
    desc: desc.value,
    topic: selectedTopic.value,
    type: selectedType.value,
    image_link: imageLink.value || null,
  };

  //console.log("Données de la question à envoyer :", questionData);

  socket.emit("addQuestion", questionData, (res) => {
    if (res?.success) {
      router.push("/add-question");
      alert("Question ajoutée avec succès !");
    } else {
      alert("Erreur lors de l'ajout de la question.");
    }
  });
}
</script>

<template>
  <div class="p-6 max-w-xl mx-auto">
    <h1 class="text-2xl font-bold mb-4">Ajouter une question</h1>

    <div v-if="loading" class="text-gray-500">Chargement des topics...</div>

    <form
      v-else
      @submit.prevent="sendQuestion"
      class="space-y-4 bg-white p-4 rounded-xl shadow"
    >
      <div>
        <label class="block font-semibold">Question :</label>
        <input
          v-model="questionText"
          type="text"
          required
          class="w-full border rounded p-2"
        />
      </div>

      <div>
        <label class="block font-semibold">Description (facultatif) :</label>
        <textarea v-model="desc" class="w-full border rounded p-2" />
      </div>

      <div>
        <label class="block font-semibold">Lien image (facultatif) :</label>
        <input v-model="imageLink" type="text" class="w-full border rounded p-2" />
      </div>

      <div>
        <label class="block font-semibold">Sujet :</label>
        <select v-model="selectedTopic" required class="w-full border rounded p-2">
          <option value="" disabled>Choisir un sujet</option>
          <option v-for="topic in topics" :key="topic" :value="topic">
            {{ topic.label }}
          </option>
        </select>
      </div>

      <div>
        <label class="block font-semibold">Type :</label>
        <select v-model="selectedType" required class="w-full border rounded p-2">
          <option value="" disabled>Choisir un type</option>
          <option v-for="type in types" :key="type" :value="type">{{ type.label }}</option>
        </select>
      </div>

      <div v-if="selectedType.label === 'qcm'">
        <label class="block font-semibold mb-2">Options (4 fixes) :</label>
        <div
          v-for="(opt, i) in options.slice(0, 4)"
          :key="i"
          class="flex items-center gap-2 mb-2"
        >
          <span class="font-semibold w-5">{{ i + 1 }}.</span>
          <input
            v-model="options[i]"
            type="text"
            placeholder="Option"
            class="flex-1 border rounded p-2"
            required
          />
        </div>
      </div>

      <div v-else-if="selectedType.label === 'open'">
        <label class="block font-semibold mb-2">Propositions possibles :</label>
        <div
          v-for="(opt, i) in options"
          :key="i"
          class="flex items-center gap-2 mb-2"
        >
          <input
            v-model="options[i]"
            type="text"
            placeholder="Proposition"
            class="flex-1 border rounded p-2"
          />
          <button
            type="button"
            @click="removeOption(i)"
            class="px-2 py-1 bg-red-500 text-white rounded"
            v-if="options.length > 1"
          >
            ✕
          </button>
        </div>
        <button
          type="button"
          class="px-3 py-1 bg-green-500 text-white rounded"
          @click="addOption"
        >
          + Ajouter une option
        </button>
      </div>

      <div v-if="selectedType.label === 'qcm'">
        <label class="block font-semibold">
          Bonne réponse :
        </label>
        <input
          v-model="response"
          type="text"
          required
          class="w-full border rounded p-2"
        />
      </div>

      <p v-if="error" class="text-red-500">{{ error }}</p>

      <button
        type="submit"
        class="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700"
      >
        Enregistrer la question
      </button>
    </form>
  </div>
</template>

<style scoped>
body {
  background-color: #f8fafc;
}
</style>
