<template>
  <div class="space-y-6 animate-in fade-in duration-500">
    <div>
      <h2 class="text-2xl font-bold text-gray-900">Gestion de Classe</h2>
      <p class="text-gray-500 mt-1">Consultez les carnets d'entraînement de vos élèves.</p>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
      
      <!-- Student List -->
      <div class="bg-white border border-gray-200 rounded-xl shadow-sm overflow-hidden flex flex-col h-[calc(100vh-200px)]">
         <div class="p-4 border-b border-gray-200 bg-gray-50">
            <h3 class="font-bold text-gray-700 flex items-center">
              <Users :size="18" class="mr-2" />
              Élèves
            </h3>
         </div>
         <div class="overflow-y-auto flex-1 p-2 custom-scrollbar">
            <div v-if="loadingStudents" class="flex justify-center py-8">
               <Loader2 :size="24" class="animate-spin text-emerald-600" />
            </div>
            <div v-else-if="students.length === 0" class="text-center py-8 text-gray-400 text-sm">
               Aucun élève trouvé.
            </div>
            <div 
              v-else 
              v-for="student in students" 
              :key="student.name"
              class="flex items-center justify-between group hover:bg-gray-50 rounded-lg transition-colors"
            >
              <button 
                @click="selectStudent(student)"
                class="flex-1 text-left px-4 py-3 flex items-center justify-between"
                :class="selectedStudentName === student.name ? 'bg-emerald-50 rounded-l-lg' : ''"
              >
                 <span class="font-medium text-gray-800">{{ student.name }}</span>
                 <ChevronRight :size="16" class="text-gray-400 group-hover:text-emerald-600" />
              </button>
              <button 
                @click.stop="deleteStudent(student)"
                class="p-2 text-gray-400 hover:text-red-500 hover:bg-red-50 rounded-r-lg opacity-0 group-hover:opacity-100 transition-all"
                title="Supprimer l'élève"
              >
                 <Trash2 :size="16" />
              </button>
            </div>
         </div>
      </div>

      <!-- Detail View -->
      <div class="lg:col-span-2 space-y-6">
         
         <div v-if="!selectedStudentName" class="bg-white border border-gray-200 rounded-xl p-12 text-center h-full flex flex-col items-center justify-center text-gray-400">
            <BookOpen :size="48" class="mb-4 text-gray-200" />
            <p>Sélectionnez un élève pour voir son historique.</p>
         </div>

         <div v-else>
            <!-- Sessions List for Selected Student -->
            <div class="bg-white border border-gray-200 rounded-xl p-6 mb-6">
               <h3 class="font-bold text-xl text-gray-900 mb-4 flex items-center">
                 <User :size="20" class="mr-2 text-emerald-600" />
                 {{ selectedStudentName }}
               </h3>
               
               <div class="flex space-x-2 overflow-x-auto pb-2 custom-scrollbar">
                  <button 
                    v-for="session in studentSessions" 
                    :key="session.id"
                    @click="loadNotebook(session)"
                    class="px-4 py-2 rounded-lg border text-sm whitespace-nowrap transition-all"
                    :class="selectedSession?.id === session.id 
                       ? 'bg-emerald-600 text-white border-emerald-600 shadow-md' 
                       : 'bg-white border-gray-200 text-gray-600 hover:border-emerald-300 hover:text-emerald-600'"
                  >
                     <span class="font-bold mr-1">{{ session.rooms?.name || 'Leçon' }}</span>
                     <span class="opacity-75">({{ session.rooms?.code }})</span> - {{ new Date(session.created_at).toLocaleDateString() }}
                  </button>
               </div>
            </div>

            <!-- Notebook Display -->
            <div v-if="selectedSession" class="bg-white border border-gray-200 rounded-xl overflow-hidden shadow-sm animate-in slide-in-from-bottom-4 duration-300">
               <div class="p-4 border-b border-gray-200 bg-gray-50 flex justify-between items-center">
                  <h4 class="font-bold text-gray-700">Carnet de la séance</h4>
                  <div class="text-sm text-gray-500">Coach: <span class="font-bold text-gray-900">{{ globalCoachName || 'Non renseigné' }}</span></div>
               </div>
               
               <div class="overflow-x-auto">
                  <table class="w-full text-sm text-left">
                     <thead class="text-xs text-gray-700 uppercase bg-gray-50 border-b border-gray-100">
                        <tr>
                           <th class="px-4 py-3">Atelier</th>
                           <th v-if="roomConfig?.notebook_visible_series" class="px-4 py-3 text-center">Série</th>
                           <th class="px-4 py-3 text-center">Niveau</th>
                           <th v-if="roomConfig?.notebook_visible_charges" class="px-4 py-3 text-center">Charges</th>
                           <th v-if="roomConfig?.notebook_visible_reps" class="px-4 py-3 text-center">Reps</th>
                           <th class="px-4 py-3 text-center">Placement</th>
                           <th class="px-4 py-3 text-center">Tempo</th>
                           <th class="px-4 py-3 text-center">Respiration</th>
                           <th class="px-4 py-3 text-center">Ressentis</th>
                        </tr>
                     </thead>
                     <tbody class="divide-y divide-gray-100">
                        <tr v-for="entry in notebookData" :key="entry.id" class="hover:bg-gray-50">
                           <td class="px-4 py-3 font-medium text-gray-900">
                              {{ entry.workshops?.exercise?.name || 'Atelier inconnu' }}
                           </td>
                           <!-- Série -->
                           <td v-if="roomConfig?.notebook_visible_series" class="px-4 py-3 text-center">
                              <span class="bg-purple-100 text-purple-700 px-2 py-0.5 rounded text-xs font-bold">{{ entry.series_number || 1 }}</span>
                           </td>
                           <!-- Niveau -->
                           <td class="px-4 py-3 text-center">
                              <template v-if="roomConfig?.notebook_visible_level !== false">
                                 <span v-if="entry.level_selected" class="bg-blue-100 text-blue-800 px-2 py-0.5 rounded text-xs font-bold">{{ entry.level_selected }}</span>
                                 <span v-else class="text-gray-400">--</span>
                              </template>
                              <span v-else class="text-gray-300">--</span>
                           </td>
                           <!-- Charges -->
                           <td v-if="roomConfig?.notebook_visible_charges" class="px-4 py-3 text-center">
                              <span v-if="entry.charge" class="font-medium">{{ entry.charge }} kg</span>
                              <span v-else class="text-gray-400">--</span>
                           </td>
                           <!-- Répétitions -->
                           <td v-if="roomConfig?.notebook_visible_reps" class="px-4 py-3 text-center">
                              <span v-if="entry.repetitions" class="font-medium">{{ entry.repetitions }}</span>
                              <span v-else class="text-gray-400">--</span>
                           </td>
                           <td class="px-4 py-3 text-center">
                              <template v-if="roomConfig?.notebook_visible_placement !== false">
                                 <span v-if="entry.placement_errors != null" :class="Number(entry.placement_errors) === 0 ? 'text-emerald-600 font-bold' : 'text-red-600 font-bold'">
                                    {{ Number(entry.placement_errors) === 0 ? 'BON' : 'PAS BON' }}
                                 </span>
                                 <span v-else class="text-gray-400">--</span>
                              </template>
                              <span v-else class="text-gray-300">--</span>
                           </td>
                           <td class="px-4 py-3 text-center">
                              <template v-if="roomConfig?.notebook_visible_tempo !== false">
                                 <span v-if="entry.tempo_errors != null" :class="Number(entry.tempo_errors) === 0 ? 'text-emerald-600 font-bold' : 'text-red-600 font-bold'">
                                    {{ Number(entry.tempo_errors) === 0 ? 'BON' : 'PAS BON' }}
                                 </span>
                                 <span v-else class="text-gray-400">--</span>
                              </template>
                              <span v-else class="text-gray-300">--</span>
                           </td>
                           <td class="px-4 py-3 text-center">
                              <template v-if="roomConfig?.notebook_visible_respiration !== false">
                                 <span v-if="entry.respiration_errors != null" :class="Number(entry.respiration_errors) === 0 ? 'text-emerald-600 font-bold' : 'text-red-600 font-bold'">
                                    {{ Number(entry.respiration_errors) === 0 ? 'BON' : 'PAS BON' }}
                                 </span>
                                 <span v-else class="text-gray-400">--</span>
                              </template>
                              <span v-else class="text-gray-300">--</span>
                           </td>
                           <td class="px-4 py-3 text-center">
                              <template v-if="roomConfig?.notebook_visible_feeling !== false">
                                 <span v-if="entry.feeling" 
                                   class="px-2 py-1 rounded text-xs font-bold"
                                   :class="{
                                     'bg-emerald-100 text-emerald-800': entry.feeling <= 2,
                                     'bg-amber-100 text-amber-800': entry.feeling >= 3 && entry.feeling <= 4,
                                     'bg-red-100 text-red-800': entry.feeling == 5
                                   }"
                                 >
                                   {{ entry.feeling }}/5
                                 </span>
                                 <span v-else class="text-gray-400">--</span>
                              </template>
                              <span v-else class="text-gray-300">--</span>
                           </td>
                        </tr>
                        <tr v-if="notebookData.length === 0">
                           <td colspan="9" class="px-4 py-8 text-center text-gray-500 italic">Aucune donnée saisie pour cette séance.</td>
                        </tr>
                     </tbody>
                  </table>
               </div>
            </div>
            
            <!-- Coaching History -->
            <div v-if="Object.keys(coachedByPerformer).length > 0" class="mt-8 animate-in slide-in-from-bottom-8 duration-500">
               <h3 class="font-bold text-lg text-gray-800 mb-4 flex items-center">
                  <Users :size="20" class="mr-2 text-indigo-600" />
                  Coaching réalisé par {{ selectedStudentName }}
               </h3>
               
               <div class="grid grid-cols-1 gap-6">
                  <div v-for="(entries, performerName) in coachedByPerformer" :key="performerName" class="bg-white border border-gray-200 rounded-xl overflow-hidden shadow-sm">
                     <div class="p-3 bg-indigo-50 border-b border-indigo-100 flex justify-between items-center">
                        <span class="font-bold text-indigo-900">{{ performerName }}</span>
                        <span class="text-xs font-medium bg-indigo-100 text-indigo-700 px-2 py-0.5 rounded-full">{{ entries.length }} ateliers</span>
                     </div>
                     <table class="w-full text-sm text-left">
                        <thead class="text-xs text-indigo-700 uppercase bg-indigo-50 border-b border-indigo-100">
                           <tr>
                              <th class="px-3 py-2">Atelier</th>
                              <th v-if="roomConfig?.notebook_visible_series" class="px-3 py-2 text-center">Série</th>
                              <th class="px-3 py-2 text-center">Niveau</th>
                              <th v-if="roomConfig?.notebook_visible_charges" class="px-3 py-2 text-center">Charges</th>
                              <th v-if="roomConfig?.notebook_visible_reps" class="px-3 py-2 text-center">Reps</th>
                              <th class="px-3 py-2 text-center">Placement</th>
                              <th class="px-3 py-2 text-center">Tempo</th>
                              <th class="px-3 py-2 text-center">Respiration</th>
                              <th class="px-3 py-2 text-center">Ressentis</th>
                           </tr>
                        </thead>
                        <tbody class="divide-y divide-gray-100">
                           <tr v-for="entry in entries" :key="entry.id" class="hover:bg-indigo-50/30">
                              <td class="px-3 py-2 text-gray-700 font-medium text-xs truncate max-w-[150px]">
                                 {{ entry.workshops?.exercise?.name || 'Inconnu' }}
                              </td>
                              <!-- Série -->
                              <td v-if="roomConfig?.notebook_visible_series" class="px-3 py-2 text-center">
                                 <span class="bg-indigo-100 text-indigo-700 px-2 py-0.5 rounded text-xs font-bold">{{ entry.series_number || 1 }}</span>
                              </td>
                              <!-- Niveau -->
                              <td class="px-3 py-2 text-center">
                                 <template v-if="roomConfig?.notebook_visible_level !== false">
                                    <span v-if="entry.level_selected" class="bg-indigo-100 text-indigo-800 px-2 py-0.5 rounded text-xs font-bold">{{ entry.level_selected }}</span>
                                    <span v-else class="text-gray-400 text-xs">--</span>
                                 </template>
                                 <span v-else class="text-gray-300 text-xs">--</span>
                              </td>
                              <!-- Charges -->
                              <td v-if="roomConfig?.notebook_visible_charges" class="px-3 py-2 text-center">
                                 <span v-if="entry.charge" class="font-medium text-xs">{{ entry.charge }} kg</span>
                                 <span v-else class="text-gray-400 text-xs">--</span>
                              </td>
                              <!-- Répétitions -->
                              <td v-if="roomConfig?.notebook_visible_reps" class="px-3 py-2 text-center">
                                 <span v-if="entry.repetitions" class="font-medium text-xs">{{ entry.repetitions }}</span>
                                 <span v-else class="text-gray-400 text-xs">--</span>
                              </td>
                              <td class="px-3 py-2 text-center">
                                 <template v-if="roomConfig?.notebook_visible_placement !== false">
                                    <span v-if="entry.placement_errors != null" :class="Number(entry.placement_errors) === 0 ? 'text-emerald-600 font-bold' : 'text-red-600 font-bold'">
                                       {{ Number(entry.placement_errors) === 0 ? 'BON' : 'PAS BON' }}
                                    </span>
                                    <span v-else class="text-gray-400 text-xs">--</span>
                                 </template>
                                 <span v-else class="text-gray-300 text-xs">--</span>
                              </td>
                              <td class="px-3 py-2 text-center">
                                 <template v-if="roomConfig?.notebook_visible_tempo !== false">
                                    <span v-if="entry.tempo_errors != null" :class="Number(entry.tempo_errors) === 0 ? 'text-emerald-600 font-bold' : 'text-red-600 font-bold'">
                                       {{ Number(entry.tempo_errors) === 0 ? 'BON' : 'PAS BON' }}
                                    </span>
                                    <span v-else class="text-gray-400 text-xs">--</span>
                                 </template>
                                 <span v-else class="text-gray-300 text-xs">--</span>
                              </td>
                              <td class="px-3 py-2 text-center">
                                 <template v-if="roomConfig?.notebook_visible_respiration !== false">
                                    <span v-if="entry.respiration_errors != null" :class="Number(entry.respiration_errors) === 0 ? 'text-emerald-600 font-bold' : 'text-red-600 font-bold'">
                                       {{ Number(entry.respiration_errors) === 0 ? 'BON' : 'PAS BON' }}
                                    </span>
                                    <span v-else class="text-gray-400 text-xs">--</span>
                                 </template>
                                 <span v-else class="text-gray-300 text-xs">--</span>
                              </td>
                              <td class="px-3 py-2 text-center">
                                 <template v-if="roomConfig?.notebook_visible_feeling !== false">
                                    <span v-if="entry.feeling" class="font-bold text-xs"
                                      :class="{
                                        'text-emerald-600': entry.feeling <= 2,
                                        'text-amber-600': entry.feeling >= 3 && entry.feeling <= 4,
                                        'text-red-600': entry.feeling == 5
                                      }"
                                    >
                                      {{ entry.feeling }}/5
                                    </span>
                                    <span v-else class="text-gray-300">--</span>
                                 </template>
                                 <span v-else class="text-gray-300 text-xs">--</span>
                              </td>
                           </tr>
                        </tbody>
                     </table>
                  </div>
               </div>
            </div>


             
             <!-- Teacher Notes -->
             <div v-if="selectedSession" class="mt-8 animate-in slide-in-from-bottom-8 duration-500 delay-100 pb-20">
                <h3 class="font-bold text-lg text-gray-800 mb-4 flex items-center">
                   <BookOpen :size="20" class="mr-2 text-emerald-600" />
                   Notes de l'enseignant
                </h3>
                
                <div class="bg-white border border-gray-200 rounded-xl p-4 shadow-sm">
                   <label class="block text-sm font-bold text-gray-700 mb-2">
                     Observations pour cette séance
                   </label>
                   <textarea
                     v-model="selectedSession.teacher_note"
                     rows="4"
                     class="w-full bg-gray-50 border border-gray-300 rounded-lg p-3 text-sm focus:outline-none focus:ring-2 focus:ring-emerald-500 resize-none mb-3"
                     placeholder="Notes privées sur l'élève (comportement, progrès, points à surveiller...)"
                   ></textarea>
                   <div class="flex justify-end">
                      <button 
                        @click="saveTeacherNote"
                        class="bg-emerald-600 text-white px-4 py-2 rounded-lg font-bold text-sm hover:bg-emerald-700 transition-colors flex items-center shadow-sm"
                      >
                         <Check :size="16" class="mr-2" />
                         Enregistrer la note
                      </button>
                   </div>
                </div>
             </div>
             
          </div>
       </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onActivated, computed } from 'vue'
import { supabase } from '../../supabase'
import { Users, ChevronRight, Loader2, BookOpen, User, Check, Trash2 } from 'lucide-vue-next'

const loadingStudents = ref(true)
const students = ref([]) // List of unique names
const selectedStudentName = ref(null)
const studentSessions = ref([])
const selectedSession = ref(null)
const notebookData = ref([])
const coachedData = ref([])
const roomConfig = ref(null) // Config from the room for column visibility

const coachedByPerformer = computed(() => {
  if (coachedData.value.length === 0) return {}
  return coachedData.value.reduce((acc, entry) => {
    const performer = entry.performer_name || 'Inconnu'
    if (!acc[performer]) acc[performer] = []
    acc[performer].push(entry)
    return acc
  }, {})
})

const globalCoachName = computed(() => {
   if (notebookData.value.length > 0) return notebookData.value[0].coach_name
   return null
})

const fetchStudents = async () => {
  loadingStudents.value = true
  const { data, error } = await supabase
    .from('students')
    .select('name')
    .order('name')

  if (error) {
    console.error('Error fetching students:', error)
  } else if (data) {
     const nameSet = new Set()
     data.forEach(row => {
        row.name.split(' & ').forEach(n => nameSet.add(n.trim()))
     })
     students.value = Array.from(nameSet).sort().map(n => ({ name: n }))
  }
  loadingStudents.value = false
}

const selectStudent = async (student) => {
   selectedStudentName.value = student.name
   selectedSession.value = null
   notebookData.value = []
   coachedData.value = []

   // Fetch all student rows that contain this name (exact or as part of a group)
   const { data, error } = await supabase
      .from('students')
      .select('id, room_id, created_at, teacher_note, name, rooms(code, name, notebook_visible_level, notebook_visible_placement, notebook_visible_tempo, notebook_visible_respiration, notebook_visible_feeling, notebook_visible_series, notebook_visible_charges, notebook_visible_reps)')
      .ilike('name', `%${student.name}%`)
      .order('created_at', { ascending: false })

   if (error) {
      console.error('Error fetching student sessions:', error)
      return
   }

   if (data) {
      // Filter client-side to ensure exact name match (not partial like "Jean" matching "Jean-Pierre")
      studentSessions.value = data.filter(row => {
        const names = row.name.split(' & ').map(n => n.trim())
        return names.includes(student.name.trim())
      })
   }
}

const loadNotebook = async (session) => {
   selectedSession.value = { ...session } // Copy to avoid mutating the original
   notebookData.value = []
   coachedData.value = []

   // Use room config from session (already loaded with students)
   if (session.rooms) {
      roomConfig.value = {
         notebook_visible_level: session.rooms.notebook_visible_level,
         notebook_visible_placement: session.rooms.notebook_visible_placement,
         notebook_visible_tempo: session.rooms.notebook_visible_tempo,
         notebook_visible_respiration: session.rooms.notebook_visible_respiration,
         notebook_visible_feeling: session.rooms.notebook_visible_feeling,
         notebook_visible_series: session.rooms.notebook_visible_series,
         notebook_visible_charges: session.rooms.notebook_visible_charges,
         notebook_visible_reps: session.rooms.notebook_visible_reps
      }
   } else {
      // Default all visible if no config found
      roomConfig.value = {
         notebook_visible_level: true,
         notebook_visible_placement: true,
         notebook_visible_tempo: true,
         notebook_visible_respiration: true,
         notebook_visible_feeling: true,
         notebook_visible_series: true,
         notebook_visible_charges: true,
         notebook_visible_reps: true
      }
   }
   
   const { data } = await supabase
      .from('notebook_entries')
      .select('*, workshops(id, exercise:exercises(name))')
      .eq('student_id', session.id)
      .eq('performer_name', selectedStudentName.value)
      
   if (data) notebookData.value = data
   
   // Fetch data where student acted as COACH
   const { data: coachData } = await supabase
      .from('notebook_entries')
      .select('*, workshops(id, exercise:exercises(name))')
      .eq('student_id', session.id)
      .eq('coach_name', selectedStudentName.value)
      
   if (coachData) coachedData.value = coachData
}

const saveTeacherNote = async () => {
  if (!selectedSession.value) return
  
  const { error } = await supabase
    .from('students')
    .update({ teacher_note: selectedSession.value.teacher_note })
    .eq('id', selectedSession.value.id)
    
  if (error) {
     alert("Erreur lors de l'enregistrement : " + error.message)
  } else {
     // Optional: show toast or brief success feedback
  }
}

const deleteStudent = async (student) => {
   if (!confirm(`Supprimer l'élève "${student.name}" ?\n\nCela supprimera toutes ses données (carnets d'entraînement, notes, etc.) de toutes les séances.\n\nCette action est irréversible.`)) return

   // Delete all notebook entries where this student is performer or coach
   // Use proper quoting for names with special characters
   const safeName = student.name.replace(/"/g, '\\"')
   const { error: notebookError } = await supabase
     .from('notebook_entries')
     .delete()
     .or(`performer_name.eq."${safeName}",coach_name.eq."${safeName}"`)

   if (notebookError) {
      alert("Erreur lors de la suppression des carnets : " + notebookError.message)
      return
   }

   // Delete/update student entries matching this name
   const { data: strategies, error: fetchError } = await supabase
      .from('students')
      .select('*')
      .ilike('name', `%${student.name}%`)

   if (fetchError) {
      alert("Erreur lors de la recherche des entrées : " + fetchError.message)
      return
   }

   if (strategies) {
      for (const row of strategies) {
         const names = row.name.split(' & ')
         if (!names.map(n => n.trim()).includes(student.name.trim())) continue

         const newNames = names.filter(n => n.trim() !== student.name.trim())

         if (newNames.length === 0) {
            const { error: delErr } = await supabase.from('students').delete().eq('id', row.id)
            if (delErr) console.error('Error deleting student row:', delErr)
         } else {
            const { error: updErr } = await supabase.from('students').update({
               name: newNames.join(' & ')
            }).eq('id', row.id)
            if (updErr) console.error('Error updating student row:', updErr)
         }
      }
   }

   // Refresh the list and clear selection
   if (selectedStudentName.value === student.name) {
      selectedStudentName.value = null
      studentSessions.value = []
      selectedSession.value = null
      notebookData.value = []
      coachedData.value = []
   }
   await fetchStudents()
}

onMounted(fetchStudents)
onActivated(fetchStudents)
</script>
