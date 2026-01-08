<template>
  <div class="min-h-screen bg-gray-50 p-4 md:p-8">
    
    <!-- Header -->
    <div class="max-w-4xl mx-auto mb-6 md:mb-8 flex flex-col md:flex-row items-stretch md:items-center justify-between gap-4">
      <div class="flex items-center space-x-3 md:space-x-4 flex-1">
        <button @click="$router.back()" class="bg-white border border-gray-200 p-2 rounded-lg text-gray-500 hover:text-gray-900 transition-colors shadow-sm shrink-0">
          <ArrowLeft :size="20" />
        </button>
        <div class="flex-1 min-w-0">
          <div class="flex items-center flex-wrap gap-2">
             <div v-if="isEditingName" class="flex items-center space-x-2 w-full max-w-md">
                <input 
                  v-model="editedRoomName" 
                  ref="nameInput"
                  @keyup.enter="saveRoomName"
                  @keyup.esc="cancelEditName"
                  class="text-xl md:text-3xl font-bold text-gray-900 bg-white border border-emerald-300 rounded px-2 py-1 outline-none focus:ring-2 focus:ring-emerald-500 w-full"
                />
                <button @click="saveRoomName" class="bg-emerald-600 text-white p-2 rounded-lg hover:bg-emerald-700">
                   <Check :size="20" />
                </button>
                <button @click="cancelEditName" class="bg-gray-200 text-gray-600 p-2 rounded-lg hover:bg-gray-300">
                   <X :size="20" />
                </button>
             </div>
             <h1 v-else class="text-2xl md:text-3xl font-bold text-gray-900 flex items-center group cursor-pointer truncate" @click="startEditName">
               <span class="truncate">{{ roomName || 'Leçon' }}</span>
               <button class="ml-2 md:ml-3 text-gray-400 group-hover:text-emerald-600 transition-colors opacity-100 md:opacity-0 md:group-hover:opacity-100 shrink-0">
                  <Pencil :size="16" class="md:w-5 md:h-5" />
               </button>
               <span class="bg-emerald-100 text-emerald-800 px-2 py-0.5 md:px-3 md:py-1 rounded-lg ml-2 md:ml-3 text-lg md:text-2xl font-mono border border-emerald-200 cursor-default shrink-0" @click.stop>{{ roomCode }}</span>
             </h1>
          </div>
          <p class="text-gray-500 text-xs md:text-sm mt-1 truncate">Configurez les ateliers de cette séance.</p>
        </div>
      </div>
      
      <button 
        @click="showAddModal = true"
        class="bg-emerald-700 hover:bg-emerald-800 text-white px-4 py-3 rounded-lg font-bold flex items-center justify-center shadow-lg shadow-emerald-700/20 active:scale-95 transition-all w-full md:w-auto"
      >
        <Plus :size="20" class="mr-2" />
        Ajouter un atelier
      </button>
    </div>

    <!-- Navigation Tabs -->
    <div class="max-w-4xl mx-auto mb-6 flex overflow-x-auto space-x-2 md:space-x-1 bg-white p-1 rounded-xl border border-gray-200 shadow-sm no-scrollbar">
      <button 
        @click="activeTab = 'workshops'"
        class="flex-1 py-2.5 px-3 md:px-4 rounded-lg font-bold text-sm flex items-center justify-center transition-all whitespace-nowrap shrink-0"
        :class="activeTab === 'workshops' ? 'bg-emerald-50 text-emerald-700 shadow-sm ring-1 ring-emerald-200' : 'text-gray-500 hover:bg-gray-50 hover:text-gray-900'"
      >
        <Dumbbell :size="18" class="mr-2" />
        Ateliers
      </button>
      <button 
        @click="activeTab = 'attendance'"
        class="flex-1 py-2.5 px-3 md:px-4 rounded-lg font-bold text-sm flex items-center justify-center transition-all whitespace-nowrap shrink-0"
        :class="activeTab === 'attendance' ? 'bg-emerald-50 text-emerald-700 shadow-sm ring-1 ring-emerald-200' : 'text-gray-500 hover:bg-gray-50 hover:text-gray-900'"
      >
        <Users :size="18" class="mr-2" />
        Appel
        <span v-if="students.length > 0" class="ml-2 bg-emerald-200 text-emerald-800 text-xs px-2 py-0.5 rounded-full">{{ students.length }}</span>
      </button>
      <button 
        @click="activeTab = 'timer'"
        class="flex-1 py-2.5 px-3 md:px-4 rounded-lg font-bold text-sm flex items-center justify-center transition-all whitespace-nowrap shrink-0"
        :class="activeTab === 'timer' ? 'bg-emerald-50 text-emerald-700 shadow-sm ring-1 ring-emerald-200' : 'text-gray-500 hover:bg-gray-50 hover:text-gray-900'"
      >
        <Clock :size="18" class="mr-2" />
        Chrono
      </button>
      <button 
        @click="activeTab = 'ranking'"
        class="flex-1 py-2.5 px-3 md:px-4 rounded-lg font-bold text-sm flex items-center justify-center transition-all whitespace-nowrap shrink-0"
        :class="activeTab === 'ranking' ? 'bg-emerald-50 text-emerald-700 shadow-sm ring-1 ring-emerald-200' : 'text-gray-500 hover:bg-gray-50 hover:text-gray-900'"
      >
        <Trophy :size="18" class="mr-2" />
        Classement
      </button>
      <button 
        @click="activeTab = 'config'"
        class="flex-1 py-2.5 px-3 md:px-4 rounded-lg font-bold text-sm flex items-center justify-center transition-all whitespace-nowrap shrink-0"
        :class="activeTab === 'config' ? 'bg-emerald-50 text-emerald-700 shadow-sm ring-1 ring-emerald-200' : 'text-gray-500 hover:bg-gray-50 hover:text-gray-900'"
      >
        <Settings :size="18" class="mr-2" />
        Config
      </button>
    </div>

    <!-- Content -->
    <div class="max-w-4xl mx-auto space-y-6">
      
      <!-- Workshops Tab -->
      <div v-if="activeTab === 'workshops'">
        <div v-if="workshops.length === 0" class="bg-white border border-gray-200 rounded-2xl p-12 text-center shadow-sm">
          <div class="bg-gray-100 w-16 h-16 rounded-full flex items-center justify-center mx-auto mb-4">
            <Dumbbell :size="32" class="text-gray-400" />
          </div>
          <h3 class="text-lg font-semibold text-gray-900">Aucun atelier configuré</h3>
          <p class="text-gray-500 mt-2">Ajoutez des ateliers pour que les élèves puissent jouer.</p>
        </div>

        <draggable 
          v-model="workshops" 
          item-key="id"
          tag="div"
          class="grid gap-4"
          handle=".drag-handle"
          @end="onDragEnd"
        >
          <template #item="{ element: workshop, index }">
            <div 
              class="bg-white border border-gray-200 rounded-xl p-4 flex flex-col sm:flex-row items-center sm:space-x-4 space-y-4 sm:space-y-0 hover:border-emerald-500/50 hover:shadow-md transition-all relative"
            >
              <!-- Drag Handle -->
              <div class="absolute top-2 right-2 sm:hidden text-gray-300">
                  <GripVertical :size="20" class="drag-handle" />
              </div>
              <div class="hidden sm:flex text-gray-300 cursor-grab active:cursor-grabbing drag-handle hover:text-gray-500 p-2">
                  <GripVertical :size="24" />
              </div>

              <!-- Number (Clickable to reorder) -->
              <div 
                @click="promptReorder(workshop, index)"
                class="absolute top-4 left-4 sm:static flex-shrink-0 w-10 h-10 bg-emerald-100 text-emerald-800 rounded-full flex items-center justify-center font-bold font-mono border border-emerald-200 cursor-pointer hover:bg-emerald-200 hover:scale-110 transition-all"
                title="Cliquer pour changer la position"
              >
                {{ index + 1 }}
              </div>
              
              <!-- Image (Full width on mobile) -->
              <div class="w-full sm:w-24 h-32 sm:h-16 bg-gray-100 rounded-lg overflow-hidden flex-shrink-0 border border-gray-200 ml-0 sm:ml-0 mt-8 sm:mt-0 drag-handle sm:cursor-grab active:cursor-grabbing">
                <img 
                  :src="workshop.workshop_image_url || workshop.exercise?.image_url" 
                  class="w-full h-full object-contain bg-white p-1 pointer-events-none" 
                  alt="Atelier"
                />
              </div>

              <!-- Info -->
              <div class="flex-1 min-w-0 w-full text-center sm:text-left">
                <h3 class="text-lg font-bold text-gray-900 truncate">{{ workshop.exercise?.name }}</h3>
                <div class="flex flex-wrap justify-center sm:justify-start gap-2 text-xs font-semibold mt-1">
                  <span class="bg-green-100 text-green-700 px-2 py-0.5 rounded border border-green-200">{{ workshop.muscle_primary }}</span>
                  <span class="bg-yellow-100 text-yellow-700 px-2 py-0.5 rounded border border-yellow-200">{{ workshop.muscle_secondary }}</span>
                  <span class="bg-red-100 text-red-700 px-2 py-0.5 rounded border border-red-200">{{ workshop.muscle_tertiary }}</span>
                </div>
              </div>

              <!-- Actions -->
              <div class="flex items-center w-full sm:w-auto justify-end sm:justify-start border-t sm:border-0 border-gray-100 pt-3 sm:pt-0 mt-3 sm:mt-0">
                <button @click="editWorkshop(workshop)" class="text-gray-400 hover:text-emerald-500 p-2 transition-colors mr-1" title="Modifier">
                   <Pencil :size="18" />
                </button>
                <button @click="deleteWorkshop(workshop.id)" class="text-gray-400 hover:text-red-500 p-2 transition-colors" title="Supprimer">
                   <Trash2 :size="18" />
                </button>
              </div>
            </div>
          </template>
        </draggable>
      </div>

      <!-- Attendance Tab -->
      <div v-else-if="activeTab === 'attendance'" class="space-y-4">
         <div class="bg-white border border-gray-200 rounded-2xl overflow-hidden shadow-sm">
            <div class="p-6 border-b border-gray-100 bg-gray-50">
               <h3 class="text-lg font-bold text-gray-900 flex items-center">
                  <Users :size="20" class="mr-2 text-emerald-600" />
                  Liste des élèves connectés
               </h3>
               <p class="text-sm text-gray-500">Mise à jour automatique en temps réel.</p>
            </div>
            
            <div v-if="parsedStudents.length === 0" class="p-12 text-center text-gray-400 italic">
               Aucun élève connecté pour le moment.
            </div>

            <div v-else class="divide-y divide-gray-100">
               <div v-for="student in parsedStudents" :key="student.id" class="p-4 flex flex-col sm:flex-row items-start sm:items-center justify-between hover:bg-gray-50 transition-colors gap-4 sm:gap-0">
                  <div class="flex items-center space-x-3 w-full sm:w-auto">
                     <div class="w-10 h-10 rounded-full bg-emerald-100 text-emerald-700 flex items-center justify-center font-bold shrink-0">
                        {{ student.realName.charAt(0) }}
                     </div>
                     <div class="min-w-0">
                        <div class="flex items-center space-x-2 flex-wrap">
                          <p class="font-bold text-gray-900 text-lg truncate">{{ student.realName }}</p>
                          <span class="bg-gray-100 text-gray-600 px-2 py-0.5 rounded text-xs font-bold border border-gray-200 whitespace-nowrap">
                             Groupe {{ student.groupNumber }}
                          </span>
                        </div>
                        <p class="text-xs text-gray-500">Connecté à {{ new Date(student.joinedAt).toLocaleTimeString() }}</p>
                     </div>
                  </div>
                  <div class="flex items-center justify-between w-full sm:w-auto sm:justify-end border-t sm:border-0 border-gray-100 pt-3 sm:pt-0">
                     <span class="inline-block px-3 py-1 bg-gray-100 text-gray-600 rounded-full text-sm font-bold mr-3">
                        {{ student.score }} pts
                     </span>
                     <button @click="deleteStudent(student)" class="text-gray-400 hover:text-red-500 hover:bg-red-50 p-1.5 rounded-full transition-colors" title="Supprimer l'élève">
                        <Trash2 :size="16" />
                     </button>
                  </div>
               </div>
            </div>
         </div>
      </div>

      <!-- Ranking Tab -->
      <div v-if="activeTab === 'ranking'" class="space-y-4">
          <div class="bg-white border border-gray-200 rounded-2xl overflow-hidden shadow-sm">
            <div class="p-6 border-b border-gray-100 bg-gray-50 flex justify-between items-center">
               <div>
                  <h3 class="text-lg font-bold text-gray-900 flex items-center">
                     <Trophy :size="20" class="mr-2 text-yellow-500" />
                     Classement en direct
                  </h3>
                  <p class="text-sm text-gray-500">Basé sur les points collectés (Exercices validés + Bonus)</p>
               </div>
            </div>

            <div v-if="rankedGroups.length === 0" class="p-12 text-center text-gray-400 italic">
               Aucun groupe pour le moment.
            </div>

            <div v-else class="divide-y divide-gray-100">
               <div 
                  v-for="(group, index) in rankedGroups" 
                  :key="group.id" 
                  class="p-4 flex items-center justify-between hover:bg-gray-50 transition-colors"
                  :class="{'bg-yellow-50/50': index === 0, 'bg-gray-50/30': index === 1, 'bg-amber-50/20': index === 2}"
               >
                  <div class="flex items-center space-x-4">
                     <!-- Rank Badge -->
                     <div 
                        class="w-12 h-12 rounded-full flex items-center justify-center font-black text-lg border-2 shadow-sm"
                        :class="[
                           index === 0 ? 'bg-yellow-100 text-yellow-700 border-yellow-200' :
                           index === 1 ? 'bg-gray-100 text-gray-700 border-gray-200' :
                           index === 2 ? 'bg-amber-100 text-amber-800 border-amber-200' :
                           'bg-white text-gray-400 border-gray-100'
                        ]"
                     >
                        {{ index + 1 }}
                     </div>
                     
                     <div>
                        <div class="font-bold text-gray-900 text-lg">{{ group.name }}</div>
                        <div class="text-xs text-gray-500">Groupe {{ index + 1 }}</div>
                     </div>
                  </div>

                  <div class="flex items-center space-x-4">
                     <div class="text-right">
                        <div class="text-2xl font-black text-emerald-600">{{ group.score || 0 }}</div>
                        <div class="text-[10px] uppercase font-bold text-emerald-800/50 tracking-wider">Points</div>
                     </div>
                  </div>
               </div>
            </div>
          </div>
      </div>

      <!-- Timer Tab -->
    <div v-show="activeTab === 'timer'" class="max-w-4xl mx-auto space-y-8">
      
      <!-- Controller Section -->
      <div class="bg-gray-900 text-white p-6 rounded-2xl shadow-xl border border-gray-800 relative overflow-hidden">
        
        <!-- Live Status Indicator -->
        <div class="absolute top-4 right-4 flex items-center space-x-2">
            <span v-if="timerState.isRunning" class="flex h-3 w-3 relative">
              <span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-emerald-400 opacity-75"></span>
              <span class="relative inline-flex rounded-full h-3 w-3 bg-emerald-500"></span>
            </span>
            <span class="text-xs font-mono uppercase text-gray-400">
               {{ timerState.state === 'running' ? 'En cours' : (timerState.state === 'paused' ? 'En pause' : 'Arrêté') }}
            </span>
        </div>

        <div class="text-center py-6">
           <div v-if="localTimerCalc.isFinished" class="animate-pulse">
              <h2 class="text-2xl md:text-4xl font-black text-red-500 mb-2 uppercase tracking-widest">Fin de l'entraînement</h2>
           </div>
           <div v-else>
               <h3 class="text-gray-400 text-xs md:text-sm font-bold uppercase tracking-wider mb-2">
                  {{ localTimerCalc.currentPhase ? `Phase ${localTimerCalc.currentPhaseIndex + 1} : ${localTimerCalc.currentPhase.name}` : 'Prêt à démarrer' }}
               </h3>
               <div class="text-5xl md:text-7xl font-mono font-bold tracking-tight mb-4 tabular-nums" :class="getTimerColorClass(localTimerCalc.currentPhase)">
                  {{ formatTime(localTimerCalc.remainingInPhase) }}
               </div>
           </div>

           <!-- Controls -->
           <div class="flex justify-center items-center space-x-4 mt-8">
             <button 
               v-if="timerState.state !== 'running'"
               type="button"
               @click="controlTimer('start')"
               class="bg-emerald-600 hover:bg-emerald-500 text-white w-16 h-16 rounded-full flex items-center justify-center transition-all active:scale-95 shadow-lg shadow-emerald-900/50"
             >
                <Play :size="32" class="ml-1" />
             </button>
             <button 
               v-else
               type="button"
               @click="controlTimer('pause')"
               class="bg-amber-600 hover:bg-amber-500 text-white w-16 h-16 rounded-full flex items-center justify-center transition-all active:scale-95 shadow-lg shadow-amber-900/50"
             >
                <Pause :size="32" />
             </button>

             <button 
               type="button"
               @click="controlTimer('stop')"
               class="bg-gray-700 hover:bg-gray-600 text-white w-12 h-12 rounded-full flex items-center justify-center transition-all active:scale-95"
               title="Arrêter et Réinitialiser"
             >
                <Square :size="20" />

             </button>
           </div>
        </div>
      </div>

      <!-- Builder Section -->
      <div class="bg-white p-6 rounded-2xl shadow-sm border border-gray-200">
         <h3 class="text-lg font-bold text-gray-900 mb-4 flex items-center">
            <Settings :size="20" class="mr-2 text-emerald-600" />
            Configuration des Séquences
         </h3>

         <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
            <!-- Phase List -->
            <div class="md:col-span-2 space-y-3">
               <div v-if="timerConfig.phases.length === 0" class="text-center p-8 border-2 border-dashed border-gray-200 rounded-xl text-gray-400">
                  Aucune phase configurée. Ajoutez-en une !
               </div>
               
               <div 
                 v-for="(phase, idx) in timerConfig.phases" 
                 :key="idx"
                 class="flex items-center p-3 bg-gray-50 rounded-lg border border-gray-100 group"
               >
                  <div class="w-6 h-6 rounded-full flex items-center justify-center text-xs font-bold mr-3" :class="getColorBg(phase.color)">
                     {{ idx + 1 }}
                  </div>
                  <div class="flex-1">
                     <div class="font-bold text-gray-800 text-sm">{{ phase.name }}</div>
                     <div class="text-xs text-gray-500">{{ formatDuration(phase.duration) }} • {{ getColorLabel(phase.color) }}</div>
                  </div>
                  <button @click="removePhase(idx)" class="text-gray-400 hover:text-red-500 p-2 opacity-0 group-hover:opacity-100 transition-opacity">
                     <Trash2 :size="16" />
                  </button>
               </div>

               <!-- Repeats -->
               <div class="flex items-center justify-end space-x-3 pt-4 border-t border-gray-100">
                  <span class="text-sm font-bold text-gray-700">Répéter la séquence :</span>
                  <div class="flex items-center bg-gray-100 rounded-lg p-1">
                     <button @click="updateRepeats(-1)" class="w-8 h-8 flex items-center justify-center hover:bg-white rounded text-gray-600 font-bold">-</button>
                     <span class="w-8 text-center font-mono font-bold">{{ timerConfig.repeats }}</span>
                     <button @click="updateRepeats(1)" class="w-8 h-8 flex items-center justify-center hover:bg-white rounded text-gray-600 font-bold">+</button>
                  </div>
                  <span class="text-sm text-gray-500 bg-gray-100 px-2 py-1 rounded">x fois</span>
               </div>
               
               <div class="flex justify-end mt-4">
                  <button @click="saveTimerConfig" class="text-sm text-emerald-600 font-bold hover:underline" v-if="configChanged">
                     Sauvegarder la configuration
                  </button>
                  <span v-else class="text-xs text-gray-400 flex items-center"><Check :size="12" class="mr-1"/> Config sauvegardée</span>
               </div>
            </div>

            <!-- Add Phase Form -->
            <div class="bg-gray-50 p-4 rounded-xl border border-gray-200 h-fit">
               <h4 class="font-bold text-gray-700 text-sm mb-3">Ajouter une phase</h4>
               <div class="space-y-3">
                  <div>
                     <label class="block text-xs uppercase text-gray-500 font-bold mb-1">Nom</label>
                     <input v-model="newPhase.name" type="text" placeholder="Ex: Travail, Repos..." class="w-full text-sm rounded-lg border-gray-300 focus:ring-emerald-500 focus:border-emerald-500 p-2" />
                  </div>
                  <div class="grid grid-cols-2 gap-2">
                     <div>
                        <label class="block text-xs uppercase text-gray-500 font-bold mb-1">Min</label>
                        <input v-model.number="newPhase.min" type="number" min="0" class="w-full text-sm rounded-lg border-gray-300 focus:ring-emerald-500 p-2" />
                     </div>
                     <div>
                        <label class="block text-xs uppercase text-gray-500 font-bold mb-1">Sec</label>
                        <input v-model.number="newPhase.sec" type="number" min="0" max="59" class="w-full text-sm rounded-lg border-gray-300 focus:ring-emerald-500 p-2" />
                     </div>
                  </div>
                  <div>
                     <label class="block text-xs uppercase text-gray-500 font-bold mb-1">Couleur</label>
                     <div class="grid grid-cols-5 gap-1">
                        <button 
                           v-for="color in timerColors" 
                           :key="color.value"
                           @click="newPhase.color = color.value"
                           class="w-8 h-8 rounded-full border-2 transition-all"
                           :class="[color.bg, newPhase.color === color.value ? 'border-gray-900 scale-110' : 'border-transparent opacity-50 hover:opacity-100']"
                           :title="color.label"
                        ></button>
                     </div>
                     <p class="text-[10px] text-gray-500 mt-1 text-center">{{ timerColors.find(c => c.value === newPhase.color)?.label }}</p>
                  </div>
                  <button 
                     @click="addPhase"
                     :disabled="!isValidPhase"
                     class="w-full bg-emerald-600 text-white font-bold py-2 rounded-lg text-sm hover:bg-emerald-700 disabled:opacity-50 disabled:cursor-not-allowed mt-2"
                  >
                     Ajouter
                  </button>
               </div>
            </div>
         </div>
      </div>
    </div>

      <!-- Config Tab -->
      <div v-if="activeTab === 'config'" class="max-w-2xl mx-auto">
         <div class="bg-white border border-gray-200 rounded-2xl p-6 shadow-sm">
            <h3 class="text-lg font-bold text-gray-900 mb-2 flex items-center">
              <Settings :size="20" class="mr-2 text-emerald-600" />
              Configuration du Carnet d'entraînement
            </h3>
            <p class="text-gray-500 text-sm mb-6">Choisissez les colonnes visibles par les élèves dans leur carnet.</p>
            
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
               <div v-for="(label, key) in notebookConfigLabels" :key="key" class="flex items-center justify-between p-4 bg-gray-50 rounded-xl border border-gray-200">
                  <span class="font-bold text-gray-700">{{ label }}</span>
                  <label class="relative inline-flex items-center cursor-pointer">
                    <input type="checkbox" v-model="notebookConfig[key]" class="sr-only peer" @change="updateRoomConfig">
                    <div class="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-emerald-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-emerald-600"></div>
                  </label>
               </div>
            </div>
         </div>
         
         <!-- Preview Widget -->
         <div class="bg-white border border-gray-200 rounded-2xl p-6 shadow-sm opacity-75">
            <h4 class="text-sm font-bold text-gray-400 uppercase tracking-widest mb-4">Aperçu du tableau élève</h4>
            <div class="overflow-x-auto">
              <table class="w-full text-sm text-left">
                 <thead class="text-xs text-gray-700 uppercase bg-gray-50">
                    <tr>
                       <th class="px-4 py-3 rounded-l-lg">Atelier (Fixe)</th>
                       <th v-if="notebookConfig.notebook_visible_level" class="px-4 py-3">Niveau</th>
                       <th v-if="notebookConfig.notebook_visible_placement" class="px-4 py-3">Placement</th>
                       <th v-if="notebookConfig.notebook_visible_tempo" class="px-4 py-3">Tempo</th>
                       <th v-if="notebookConfig.notebook_visible_respiration" class="px-4 py-3">Respiration</th>
                       <th v-if="notebookConfig.notebook_visible_feeling" class="px-4 py-3 rounded-r-lg">Ressentis</th>
                    </tr>
                 </thead>
                 <tbody>
                    <tr class="border-b border-gray-100">
                       <td class="px-4 py-3 font-medium">Atelier 1...</td>
                       <td v-if="notebookConfig.notebook_visible_level" class="px-4 py-3 text-gray-400">--</td>
                       <td v-if="notebookConfig.notebook_visible_placement" class="px-4 py-3 text-gray-400">--</td>
                       <td v-if="notebookConfig.notebook_visible_tempo" class="px-4 py-3 text-gray-400">--</td>
                       <td v-if="notebookConfig.notebook_visible_respiration" class="px-4 py-3 text-gray-400">--</td>
                       <td v-if="notebookConfig.notebook_visible_feeling" class="px-4 py-3 text-gray-400">--</td>
                    </tr>
                 </tbody>
              </table>
            </div>
         </div>
      </div>

    </div>

    <!-- Add Modal -->
    <div v-if="showAddModal" class="fixed inset-0 z-50 flex items-center justify-center px-4 bg-black/40 backdrop-blur-sm">
      <div class="bg-white rounded-2xl w-full max-w-2xl p-6 shadow-2xl max-h-[90vh] overflow-y-auto animate-in zoom-in-95 duration-200">
        
        <div class="flex justify-between items-center mb-6 border-b border-gray-100 pb-4">
          <h3 class="text-xl font-bold text-gray-900">Nouvel Atelier</h3>
          <button @click="showAddModal = false" class="text-gray-400 hover:text-gray-600">
            <X :size="24" />
          </button>
        </div>

        <form @submit.prevent="saveWorkshop" class="space-y-6">
          
          <!-- Step 1: Exercises -->
          <div class="space-y-3">
             <label class="block text-sm font-bold text-gray-700">Exercice support</label>
             <div class="grid grid-cols-2 sm:grid-cols-3 gap-3 max-h-48 overflow-y-auto pr-2 custom-scrollbar">
                <div 
                  v-for="ex in exercises" 
                  :key="ex.id"
                  @click="selectedExercise = ex"
                  :class="[
                    'cursor-pointer border-2 rounded-lg p-2 text-center transition-all',
                    selectedExercise?.id === ex.id 
                      ? 'bg-emerald-50 border-emerald-500' 
                      : 'bg-white border-gray-200 hover:border-emerald-300'
                  ]"
                >
                  <div class="aspect-video bg-gray-100 rounded mb-2 overflow-hidden border border-gray-100">
                    <img v-if="ex.image_url" :src="ex.image_url" class="w-full h-full object-cover" />
                  </div>
                  <p class="text-xs font-medium text-gray-700 truncate">{{ ex.name }}</p>
                </div>
             </div>
             <p v-if="!selectedExercise" class="text-red-500 text-xs mt-1 font-medium">Veuillez sélectionner un exercice</p>
             <p v-if="!selectedExercise" class="text-red-500 text-xs mt-1 font-medium">Veuillez sélectionner un exercice</p>
          </div>

          <!-- Mission du jour -->
          <div>
            <label class="block text-sm font-bold text-gray-700 mb-1">Mission du jour</label>
            <textarea
              v-model="newWorkshop.mission"
              rows="3"
              class="w-full bg-gray-50 border border-gray-300 rounded-lg px-4 py-2 text-gray-900 text-sm focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 resize-none"
              placeholder="Ex: Réaliser 3 séries de 10 répétitions avec une pause de 2 minutes."
            ></textarea>
            <p class="text-xs text-gray-500 mt-1">Ces consignes apparaitront sur la fiche de l'atelier pour l'élève.</p>
          </div>



          <!-- Options de visibilité -->
          <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
             <label 
                class="flex items-center space-x-3 p-3 border rounded-lg transition"
                :class="selectedExercise?.placement ? 'border-gray-200 hover:bg-gray-50 cursor-pointer' : 'border-gray-100 bg-gray-50 opacity-50 cursor-not-allowed'"
             >
               <input 
                 type="checkbox" 
                 v-model="newWorkshop.show_placement" 
                 :disabled="!selectedExercise?.placement"
                 class="w-5 h-5 text-emerald-600 rounded focus:ring-emerald-500 disabled:text-gray-400" 
               />
               <div class="flex flex-col">
                  <span class="text-sm font-medium text-gray-700">Afficher Placement (après validation)</span>
                  <span v-if="!selectedExercise?.placement" class="text-xs text-red-500 font-medium italic">Contenu manquant (vide)</span>
               </div>
             </label>

             <label 
                class="flex items-center space-x-3 p-3 border rounded-lg transition"
                :class="selectedExercise?.respiration ? 'border-gray-200 hover:bg-gray-50 cursor-pointer' : 'border-gray-100 bg-gray-50 opacity-50 cursor-not-allowed'"
             >
               <input 
                 type="checkbox" 
                 v-model="newWorkshop.show_respiration" 
                 :disabled="!selectedExercise?.respiration"
                 class="w-5 h-5 text-emerald-600 rounded focus:ring-emerald-500 disabled:text-gray-400" 
               />
               <div class="flex flex-col">
                  <span class="text-sm font-medium text-gray-700">Afficher Respiration (après validation)</span>
                  <span v-if="!selectedExercise?.respiration" class="text-xs text-red-500 font-medium italic">Contenu manquant (vide)</span>
              </div>
             </label>

             <label 
                class="flex items-center space-x-3 p-3 border rounded-lg transition"
                :class="selectedExercise?.tempo ? 'border-gray-200 hover:bg-gray-50 cursor-pointer' : 'border-gray-100 bg-gray-50 opacity-50 cursor-not-allowed'"
             >
                <input 
                  type="checkbox" 
                  v-model="newWorkshop.show_tempo" 
                  :disabled="!selectedExercise?.tempo"
                  class="w-5 h-5 text-emerald-600 rounded focus:ring-emerald-500 disabled:text-gray-400" 
                />
                <div class="flex flex-col">
                  <span class="text-sm font-medium text-gray-700">Afficher Tempo (après validation)</span>
                  <span v-if="!selectedExercise?.tempo" class="text-xs text-red-500 font-medium italic">Contenu manquant (vide)</span>
                </div>
              </label>
          </div>

          


          <!-- Footer -->
          <div class="pt-4 flex justify-end space-x-3 border-t border-gray-100 mt-6">
            <button 
              type="button"
              @click="closeModal"
              class="px-4 py-2 text-gray-700 font-bold bg-gray-100 hover:bg-gray-200 rounded-lg transition-colors"
            >
              Annuler
            </button>
            <button 
              type="submit"
              :disabled="!selectedExercise || submitting" 
              class="px-6 py-2 bg-emerald-600 text-white font-bold rounded-lg hover:bg-emerald-700 transition-colors disabled:opacity-50 disabled:cursor-not-allowed flex items-center"
            >
              <Loader2 v-if="submitting" class="animate-spin mr-2" :size="18" />
              {{ editingWorkshopId ? 'Mettre à jour' : 'Créer' }}
            </button> 

          </div>

        </form>
      </div>
    </div>

  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { useRoute } from 'vue-router'
import { supabase } from '../../supabase'
import { MUSCLE_LIST } from '../../constants/muscles'
import { calculateTimerState, TIMER_COLORS } from '../../utils/timer'
import { ArrowLeft, Plus, Dumbbell, Trash2, X, Loader2, Users, Settings, Pencil, Check, Clock, Play, Pause, Square, Trophy, GripVertical, Copy } from 'lucide-vue-next'
import draggable from 'vuedraggable'

const route = useRoute()
const roomId = route.params.id
const roomCode = ref('...')
const roomName = ref('')
const isEditingName = ref(false)
const editedRoomName = ref('')
const nameInput = ref(null)

const workshops = ref([])
const exercises = ref([])
const students = ref([])
const activeTab = ref('workshops')
const muscleList = MUSCLE_LIST

const showAddModal = ref(false)
const editingWorkshopId = ref(null)
const submitting = ref(false)
const selectedExercise = ref(null)

// Watch for exercise change to reset options if content is missing
import { watch } from 'vue'
watch(selectedExercise, (newEx) => {
  if (newEx) {
    if (!newEx.placement) newWorkshop.value.show_placement = false
    if (!newEx.respiration) newWorkshop.value.show_respiration = false
    if (!newEx.tempo) newWorkshop.value.show_tempo = false
  }
})

const newWorkshop = ref({
  workshop_image_url: '',
  mission: '',
  show_placement: false,
  show_respiration: false,
  show_tempo: false
})

const notebookConfig = ref({
  notebook_visible_level: true,
  notebook_visible_placement: true,
  notebook_visible_tempo: true,
  notebook_visible_respiration: true,
  notebook_visible_feeling: true
})

const notebookConfigLabels = {
  notebook_visible_level: 'Colonne Niveau',
  notebook_visible_placement: 'Colonne Placement',
  notebook_visible_tempo: 'Colonne Tempo',
  notebook_visible_respiration: 'Colonne Respiration',
  notebook_visible_feeling: 'Colonne Ressentis (RPE)'
}

const fetchRoomDetails = async () => {
  const { data, error } = await supabase.from('rooms').select('*').eq('id', roomId).single()
  if (data) {
    roomCode.value = data.code
    roomName.value = data.name
    notebookConfig.value = {
      notebook_visible_level: data.notebook_visible_level ?? true,
      notebook_visible_placement: data.notebook_visible_placement ?? true,
      notebook_visible_tempo: data.notebook_visible_tempo ?? true,
      notebook_visible_respiration: data.notebook_visible_respiration ?? true,
      notebook_visible_feeling: data.notebook_visible_feeling ?? true,
    }
    
    // Timer Config & Status Load
    if (data.timer_config) timerConfig.value = data.timer_config
    if (data.timer_status) timerState.value = data.timer_status
  }
}

// Timer Logic
const timerColors = TIMER_COLORS
const timerConfig = ref({ repeats: 1, phases: [] })
const timerState = ref({ state: 'idle', start_timestamp: null, paused_timestamp: null, elapsed_before_pause: 0 })
const localTimerCalc = ref({})
const configChanged = ref(false)

const newPhase = ref({ name: 'Travail', min: 0, sec: 0, color: 'emerald' })

const isValidPhase = computed(() => {
   return newPhase.value.name.length > 0 && (newPhase.value.min > 0 || newPhase.value.sec > 0)
})

const addPhase = () => {
   const duration = (newPhase.value.min * 60) + newPhase.value.sec
   timerConfig.value.phases.push({
      id: crypto.randomUUID(),
      name: newPhase.value.name,
      duration: duration,
      color: newPhase.value.color
   })
   configChanged.value = true
   // Reset form (keep name/color for rapid entry?)
   newPhase.value = { name: 'Repos', min: 0, sec: 30, color: 'red' }
}

const removePhase = (idx) => {
   timerConfig.value.phases.splice(idx, 1)
   configChanged.value = true
}

const updateRepeats = (delta) => {
   const newVal = (timerConfig.value.repeats || 1) + delta
   if (newVal >= 1) {
      timerConfig.value.repeats = newVal
      configChanged.value = true
   }
}

const saveTimerConfig = async () => {
   const { error } = await supabase.from('rooms').update({ timer_config: timerConfig.value }).eq('id', roomId)
   if (!error) configChanged.value = false
}

const controlTimer = async (action) => {
  // Auto-save config if needed before starting
  if (configChanged.value || action === 'start') {
      await supabase.from('rooms').update({ timer_config: timerConfig.value }).eq('id', roomId)
      configChanged.value = false
  }

  const now = Date.now()
  let newState = { ...timerState.value }

  if (action === 'start') {
     // Resume or Start Fresh
     if (newState.state === 'paused') {
        newState.state = 'running'
        newState.start_timestamp = now - newState.elapsed_before_pause
        newState.paused_timestamp = null
     } else {
        newState.state = 'running'
        newState.start_timestamp = now
        newState.elapsed_before_pause = 0
     }
  } else if (action === 'pause') {
     if (newState.state === 'running') {
        newState.state = 'paused'
        newState.paused_timestamp = now
        newState.elapsed_before_pause = now - newState.start_timestamp
     }
  } else if (action === 'stop') {
     // Force full reset
     newState = { 
        state: 'idle', 
        start_timestamp: null, 
        paused_timestamp: null, 
        elapsed_before_pause: 0 
     }
  }

  // Optimistic update - Force new object reference
  timerState.value = { ...newState }
  
  // Save to DB
  const { error } = await supabase.from('rooms').update({ timer_status: newState }).eq('id', roomId)
  
  if (error) {
     console.error("Timer update error:", error)
     // Revert on error? Or just alert
     // alert("Erreur maj chrono: " + error.message)
  }
}

// Helpers
const getColorBg = (colorVal) => {
   return timerColors.find(c => c.value === colorVal)?.light || 'bg-gray-100'
}
const getColorLabel = (colorVal) => {
   return timerColors.find(c => c.value === colorVal)?.label || colorVal
}
const getTimerColorClass = (phase) => {
   if (!phase) return 'text-gray-400'
   return timerColors.find(c => c.value === phase.color)?.text || 'text-gray-900'
}
const formatDuration = (d) => {
   if (!d) return '0s'
   const m = Math.floor(d / 60)
   const s = d % 60
   return `${m > 0 ? m + 'm ' : ''}${s}s`
}
// Specific formatter for HH:MM:SS big display
const formatTime = (ms) => {
   if (ms <= 0) return '00:00'
   const totalSec = Math.ceil(ms / 1000)
   const m = Math.floor(totalSec / 60)
   const s = totalSec % 60
   return `${m.toString().padStart(2, '0')}:${s.toString().padStart(2, '0')}`
}

let timerInterval
onMounted(() => {
   fetchRoomDetails()
   
   // Subscribe to Realtime changes for this room
   const channel = supabase.channel(`room_timer_${roomId}`)
   .on('postgres_changes', { event: 'UPDATE', schema: 'public', table: 'rooms', filter: `id=eq.${roomId}` }, (payload) => {
      if (payload.new.timer_status) timerState.value = payload.new.timer_status
      // We don't auto-update config here to avoid disrupting editing, but for status it's critical
   })
   .subscribe()

   // Local Loop for UI update
   timerInterval = setInterval(() => {
     localTimerCalc.value = calculateTimerState(timerConfig.value, timerState.value)
   }, 100)
})

import { onBeforeUnmount } from 'vue'
onBeforeUnmount(() => {
   if (timerInterval) clearInterval(timerInterval)
   supabase.removeAllChannels()
})

const updateRoomConfig = async () => {
  const { error } = await supabase
    .from('rooms')
    .update(notebookConfig.value)
    .eq('id', roomId)
    
  if (error) console.error('Error updating config:', error)
}

const fetchWorkshops = async () => {
  const { data, error } = await supabase
    .from('workshops')
    .select('*, exercise:exercises(*)')
    .eq('room_id', roomId)
    .order('order_index', { ascending: true })
    .order('created_at', { ascending: true })
  
  if (data) workshops.value = data
}

const startEditName = () => {
  editedRoomName.value = roomName.value
  isEditingName.value = true
  setTimeout(() => {
     nameInput.value?.focus()
  }, 100)
}

const cancelEditName = () => {
   isEditingName.value = false
   editedRoomName.value = ''
}

const saveRoomName = async () => {
   if (!editedRoomName.value || !editedRoomName.value.trim()) return
   
   const newName = editedRoomName.value.trim()
   const { error } = await supabase
      .from('rooms')
      .update({ name: newName })
      .eq('id', roomId)
      
   if (error) {
      alert("Erreur lors de la modification : " + error.message)
   } else {
      roomName.value = newName
      isEditingName.value = false
   }
}

const fetchExercises = async () => {
  const { data } = await supabase.from('exercises').select('*').order('name')
  if (data) exercises.value = data
}

const fetchStudents = async () => {
  const { data } = await supabase
    .from('students')
    .select('*')
    .eq('room_id', roomId)
    .order('created_at', { ascending: true }) // Load oldest first to assign group IDs correctly
  
  if (data) students.value = data
}

const rankedGroups = computed(() => {
  return [...students.value].sort((a, b) => (b.score || 0) - (a.score || 0))
})

const parsedStudents = computed(() => {
  const result = []
  students.value.forEach((student, index) => {
    // Split names by ' & ' separator used in join screen
    const names = student.name.split(' & ')
    names.forEach(name => {
      result.push({
        id: `${student.id}-${name}`,
        originalId: student.id,
        realName: name.trim(),
        groupNumber: index + 1,
        score: student.score,
        joinedAt: student.created_at
      })
    })
  })
  return result
})

const subscribeToStudents = () => {
  supabase
    .channel('public:students')
    .on('postgres_changes', { event: '*', schema: 'public', table: 'students', filter: `room_id=eq.${roomId}` }, (payload) => {
      fetchStudents()
    })
    .subscribe()
}

const deleteStudent = async (student) => {
  // Removing confirmation as requested
  
  // console.log("Attempting to delete student:", student)

  const originalRow = students.value.find(s => s.id === student.originalId)
  if (!originalRow) {
    console.error("Could not find original student row:", student.originalId)
    return
  }

  const names = originalRow.name.split(' & ')
  // Ensure precise matching by trimming both sides
  const newNames = names.filter(n => n.trim() !== student.realName.trim())
  
  // console.log("Current names:", names)
  // console.log("Names after removal:", newNames)

  if (newNames.length === 0) {
    // No students left in this group, delete the row
    // console.log("Deleting entire row...")
    const { error } = await supabase.from('students').delete().eq('id', student.originalId)
    if (error) {
      console.error("Error deleting student row:", error)
      alert("Erreur lors de la suppression : " + error.message)
    } else {
      // console.log("Deleted successfully. Refreshing list...")
      await fetchStudents() // Force refresh
    }
  } else {
    // Update with remaining students
    const newNameStr = newNames.join(' & ')
    // console.log("Updating row with:", newNameStr)
    const { error } = await supabase.from('students').update({ name: newNameStr }).eq('id', student.originalId)
    if (error) {
       console.error("Error updating student names:", error)
       alert("Erreur lors de la mise à jour : " + error.message)
    } else {
       // console.log("Updated successfully. Refreshing list...")
       await fetchStudents() // Force refresh
    }
  }
}

const openAddModal = () => {
  editingWorkshopId.value = null
  selectedExercise.value = null
  newWorkshop.value = { workshop_image_url: '', mission: '', show_placement: false, show_respiration: false, show_tempo: false }
  showAddModal.value = true
}

const closeModal = () => {
  showAddModal.value = false
  editingWorkshopId.value = null
}

const editWorkshop = (workshop) => {
  console.log("Editing workshop:", workshop)
  editingWorkshopId.value = workshop.id
  
  // Find full exercise object
  // Debug: check if exercises are loaded and if we can find the match
  console.log("All exercises:", exercises.value.length)
  const found = exercises.value.find(e => e.id === workshop.exercise_id)
  console.log("Found exercise:", found)
  
  selectedExercise.value = found
  
  newWorkshop.value = {
    workshop_image_url: workshop.workshop_image_url || '',
    mission: workshop.mission || '',
    show_placement: workshop.show_placement || false,
    show_respiration: workshop.show_respiration || false,
    show_tempo: workshop.show_tempo || false
  }
  showAddModal.value = true
}

const saveWorkshop = async () => {
  if (!selectedExercise.value) return 
  
  submitting.value = true
  
  const payload = {
      room_id: roomId,
      exercise_id: selectedExercise.value.id,
      workshop_image_url: null, // Always use exercise image
      muscle_primary: selectedExercise.value.muscle_primary,
      muscle_secondary: selectedExercise.value.muscle_secondary,
      muscle_tertiary: selectedExercise.value.muscle_tertiary,
      order_index: workshops.value.length, // Only relevant for insert
      mission: newWorkshop.value.mission,
      show_placement: newWorkshop.value.show_placement,
      show_respiration: newWorkshop.value.show_respiration,
      show_tempo: newWorkshop.value.show_tempo
  }

  let data, error

  if (editingWorkshopId.value) {
     // Update
     const res = await supabase
       .from('workshops')
       .update(payload)
       .eq('id', editingWorkshopId.value)
       .select('*, exercise:exercises(*)')
     data = res.data
     error = res.error
  } else {
     // Insert
     const res = await supabase
       .from('workshops')
       .insert([payload])
       .select('*, exercise:exercises(*)')
     data = res.data
     error = res.error
  }
    
  if (error) {
    alert('Erreur: ' + error.message)
  } else {
    if (editingWorkshopId.value) {
       // Update list in place
       const idx = workshops.value.findIndex(w => w.id === editingWorkshopId.value)
       if (idx !== -1 && data && data[0]) workshops.value[idx] = data[0]
    } else {
       if (data && data[0]) workshops.value.push(data[0])
    }
    closeModal()
  }
  submitting.value = false
}

const deleteWorkshop = async (id) => {
  if(!confirm('Supprimer cet atelier ?')) return
  
  const { error } = await supabase.from('workshops').delete().eq('id', id)
  if (!error) {
    workshops.value = workshops.value.filter(w => w.id !== id)
    // Re-index remaining (optional but cleaner)
    saveWorkshopOrder() 
  }
}

const saveWorkshopOrder = async () => {
  // Use Promise.all for parallel updates (Safer than upsert for partial updates)
  const updates = workshops.value.map((w, index) => 
    supabase.from('workshops').update({ order_index: index }).eq('id', w.id)
  )
  
  if (updates.length === 0) return

  const results = await Promise.all(updates)
  const error = results.find(r => r.error)?.error
  
  if (error) {
     console.error("Error saving order:", error)
  } else {
     console.log("Order saved successfully")
  }
}

const onDragEnd = () => {
  saveWorkshopOrder()
}

const promptReorder = (workshop, currentIndex) => {
   const input = prompt(`Changer la position de cet atelier (1 - ${workshops.value.length}) :`, currentIndex + 1)
   if (input === null) return
   
   let newPos = parseInt(input)
   if (isNaN(newPos)) return
   
   // Clamp
   if (newPos < 1) newPos = 1
   if (newPos > workshops.value.length) newPos = workshops.value.length
   
   const newIndex = newPos - 1
   if (newIndex === currentIndex) return
   
   // Move
   const item = workshops.value.splice(currentIndex, 1)[0]
   workshops.value.splice(newIndex, 0, item)
   
   saveWorkshopOrder()
}

onMounted(() => {
  fetchRoomDetails()
  fetchWorkshops()
  fetchExercises()
  fetchStudents()
  subscribeToStudents()
})
</script>

<style scoped>
.custom-scrollbar::-webkit-scrollbar {
  width: 6px;
}
.custom-scrollbar::-webkit-scrollbar-track {
  background: #f1f5f9;
}
.custom-scrollbar::-webkit-scrollbar-thumb {
  background: #cbd5e1;
  border-radius: 4px;
}
</style>
