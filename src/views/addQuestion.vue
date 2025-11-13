<script setup>
import { ref, onMounted, watch } from "vue";
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
const connected = ref(false);
const createurPassword = ref("");
const CREATE_PASS = import.meta.env.VITE_CREATE_PASS;

onMounted(() => {
  checkAuth();
  socket.emit("getTopicsAndTypes");
  socket.on("topicsAndTypes", (data) => {
    topics.value = data.topics || [];
    types.value = data.types || [];
    loading.value = false;
  });
});

watch(selectedType, (newType) => {
  if (!newType) return;

  if (newType.label === "qcm") {
    const firstFour = options.value.slice(0, 4).map(v => v || ""); 
    while (firstFour.length < 4) firstFour.push(""); 
    options.value = firstFour;

    if (!options.value.includes(response.value)) response.value = "";
  }

  if (newType.label === "open") {
    const cleaned = options.value.map(v => v || "").filter(v => v.trim() !== "");
    options.value = cleaned.length ? cleaned : [""];
    response.value = "1"; 
  }
});

function addOption() {
  if (selectedType.value && selectedType.value.label === "open") {
    options.value.push("");
  }
}
function removeOption(index) {
  options.value.splice(index, 1);
  if (selectedType.value && selectedType.value.label === "open" && options.value.length === 0) {
    options.value.push("");
  }
}

function sendQuestion() {
  if (!questionText.value || !selectedType.value || !selectedTopic.value) {
    error.value = "Veuillez remplir tous les champs obligatoires.";
    return;
  }
  if (!selectedType == "Choisir un type" ) {
    error.value = "Veuillez sélectionner un type de question.";
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
    if(options.value.length != 4){
        error.value = "Veuillez entrer le bon nombre de réponses"
        return;
    }
    for (let opt of options.value) {
      if (!opt || opt.trim() === "") {
        error.value = "Veuillez remplir toutes les options.";
        return;
      }
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
      alert("Question ajoutée avec succès !");
      selectedTopic.value = "";
      selectedType.value = "";
      questionText.value = "";
      desc.value = "";
      imageLink.value = "";
      options.value = ["", "", "", ""];
      response.value = "";
    } else {
      alert("Erreur lors de l'ajout de la question.");
    }
  });
}

function checkAuth(){
  if(sessionStorage.getItem("creaValue")){
    if(sessionStorage.getItem("creaValue") === "1"){
      connected.value = true;
      return;
    }
  }
  if(createurPassword.value === ""){
    return;
  }
  if(createurPassword.value === CREATE_PASS){
    sessionStorage.setItem("creaValue", "1");
    connected.value = true;
  } else {
    alert("Mot de passe incorrect");
  }
}

</script>

<template>
  <div class="p-6" v-if="!connected">

    <form @submit.prevent="checkAuth">
      <h2 class="text-xl font-bold mb-4">🔐 Authentification créateur de question</h2>
      <div class="mb-4">
        <input type="text" name="username" autocomplete="username" style="display:none"/>
        <label for="createurPassword" class="block text-gray-700 mb-2">Mot de passe :</label>
        <input type="password" id="createurPassword" v-model="createurPassword" class="w-full p-2 border rounded" autocomplete="new-password" required />
      </div>
      <button type="submit" class="bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600">Se connecter</button>
    </form>
  </div>

  <div class="p-6 max-w-xl mx-auto" v-if="connected">
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
        <textarea v-model="desc" class="w-full border rounded p-2"/>
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
