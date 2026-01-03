<template>
  <div class="space-y-6">
    <div class="flex justify-between items-end">
      <div>
        <h2 class="text-2xl font-bold text-gray-900">Banque d'Exercices</h2>
        <p class="text-gray-500 text-sm mt-1">Gérez la bibliothèque d'exercices disponibles pour vos ateliers.</p>
      </div>
      <button 
        @click="showAddModal = true"
        class="bg-emerald-700 hover:bg-emerald-600 text-white px-4 py-2 rounded-lg font-bold flex items-center transition-all shadow-lg shadow-emerald-700/20 active:scale-95"
      >
        <Plus :size="18" class="mr-2" />
        Nouvel Exercice
      </button>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="flex justify-center py-12">
      <Loader2 :size="32" class="animate-spin text-emerald-600" />
    </div>

    <!-- Empty State -->
    <div v-else-if="exercises.length === 0" class="bg-white border border-gray-200 rounded-xl p-12 text-center shadow-sm">
      <div class="bg-gray-100 w-16 h-16 rounded-full flex items-center justify-center mx-auto mb-4">
        <Dumbbell :size="32" class="text-gray-400" />
      </div>
      <h3 class="text-lg font-semibold text-gray-900">Aucun exercice</h3>
      <p class="text-gray-500 mt-2 mb-6">Commencez par ajouter des exercices à votre banque.</p>
    </div>

    <!-- Grid -->
    <div v-else class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
      <div 
        v-for="exercise in exercises" 
        :key="exercise.id"
        class="bg-white border border-gray-200 rounded-xl overflow-hidden hover:border-emerald-500/50 hover:shadow-lg transition-all group"
      >
        <div class="aspect-video bg-gray-100 relative overflow-hidden text-gray-400 flex items-center justify-center">
          <img 
            v-if="exercise.image_url" 
            :src="exercise.image_url" 
            :alt="exercise.name"
            class="w-full h-full object-contain p-2 bg-white transition-transform group-hover:scale-105" 
          />
          <ImageIcon v-else :size="32" />
          
          <!-- Actions Overlay -->
          <div class="absolute inset-0 bg-black/40 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center space-x-2">
            <button @click="openEditModal(exercise)" class="bg-white/90 hover:bg-emerald-500 text-emerald-600 hover:text-white p-2 rounded-full backdrop-blur-sm transition-all shadow-xl">
              <Pencil :size="18" />
            </button>
            <button @click="deleteExercise(exercise.id)" class="bg-white/90 hover:bg-red-500 text-red-500 hover:text-white p-2 rounded-full backdrop-blur-sm transition-all shadow-xl">
              <Trash2 :size="18" />
            </button>
          </div>
        </div>
        <div class="p-4 border-t border-gray-100">
          <h3 class="font-bold text-gray-900 truncate">{{ exercise.name }}</h3>
        </div>
      </div>
    </div>

    <!-- Add/Edit Modal -->
    <div v-if="showAddModal" class="fixed inset-0 z-50 flex items-center justify-center px-4 bg-black/40 backdrop-blur-sm">
      <div class="bg-white rounded-2xl w-full max-w-lg max-h-[90vh] overflow-y-auto p-6 shadow-2xl space-y-6 animate-in zoom-in-95 duration-200">
        <div class="flex justify-between items-center border-b border-gray-100 pb-4">
          <h3 class="text-xl font-bold text-gray-900">{{ isEditing ? 'Modifier' : 'Ajouter' }} un exercice</h3>
          <button @click="closeModal" class="text-gray-400 hover:text-gray-600">
            <X :size="24" />
          </button>
        </div>

        <form @submit.prevent="handleSubmit" class="space-y-4">
          <!-- Tabs Header -->
          <div class="flex space-x-1 bg-gray-100 p-1 rounded-lg mb-6">
            <button 
              type="button" 
              @click="activeTab = 'general'"
              :class="['flex-1 py-2 text-sm font-medium border-b-2 transition-colors', activeTab === 'general' ? 'border-emerald-500 text-emerald-700' : 'border-transparent text-gray-400 hover:text-gray-600']"
            >
              Général
            </button>
            <button 
              type="button" 
              @click="activeTab = 'levels'"
              :class="['flex-1 py-2 text-sm font-medium border-b-2 transition-colors', activeTab === 'levels' ? 'border-emerald-500 text-emerald-700' : 'border-transparent text-gray-400 hover:text-gray-600']"
            >
              Niveaux
            </button>
            <button 
              type="button" 
              @click="activeTab = 'placement'"
              :class="['flex-1 py-2 text-sm font-medium border-b-2 transition-colors', activeTab === 'placement' ? 'border-emerald-500 text-emerald-700' : 'border-transparent text-gray-400 hover:text-gray-600']"
            >
              Placement
            </button>
            <button 
              type="button" 
              @click="activeTab = 'respiration'"
              :class="['flex-1 py-2 text-sm font-medium border-b-2 transition-colors', activeTab === 'respiration' ? 'border-emerald-500 text-emerald-700' : 'border-transparent text-gray-400 hover:text-gray-600']"
            >
              Respiration
            </button>
            <button 
              type="button" 
              @click="activeTab = 'tempo'"
              :class="['flex-1 py-2 text-sm font-medium border-b-2 transition-colors', activeTab === 'tempo' ? 'border-emerald-500 text-emerald-700' : 'border-transparent text-gray-400 hover:text-gray-600']"
            >
              Tempo
            </button>
          </div>

          <!-- Tab: General -->
          <div v-show="activeTab === 'general'" class="space-y-4">
            <div>
              <label class="block text-sm font-bold text-gray-700 mb-1">Nom de l'exercice</label>
              <input 
                v-model="newExercise.name" 
                type="text" 
                class="w-full bg-gray-50 border border-gray-300 rounded-lg px-4 py-2 text-gray-900 focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500"
                placeholder="Ex: Développé Couché"
                required
              />
            </div>
            
            <div>
              <label class="block text-sm font-bold text-gray-700 mb-2">Image de l'exercice</label>
              
              <div 
                @dragover.prevent="isDragging = true"
                @dragleave.prevent="isDragging = false"
                @drop.prevent="handleDrop"
                @click="triggerFileInput"
                class="border-2 border-dashed rounded-xl p-8 text-center cursor-pointer transition-all duration-200 group relative overflow-hidden"
                :class="[
                  isDragging ? 'border-emerald-500 bg-emerald-50' : 'border-gray-300 hover:border-emerald-400 hover:bg-gray-50',
                  uploadError ? 'border-red-300 bg-red-50' : ''
                ]"
              >
                <input 
                  type="file" 
                  ref="fileInput" 
                  accept="image/*" 
                  class="hidden" 
                  @change="handleFileSelect"
                />

                <div v-if="uploading" class="flex flex-col items-center justify-center py-4">
                   <Loader2 :size="32" class="animate-spin text-emerald-600 mb-2" />
                   <p class="text-sm text-gray-500">Téléchargement...</p>
                </div>

                <div v-else-if="newExercise.image_url" class="relative group-hover:opacity-100">
                   <img :src="newExercise.image_url" class="max-h-48 mx-auto rounded-lg shadow-sm" />
                   <div class="absolute inset-0 bg-black/40 opacity-0 group-hover:opacity-100 flex items-center justify-center transition-opacity rounded-lg">
                      <p class="text-white font-bold text-sm">Changer l'image</p>
                   </div>
                </div>

                <div v-else class="space-y-2 py-4">
                  <div class="w-12 h-12 bg-emerald-100 text-emerald-600 rounded-full flex items-center justify-center mx-auto mb-2 group-hover:scale-110 transition-transform">
                    <UploadCloud :size="24" />
                  </div>
                  <p class="text-gray-900 font-medium">Cliquez ou glissez une image ici</p>
                  <p class="text-xs text-gray-500">PNG, JPG, WEBP jusqu'à 5MB</p>
                </div>
              </div>

              <div class="mt-4 relative">
                <div class="absolute inset-0 flex items-center">
                  <div class="w-full border-t border-gray-200"></div>
                </div>
                <div class="relative flex justify-center text-sm">
                  <span class="px-2 bg-white text-gray-500">Ou via URL</span>
                </div>
              </div>

              <input 
                v-model="newExercise.image_url" 
                type="url" 
                class="mt-4 w-full bg-gray-50 border border-gray-300 rounded-lg px-4 py-2 text-gray-900 text-sm focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 placeholder-gray-400"
                placeholder="https://..."
              />
              <p v-if="uploadError" class="text-red-500 text-xs mt-2 font-medium flex items-center justify-center">
                 {{ uploadError }}
              </p>
            </div>

            <!-- Video Section -->
            <div class="border-t border-gray-100 pt-6">
              <label class="block text-sm font-bold text-gray-700 mb-2">Vidéo de l'exercice (Optionnel)</label>
              
              <div 
                @dragover.prevent="isDraggingVideo = true"
                @dragleave.prevent="isDraggingVideo = false"
                @drop.prevent="handleVideoDrop"
                @click="triggerVideoInput"
                class="border-2 border-dashed rounded-xl p-8 text-center cursor-pointer transition-all duration-200 group relative overflow-hidden"
                :class="[
                  isDraggingVideo ? 'border-emerald-500 bg-emerald-50' : 'border-gray-300 hover:border-emerald-400 hover:bg-gray-50',
                  uploadVideoError ? 'border-red-300 bg-red-50' : ''
                ]"
              >
                <input 
                  type="file" 
                  ref="videoInput" 
                  accept="video/*" 
                  class="hidden" 
                  @change="handleVideoSelect"
                />

                <div v-if="uploadingVideo" class="flex flex-col items-center justify-center py-4">
                   <Loader2 :size="32" class="animate-spin text-emerald-600 mb-2" />
                   <p class="text-sm text-gray-500">Téléchargement de la vidéo...</p>
                </div>

                <div v-else-if="newExercise.video_url && !newExercise.video_url.includes('youtube')" class="relative group-hover:opacity-100">
                   <div class="flex flex-col items-center">
                      <div class="w-16 h-16 bg-emerald-100 rounded-full flex items-center justify-center mb-2">
                        <Video :size="32" class="text-emerald-600" />
                      </div>
                      <p class="text-emerald-700 font-bold text-sm">Vidéo importée avec succès</p>
                      <p class="text-xs text-emerald-600/70 truncate max-w-xs">{{ newExercise.video_url.split('/').pop() }}</p>
                   </div>
                   <div class="absolute inset-0 bg-white/80 opacity-0 group-hover:opacity-100 flex items-center justify-center transition-opacity rounded-lg backdrop-blur-sm">
                      <p class="text-emerald-700 font-bold text-sm">Changer la vidéo</p>
                   </div>
                </div>

                <div v-else class="space-y-2 py-4">
                  <div class="w-12 h-12 bg-emerald-100 text-emerald-600 rounded-full flex items-center justify-center mx-auto mb-2 group-hover:scale-110 transition-transform">
                    <Video :size="24" />
                  </div>
                  <p class="text-gray-900 font-medium">Cliquez ou glissez une vidéo ici</p>
                  <p class="text-xs text-gray-500">MP4, MOV, WEBM jusqu'à 50MB</p>
                </div>
              </div>

              <div class="mt-4 relative">
                <div class="absolute inset-0 flex items-center">
                  <div class="w-full border-t border-gray-200"></div>
                </div>
                <div class="relative flex justify-center text-sm">
                  <span class="px-2 bg-white text-gray-500">Ou lien YouTube</span>
                </div>
              </div>

              <div class="mt-4 relative">
                 <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                    <Youtube :size="18" class="text-red-500" />
                 </div>
                <input 
                  v-model="newExercise.video_url" 
                  type="url" 
                  class="w-full bg-gray-50 border border-gray-300 rounded-lg pl-10 pr-4 py-2 text-gray-900 text-sm focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 placeholder-gray-400"
                  placeholder="https://www.youtube.com/watch?v=..."
                />
              </div>
              <p v-if="uploadVideoError" class="text-red-500 text-xs mt-2 font-medium flex items-center justify-center">
                 {{ uploadVideoError }}
              </p>
            </div>

            <!-- Muscles Configuration -->
            <div class="grid grid-cols-1 sm:grid-cols-3 gap-4 border-t border-gray-100 pt-4">
               <div v-for="(label, key) in { muscle_primary: 'Principal (10pts)', muscle_secondary: 'Secondaire (5pts)', muscle_tertiary: 'Tertiaire (3pts)' }" :key="key">
                  <label class="block text-xs font-bold text-gray-500 uppercase tracking-wider mb-2">{{ label }}</label>
                  <select v-model="newExercise[key]" class="w-full bg-gray-50 border border-gray-300 rounded-lg px-3 py-2 text-gray-900 text-sm focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 outline-none">
                    <option value="" disabled>Choisir...</option>
                    <option v-for="m in muscleList" :key="m" :value="m">{{ m }}</option>
                  </select>
               </div>
            </div>
          </div>

          <!-- Tab: Niveaux -->
          <div v-show="activeTab === 'levels'" class="space-y-4">
            <div class="bg-blue-50 text-blue-800 p-4 rounded-lg text-sm mb-4">
              Ce contenu sera visible par l'élève <strong>avant et pendant</strong> l'exercice.
            </div>
            <div>
              <label class="block text-sm font-bold text-gray-700 mb-2">Description des Niveaux</label>
              <textarea 
                v-model="newExercise.levels" 
                rows="8"
                class="w-full bg-gray-50 border border-gray-300 rounded-lg px-4 py-2 text-gray-900 focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 resize-none"
                placeholder="Niveau 1 : ...&#10;Niveau 2 : ..."
              ></textarea>
            </div>
          </div>

          <!-- Tab: Placement -->
          <div v-show="activeTab === 'placement'" class="space-y-4">
            <div class="bg-amber-50 text-amber-800 p-4 rounded-lg text-sm mb-4">
              Ce contenu ne sera visible par l'élève qu'une fois l'exercice <strong>validé</strong>, si l'option est activée lors de la création de l'atelier.
            </div>
            <div>
              <label class="block text-sm font-bold text-gray-700 mb-2">Consignes de Placement</label>
              <textarea 
                v-model="newExercise.placement" 
                rows="8"
                class="w-full bg-gray-50 border border-gray-300 rounded-lg px-4 py-2 text-gray-900 focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 resize-none"
                placeholder="Détails sur le placement correct..."
              ></textarea>
            </div>
          </div>

          <!-- Tab: Respiration -->
          <div v-show="activeTab === 'respiration'" class="space-y-4">
            <div class="bg-amber-50 text-amber-800 p-4 rounded-lg text-sm mb-4">
              Ce contenu ne sera visible par l'élève qu'une fois l'exercice <strong>validé</strong>, si l'option est activée lors de la création de l'atelier.
            </div>
            <div>
              <label class="block text-sm font-bold text-gray-700 mb-2">Consignes de Respiration</label>
              <textarea 
                v-model="newExercise.respiration" 
                rows="8"
                class="w-full bg-gray-50 border border-gray-300 rounded-lg px-4 py-2 text-gray-900 focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 resize-none"
                placeholder="Quand inspirer, quand expirer..."
              ></textarea>
            </div>
          </div>

          <!-- Tab: Tempo -->
          <div v-show="activeTab === 'tempo'" class="space-y-4">
            <div class="bg-amber-50 text-amber-800 p-4 rounded-lg text-sm mb-4">
              Ce contenu ne sera visible par l'élève qu'une fois l'exercice <strong>validé</strong>, si l'option est activée lors de la création de l'atelier.
            </div>
            <div>
              <label class="block text-sm font-bold text-gray-700 mb-2">Consignes de Tempo</label>
              <textarea 
                v-model="newExercise.tempo" 
                rows="8"
                class="w-full bg-gray-50 border border-gray-300 rounded-lg px-4 py-2 text-gray-900 focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 resize-none"
                placeholder="Ex: 3 secondes de descente, 1 seconde de montée..."
              ></textarea>
            </div>
          </div>

          <div class="pt-4 flex justify-end space-x-3 border-t border-gray-100 mt-2">
            <button 
              type="button" 
              @click="closeModal"
              class="px-4 py-2 rounded-lg text-gray-600 hover:bg-gray-100 transition-colors font-medium"
            >
              Annuler
            </button>
            <button 
              type="submit" 
              class="bg-emerald-700 hover:bg-emerald-800 text-white px-6 py-2 rounded-lg font-bold flex items-center shadow-md shadow-emerald-700/20"
              :disabled="submitting"
            >
              <Loader2 v-if="submitting" :size="16" class="animate-spin mr-2" />
              {{ isEditing ? 'Enregistrer' : 'Ajouter' }}
            </button>
          </div>
        </form>
      </div>
    </div>

  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { supabase } from '../../../supabase'
import { MUSCLE_LIST } from '../../../constants/muscles'
import { Plus, Loader2, Dumbbell, Trash2, Image as ImageIcon, X, UploadCloud, Pencil, Video, Youtube } from 'lucide-vue-next'

const exercises = ref([])
const loading = ref(true)
const showAddModal = ref(false)
const submitting = ref(false)
const muscleList = MUSCLE_LIST

// Edit State
const isEditing = ref(false)
const editingId = ref(null)

// Upload State
const fileInput = ref(null)
const isDragging = ref(false)
const uploading = ref(false)
const uploadError = ref('')
const videoInput = ref(null)
const isDraggingVideo = ref(false)
const uploadingVideo = ref(false)
const uploadVideoError = ref('')

const newExercise = ref({
  name: '',
  image_url: '',
  muscle_primary: '',
  muscle_secondary: '',
  muscle_tertiary: '',
  levels: '',
  placement: '',
  placement: '',
  placement: '',
  respiration: '',
  tempo: '',
  video_url: ''
})

const activeTab = ref('general')
const tabs = [
  { id: 'general', label: 'Général' },
  { id: 'levels', label: 'Niveaux' },
  { id: 'placement', label: 'Placement' },
  { id: 'respiration', label: 'Respiration' }
]

const fetchExercises = async () => {
  loading.value = true
  const { data, error } = await supabase
    .from('exercises')
    .select('*')
    .order('created_at', { ascending: false })
  
  if (error) console.error(error)
  else exercises.value = data
  loading.value = false
}

// Upload Logic (unchanged)
const triggerFileInput = () => fileInput.value.click()

const handleFileSelect = async (event) => {
  const file = event.target.files[0]
  if (file) await uploadFile(file)
}

const handleDrop = async (event) => {
  isDragging.value = false
  const file = event.dataTransfer.files[0]
  if (file) await uploadFile(file)
}

const uploadFile = async (file) => {
  if (!file.type.startsWith('image/')) {
    uploadError.value = "Format invalide. Choisissez une image."
    return
  }
  
  uploading.value = true
  uploadError.value = ''
  
  const fileExt = file.name.split('.').pop()
  const fileName = `${Date.now()}-${Math.random().toString(36).substring(2, 10)}.${fileExt}`
  const filePath = `${fileName}`

  const { data, error } = await supabase.storage
    .from('exercises')
    .upload(filePath, file)

  if (error) {
    uploadError.value = "Erreur upload: " + error.message
    console.error(error)
  } else {
    const { data: { publicUrl } } = supabase.storage
      .from('exercises')
      .getPublicUrl(filePath)
      
    newExercise.value.image_url = publicUrl
  }
  uploading.value = false
}

// Video Upload Logic
const triggerVideoInput = () => videoInput.value.click()

const handleVideoSelect = async (event) => {
  const file = event.target.files[0]
  if (file) await uploadVideo(file)
}

const handleVideoDrop = async (event) => {
  isDraggingVideo.value = false
  const file = event.dataTransfer.files[0]
  if (file) await uploadVideo(file)
}

const uploadVideo = async (file) => {
  if (!file.type.startsWith('video/')) {
    uploadVideoError.value = "Format invalide. Choisissez une vidéo."
    return
  }
  
  // Max size check (e.g. 50MB)
  if (file.size > 50 * 1024 * 1024) {
    uploadVideoError.value = "La vidéo est trop volumineuse (Max 50MB)."
    return
  }

  uploadingVideo.value = true
  uploadVideoError.value = ''
  
  const fileExt = file.name.split('.').pop()
  const fileName = `video-${Date.now()}-${Math.random().toString(36).substring(2, 10)}.${fileExt}`
  const filePath = `${fileName}`

  const { data, error } = await supabase.storage
    .from('exercises')
    .upload(filePath, file)

  if (error) {
    uploadVideoError.value = "Erreur upload: " + error.message
    console.error(error)
  } else {
    const { data: { publicUrl } } = supabase.storage
      .from('exercises')
      .getPublicUrl(filePath)
      
    newExercise.value.video_url = publicUrl
  }
  uploadingVideo.value = false
}

const closeModal = () => {
  showAddModal.value = false
  isEditing.value = false
  editingId.value = null
  newExercise.value = { 
    name: '', 
    image_url: '', 
    muscle_primary: '', 
    muscle_secondary: '', 
    muscle_tertiary: '',
    levels: '',
    placement: '',
    respiration: '',
    levels: '',
    placement: '',
    placement: '',
    respiration: '',
    tempo: '',
    video_url: ''
  }
  activeTab.value = 'general'
}

const openEditModal = (exercise) => {
  isEditing.value = true
  editingId.value = exercise.id
  newExercise.value = { ...exercise }
  showAddModal.value = true
}

const handleSubmit = () => {
  if (isEditing.value) updateExercise()
  else addExercise()
}

const addExercise = async () => {
  submitting.value = true
  const { data, error } = await supabase
    .from('exercises')
    .insert([newExercise.value])
    .select()

  if (error) {
    console.error(error)
    alert("Erreur lors de l'ajout")
  } else {
    exercises.value.unshift(data[0])
    closeModal()
  }
  submitting.value = false
}

const updateExercise = async () => {
  submitting.value = true
  const { data, error } = await supabase
    .from('exercises')
    .update(newExercise.value)
    .eq('id', editingId.value)
    .select()

  if (error) {
    console.error(error)
    alert("Erreur lors de la modification")
  } else {
    const index = exercises.value.findIndex(e => e.id === editingId.value)
    if (index !== -1) exercises.value[index] = data[0]
    closeModal()
  }
  submitting.value = false
}

const deleteExercise = async (id) => {
  if (!confirm('Êtes-vous sûr de vouloir supprimer cet exercice ?')) return

  const { error } = await supabase
    .from('exercises')
    .delete()
    .eq('id', id)

  if (error) {
    console.error(error)
    if (error.code === '23503') {
      alert("Cet exercice est utilisé dans un ou plusieurs ateliers. Vous ne pouvez pas le supprimer tant qu'il est lié à un atelier.")
    } else {
      alert("Erreur lors de la suppression: " + error.message)
    }
  } else {
    exercises.value = exercises.value.filter(e => e.id !== id)
  }
}

onMounted(fetchExercises)
</script>
