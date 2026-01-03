<template>
  <div class="min-h-screen bg-gray-50 flex items-center justify-center p-4">
    <div class="w-full max-w-md bg-white border border-gray-200 rounded-2xl shadow-xl shadow-gray-200/50 overflow-hidden">
      
      <div class="p-8 space-y-8">
        <div class="text-center">
          <div class="inline-flex items-center justify-center w-12 h-12 rounded-full bg-emerald-100 text-emerald-700 ring-4 ring-emerald-50 mb-4 animate-bounce">
            <Users :size="24" />
          </div>
          <h1 class="text-2xl font-bold text-gray-900">Rejoindre une séance</h1>
          <p class="text-gray-500 text-sm mt-1">Entrez le code fourni par votre enseignant.</p>
        </div>

        <form @submit.prevent="handleJoin" class="space-y-6">
          
          <div class="space-y-2">
            <label class="text-sm font-bold text-gray-700">Code de la salle</label>
            <input 
              v-model="roomCode" 
              type="text" 
              class="w-full bg-gray-50 border border-gray-300 rounded-lg px-4 py-3 text-gray-900 placeholder-gray-400 focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 font-mono uppercase tracking-widest text-center text-lg shadow-sm"
              placeholder="XXX-00"
              required
            />
          </div>
          
          <!-- Recent Names Suggestions -->
          <div v-if="savedNames.length > 0" class="space-y-2">
             <p class="text-xs font-bold text-gray-500 uppercase tracking-wide">C'est toi ?</p>
             <div class="flex flex-wrap gap-2">
                <button 
                  v-for="name in savedNames" 
                  :key="name"
                  type="button"
                  @click="useName(name)"
                  class="bg-emerald-50 hover:bg-emerald-100 text-emerald-700 border border-emerald-200 px-3 py-1.5 rounded-full text-sm font-semibold transition-colors active:scale-95"
                >
                  {{ name }}
                </button>
             </div>
          </div>

          <div class="space-y-3">
            <label class="text-sm font-bold text-gray-700">Membres du groupe</label>
            <div class="space-y-2">
               <input 
                 v-model="groupNames[0]" 
                 type="text" 
                 class="w-full bg-gray-50 border border-gray-300 rounded-lg px-4 py-3 text-gray-900 placeholder-gray-400 focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 shadow-sm"
                 placeholder="Prénom élève 1"
                 required
               />
               <input 
                 v-model="groupNames[1]" 
                 type="text" 
                 class="w-full bg-gray-50 border border-gray-300 rounded-lg px-4 py-3 text-gray-900 placeholder-gray-400 focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 shadow-sm"
                 placeholder="Prénom élève 2"
               />
               <input 
                 v-model="groupNames[2]" 
                 type="text" 
                 class="w-full bg-gray-50 border border-gray-300 rounded-lg px-4 py-3 text-gray-900 placeholder-gray-400 focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 shadow-sm"
                 placeholder="Prénom élève 3"
               />
               <input 
                 v-model="groupNames[3]" 
                 type="text" 
                 class="w-full bg-gray-50 border border-gray-300 rounded-lg px-4 py-3 text-gray-900 placeholder-gray-400 focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 shadow-sm"
                 placeholder="Prénom élève 4"
               />
            </div>
          </div>

          <div v-if="error" class="bg-red-50 border border-red-100 rounded-lg p-3 flex items-start text-red-600 text-sm">
            <AlertCircle :size="16" class="mr-2 mt-0.5 flex-shrink-0" />
            <span>{{ error }}</span>
          </div>

          <button 
            type="submit" 
            class="w-full bg-emerald-700 hover:bg-emerald-800 text-white font-bold py-4 rounded-xl shadow-lg shadow-emerald-700/20 transform transition-all active:scale-95 flex items-center justify-center"
            :disabled="loading"
          >
            <Loader2 v-if="loading" :size="20" class="animate-spin mr-2" />
            Commencer l'entraînement !
          </button>
        </form>

         <div class="text-center">
            <router-link to="/" class="text-gray-400 hover:text-gray-600 text-sm transition-colors font-medium">
              Annuler
            </router-link>
          </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { supabase } from '../../supabase'
import { useStudentStore } from '../../stores/student'
import { Users, AlertCircle, Loader2 } from 'lucide-vue-next'

const roomCode = ref('')
const groupNames = ref(['', '', '', '']) // 4 slots
const error = ref('')
const loading = ref(false)
const savedNames = ref([])
const router = useRouter()
const studentStore = useStudentStore()

onMounted(() => {
  try {
    const history = localStorage.getItem('muscu_recent_names')
    if (history) {
      const parsed = JSON.parse(history)
      if (Array.isArray(parsed)) {
        // Deduplicate loaded history
        const unique = []
        const seen = new Set()
        for (const name of parsed) {
          const lower = name.toLowerCase()
          if (!seen.has(lower)) {
            seen.add(lower)
            unique.push(name)
          }
        }
        savedNames.value = unique.slice(0, 5)
      }
    }
  } catch (e) {
    console.error("Error loading history", e)
    localStorage.removeItem('muscu_recent_names')
  }
})

const useName = (name) => {
  // Find first empty slot or overwrite first
  const emptyIndex = groupNames.value.findIndex(n => n.trim() === '')
  if (emptyIndex !== -1) {
    groupNames.value[emptyIndex] = name
  } else {
    groupNames.value[0] = name
  }
}

const handleJoin = async () => {
  console.log("handleJoin called")
  console.log("Group Names:", groupNames.value)
  
  error.value = ''
  loading.value = true
  
  try {
    // Combine names
    const validNames = groupNames.value.map(n => n.trim()).filter(n => n.length > 0)
    console.log("Valid Names:", validNames)

    if (validNames.length === 0) {
      console.log("Validation failed: no names")
      throw new Error("Veuillez entrer au moins un prénom.")
    }
    const finalName = validNames.join(' & ')
    console.log("Final Name:", finalName)

    console.log("Checking room code:", roomCode.value.toUpperCase())
    const { data: room, error: roomError } = await supabase
      .from('rooms')
      .select('id, is_active')
      .eq('code', roomCode.value.toUpperCase())
      .single()

    console.log("Room check result:", room, roomError)

    if (roomError || !room) throw new Error("Code salle invalide.")
    if (!room.is_active) throw new Error("Cette salle n'est plus active.")

    // Check for duplicate names / Re-login logic
    console.log("Checking for duplicates/re-login...")
    const { data: existingStudents, error: fetchError } = await supabase
      .from('students')
      .select('id, name')
      .eq('room_id', room.id)

    if (fetchError) throw fetchError

    let existingStudentId = null
    let student = null
    const inputNamesSet = new Set(validNames.map(n => n.toLowerCase()))
    
    if (existingStudents) {
      for (const s of existingStudents) {
        const sNames = s.name.split(' & ').map(n => n.trim().toLowerCase())
        
        // Exact Match (Re-login)
        const isExactMatch = sNames.length === validNames.length && sNames.every(n => inputNamesSet.has(n))
        
        if (isExactMatch) {
          console.log("Exact match found! Logging in existing student:", s.name)
          existingStudentId = s.id
          student = s
          break 
        }

        // Partial Conflict
        const intersection = sNames.filter(n => inputNamesSet.has(n))
        if (intersection.length > 0) {
           throw new Error(`${intersection[0]} est déjà inscrit dans le groupe "${s.name}". Tu ne peux pas changer de groupe.`)
        }
      }
    }

    if (!existingStudentId) {
       // Create new
       console.log("Creating new student...")
       const { data: newStudent, error: createError } = await supabase
        .from('students')
        .insert([{ 
          room_id: room.id, 
          name: finalName,
          score: 0
        }])
        .select()
        .single()
        
       if (createError) throw new Error("Impossible de rejoindre la salle.")
       student = newStudent
    }

    if (!student) throw new Error("Erreur inattendue lors de la connexion.")

    studentStore.login({
      id: student.id,
      name: student.name,
      roomId: room.id
    })
    
    // Save names to local history (deduplicated)
    const oldHistory = JSON.parse(localStorage.getItem('muscu_recent_names') || '[]')
    const uniqueNames = []
    const seen = new Set()
    
    // Priority to new names
    for (const name of validNames) {
      const lower = name.toLowerCase()
      if (!seen.has(lower)) {
        seen.add(lower)
        uniqueNames.push(name)
      }
    }
    // Then old history
    for (const name of oldHistory) {
      const lower = name.toLowerCase()
      if (!seen.has(lower)) {
        seen.add(lower)
        uniqueNames.push(name)
      }
    }
    
    const newHistory = uniqueNames.slice(0, 5)
    localStorage.setItem('muscu_recent_names', JSON.stringify(newHistory))

    console.log("Redirecting to room...")
    await router.push(`/student/room/${room.id}`)

  } catch (e) {
    console.error("Error in handleJoin:", e)
    error.value = e.message || "Une erreur est survenue."
  } finally {
    loading.value = false
  }
}
</script>
