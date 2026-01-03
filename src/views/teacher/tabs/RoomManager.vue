<template>
  <div class="space-y-6">
    <div class="flex justify-between items-end">
      <div>
        <h2 class="text-2xl font-bold text-gray-900">Leçons</h2>
        <p class="text-gray-500 text-sm mt-1">Créez et gérez vos leçons actives.</p>
      </div>
      <button 
        @click="createRoom"
        class="bg-emerald-700 hover:bg-emerald-800 text-white px-4 py-2 rounded-lg font-bold flex items-center transition-all shadow-lg shadow-emerald-700/20 active:scale-95"
        :disabled="creating"
      >
        <component :is="creating ? Loader2 : Plus" :size="18" :class="creating ? 'animate-spin mr-2' : 'mr-2'" />
        Créer une leçon
      </button>
    </div>

    <!-- Active Rooms List -->
    <div v-if="loading" class="flex justify-center py-12">
       <Loader2 :size="32" class="animate-spin text-emerald-600" />
    </div>

    <div v-else-if="rooms.length === 0" class="bg-white border border-gray-200 rounded-xl p-12 text-center shadow-sm">
      <div class="bg-gray-100 w-16 h-16 rounded-full flex items-center justify-center mx-auto mb-4">
        <LayoutDashboard :size="32" class="text-gray-400" />
      </div>
      <h3 class="text-lg font-semibold text-gray-900">Aucune leçon active</h3>
      <p class="text-gray-500 mt-2">Cliquez sur "Créer une leçon" pour démarrer une nouvelle session.</p>
    </div>

    <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
       <div 
        v-for="room in rooms" 
        :key="room.id"
        class="bg-white border border-gray-200 rounded-xl p-6 hover:border-emerald-500 transition-all group flex flex-col justify-between shadow-sm hover:shadow-md"
       >
         <div>
          <div>
            <div class="flex items-center justify-between mb-2">
              <h3 class="font-bold text-gray-900 truncate pr-2" :title="room.name">{{ room.name || 'Leçon sans nom' }}</h3>
              <span class="text-gray-400 text-xs flex items-center font-medium whitespace-nowrap">
                 <Clock :size="12" class="mr-1" />
                 {{ new Date(room.created_at).toLocaleDateString() }}
              </span>
            </div>
            <div class="inline-block bg-emerald-100 text-emerald-800 px-3 py-1 rounded-lg font-mono font-bold text-lg border border-emerald-200 mb-4">
              {{ room.code }}
            </div>
            <p class="text-gray-500 text-sm mb-4">
              Code à partager aux élèves.
            </p>
         </div>
         </div>
         
         <div class="flex space-x-2 pt-4 border-t border-gray-100">
           <button 
             @click="$router.push(`/teacher/room/${room.id}`)"
             class="flex-1 bg-gray-50 hover:bg-gray-100 text-gray-700 border border-gray-200 py-2 rounded-lg text-sm font-semibold transition-colors"
           >
             Gérer / ateliers
           </button>
           <button 
             @click="duplicateRoom(room.id)"
             class="px-3 bg-blue-50 hover:bg-blue-100 text-blue-600 border border-blue-100 rounded-lg transition-colors"
             title="Dupliquer la leçon"
             :disabled="duplicatingId === room.id"
           >
             <Loader2 v-if="duplicatingId === room.id" :size="16" class="animate-spin" />
             <Copy v-else :size="16" />
           </button>
           <button 
            @click="deleteRoom(room.id)"
            class="px-3 bg-red-50 hover:bg-red-100 text-red-600 border border-red-100 rounded-lg transition-colors"
            title="Supprimer la salle"
           >
             <Trash2 :size="16" />
           </button>
         </div>
       </div>
    </div>
     
     <!-- Create Room Modal -->
     <div v-if="showCreateModal" class="fixed inset-0 z-50 flex items-center justify-center px-4 bg-black/40 backdrop-blur-sm">
      <div class="bg-white rounded-2xl w-full max-w-md p-6 shadow-2xl animate-in zoom-in-95 duration-200">
        <div class="flex justify-between items-center mb-6 border-b border-gray-100 pb-4">
          <h3 class="text-xl font-bold text-gray-900">Nouvelle Leçon</h3>
          <button @click="closeCreateModal" class="text-gray-400 hover:text-gray-600">
            <X :size="24" />
          </button>
        </div>

        <form @submit.prevent="confirmCreateRoom" class="space-y-6">
          <div>
            <label class="block text-sm font-bold text-gray-700 mb-1">Nom de la leçon</label>
            <input 
              v-model="newRoomName"
              type="text" 
              class="w-full bg-gray-50 border border-gray-300 rounded-lg px-4 py-3 text-gray-900 focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500"
              placeholder="Ex: Cycle Force - Séance 1"
              autofocus
            />
          </div>

          <div class="flex justify-end space-x-3 pt-2">
            <button 
              type="button" 
              @click="closeCreateModal"
              class="px-4 py-2 text-gray-700 font-bold bg-gray-100 hover:bg-gray-200 rounded-lg transition-colors"
            >
              Annuler
            </button>
            <button 
              type="submit"
              :disabled="!newRoomName || creating" 
              class="px-6 py-2 bg-emerald-600 text-white font-bold rounded-lg hover:bg-emerald-700 transition-colors disabled:opacity-50 disabled:cursor-not-allowed flex items-center"
            >
              <Loader2 v-if="creating" class="animate-spin mr-2" :size="18" />
              Créer
            </button>
          </div>
        </form>
      </div>
     </div>
   </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { supabase } from '../../../supabase'

import { Plus, LayoutDashboard, Loader2, Trash2, Clock, X, Copy } from 'lucide-vue-next'

const rooms = ref([])
const loading = ref(true)
const creating = ref(false)
const duplicatingId = ref(null)
const showCreateModal = ref(false)
const newRoomName = ref('')
const router = useRouter()

const fetchRooms = async () => {
  loading.value = true
  const { data, error } = await supabase
    .from('rooms')
    .select('*')
    .eq('is_active', true)
    .order('created_at', { ascending: false })
  
  if (data) rooms.value = data
  loading.value = false
}

const generateCode = () => {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ' 
  const randomChar = () => chars[Math.floor(Math.random() * chars.length)]
  const num = Math.floor(Math.random() * 90) + 10 
  return `${randomChar()}${randomChar()}${randomChar()}${num}`
}

const createRoom = () => {
  newRoomName.value = ''
  showCreateModal.value = true
}

const closeCreateModal = () => {
  showCreateModal.value = false
  newRoomName.value = ''
}

const confirmCreateRoom = async () => {
  if (!newRoomName.value) return

  creating.value = true
  const code = generateCode()
  
  const { data, error } = await supabase
    .from('rooms')
    .insert([{ code, is_active: true, name: newRoomName.value }])
    .select()
    .single()

  if (error) {
    alert("Erreur: " + error.message)
    creating.value = false
  } else {
    // Redirect immediately
    router.push(`/teacher/room/${data.id}`)
    // Modal will be closed by navigation/unmount
  }
}

const deleteRoom = async (id) => {
  if (!confirm('Supprimer cette leçon ? Cela déconnectera les élèves.')) return
  
  const { error } = await supabase.from('rooms').delete().eq('id', id)
  if (!error) {
    rooms.value = rooms.value.filter(r => r.id !== id)
  }
}

const duplicateRoom = async (fromId) => {
  const original = rooms.value.find(r => r.id === fromId)
  if (!original) return

  if (!confirm(`Dupliquer la leçon "${original.name}" ?`)) return

  duplicatingId.value = fromId

  try {
    // 1. Create New Room
    const code = generateCode()
    const newName = `${original.name} (Copie)`
    
    const { data: newRoom, error: roomError } = await supabase
      .from('rooms')
      .insert([{ 
        code, 
        is_active: true, 
        name: newName,
        timer_config: original.timer_config // Copy timer config if exists
      }])
      .select()
      .single()

    if (roomError) throw roomError

    // 2. Fetch Original Workshops
    const { data: workshops, error: wsError } = await supabase
      .from('workshops')
      .select('*')
      .eq('room_id', fromId)
    
    if (wsError) throw wsError

    if (workshops && workshops.length > 0) {
      // 3. Prepare New Workshops Payload
      // Remove ID, created_at, etc. and update room_id
      const newWorkshops = workshops.map(w => {
        const { id, created_at, ...rest } = w
        return { ...rest, room_id: newRoom.id }
      })

      const { error: copyError } = await supabase
        .from('workshops')
        .insert(newWorkshops)
      
      if (copyError) throw copyError
    }

    // Refresh list
    await fetchRooms()

  } catch (e) {
    console.error("Duplication failed:", e)
    alert("Erreur lors de la duplication: " + e.message)
  } finally {
    duplicatingId.value = null
  }
}

onMounted(fetchRooms)
</script>
