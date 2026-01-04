<template>
  <div class="min-h-screen bg-gray-50 pb-20">
    
    <!-- Top Bar -->
    <header class="bg-white border-b border-gray-200 sticky top-0 z-40 px-4 py-3 flex justify-between items-center shadow-md shadow-gray-200/50">
      <div class="flex items-center space-x-2">
         <div class="bg-gray-100 p-1.5 rounded text-gray-600">
           <User :size="16" />
         </div>
         <div class="flex flex-col min-w-0 max-w-[40vw]">
            <span class="font-bold text-gray-900 text-xs md:text-sm leading-tight truncate block" :title="studentInfo?.name">
              {{ studentInfo?.name }}
            </span>
            <button @click="leaveSession" class="text-[10px] flex items-center text-red-500 hover:text-red-700 font-medium mt-0.5 hover:underline decoration-red-500/30 transition-all w-fit">
               <LogOut :size="10" class="mr-1" />
               Quitter
            </button>
         </div>
      </div>
      
      <div class="flex items-center space-x-2 md:space-x-4">
        <!-- Global Timer -->
        <div 
          class="flex items-center space-x-2 md:space-x-3 rounded-xl px-2 py-1 md:px-4 md:py-2 border transition-all duration-500 shadow-sm"
          :class="[
            localTimerCalc.isFinished 
               ? 'bg-red-500 border-red-600 shadow-red-500/30 text-white' 
               : (!localTimerCalc.isRunning && !localTimerCalc.currentPhase 
                  ? 'bg-white border-gray-200 shadow-gray-200/50' 
                  : getTimerBgClass(localTimerCalc.currentPhase) + ' border-transparent shadow-lg'
               )
          ]"
        >
           <div class="relative">
              <Clock :size="16" class="md:w-5 md:h-5 transition-transform duration-700" :class="[
                 localTimerCalc.isFinished ? 'text-white' : (
                    (!localTimerCalc.isRunning && !localTimerCalc.currentPhase) ? 'text-gray-400' : getTimerTextClass(localTimerCalc.currentPhase)
                 ),
                 localTimerCalc.isRunning ? 'animate-pulse' : ''
              ]" />
              <span v-if="localTimerCalc.isRunning" class="absolute top-0 right-0 w-1.5 h-1.5 md:w-2 md:h-2 bg-red-500 rounded-full border-2 border-white translate-x-1 -translate-y-1"></span>
           </div>
           
           <div class="flex flex-col leading-tight" v-if="!localTimerCalc.isFinished">
              <span class="text-[8px] md:text-[10px] uppercase font-bold tracking-widest transition-colors" 
                 :class="(!localTimerCalc.isRunning && !localTimerCalc.currentPhase) ? 'text-gray-400' : getTimerTextClass(localTimerCalc.currentPhase).replace('text-', 'text-opacity-70 text-')"
              >
                {{ !localTimerCalc.isRunning && !localTimerCalc.currentPhase ? 'Attente' : (localTimerCalc.currentPhase?.name || 'Prêt') }}
              </span>
              <span class="font-mono font-bold text-sm md:text-base tabular-nums transition-colors" 
                 :class="(!localTimerCalc.isRunning && !localTimerCalc.currentPhase) ? 'text-gray-600 text-[10px] md:text-xs font-sans' : getTimerTextClass(localTimerCalc.currentPhase)"
              >
                {{ (!localTimerCalc.isRunning && !localTimerCalc.currentPhase) ? 'du prof...' : formatGlobalTime(localTimerCalc.remainingInPhase) }}
              </span>
           </div>
           <span v-else class="font-bold text-sm md:text-lg uppercase tracking-widest animate-pulse">FIN</span>
        </div>

        <!-- Personal Timer -->
        <!-- Timer -->
        <div class="flex items-center space-x-2 bg-gray-100 rounded-full p-1 border border-gray-200">
           <div class="px-2 md:px-3 flex items-center space-x-1 md:space-x-2">
              <Timer :size="16" class="md:w-[18px] md:h-[18px] text-emerald-600" />
              <span class="font-mono text-base md:text-xl font-bold text-gray-800 w-12 md:w-16 text-center">{{ formattedTime }}</span>
           </div>
           
           <div class="flex space-x-1">
              <button 
                @click="toggleTimer" 
                class="w-8 h-8 flex items-center justify-center rounded-full transition-all shadow-sm"
                :class="timerRunning ? 'bg-amber-100 text-amber-600 hover:bg-amber-200' : 'bg-emerald-100 text-emerald-600 hover:bg-emerald-200'"
              >
                <Pause v-if="timerRunning" :size="14" fill="currentColor" />
                <Play v-else :size="14" fill="currentColor" class="ml-0.5" />
              </button>

              <button 
                @click="resetTimer" 
                class="w-8 h-8 flex items-center justify-center bg-gray-200 text-gray-500 rounded-full hover:bg-gray-300 hover:text-gray-700 transition-all"
                title="Remettre à zéro"
              >
                <RotateCcw :size="14" />
              </button>
           </div>
        </div>

        <!-- Score -->
        <div class="bg-emerald-700 rounded-full px-3 py-1 flex items-center space-x-1 shadow-lg shadow-emerald-700/20">
           <Trophy :size="14" class="text-white" />
           <span class="font-bold text-white">{{ currentScore }} pts</span>
        </div>
      </div>
    </header>

    <!-- Content -->
    <main class="p-4 max-w-2xl mx-auto space-y-6">
      
      <!-- Start Workshop Modal -->
     <div v-if="workshops.length > 0 && !startWorkshopId" class="fixed inset-0 z-50 bg-gray-900/95 backdrop-blur-sm flex items-center justify-center p-4">
        <div class="bg-white w-full max-w-md rounded-2xl p-6 shadow-2xl animate-in zoom-in-95 duration-300 mx-4">
           <h2 class="text-xl md:text-2xl font-bold text-gray-900 mb-2 text-center">Départ 🏋️‍♂️</h2>
           <p class="text-gray-500 text-center mb-6 text-sm md:text-base">À quel atelier votre groupe commence-t-il ?</p>
           
           <div class="space-y-3 max-h-[60vh] overflow-y-auto custom-scrollbar pr-2">
              <button 
                v-for="(w, idx) in workshops" 
                :key="w.id"
                @click="!takenWorkshopIds.has(w.id) && setStartWorkshop(w.id)"
                :disabled="takenWorkshopIds.has(w.id)"
                class="w-full bg-gray-50 border border-gray-200 rounded-xl p-4 flex items-center transition-all group text-left relative overflow-hidden"
                :class="takenWorkshopIds.has(w.id) ? 'opacity-50 cursor-not-allowed bg-gray-100 grayscale' : 'hover:bg-emerald-50 hover:border-emerald-500'"
              >
                 <div class="absolute inset-0 bg-gray-200/50 backdrop-blur-[1px] z-10 flex items-center justify-center font-bold text-gray-500 uppercase tracking-widest -rotate-12 border-2 border-gray-300 rounded-xl m-2" v-if="takenWorkshopIds.has(w.id)">
                    Déjà choisi
                 </div>

                 <div class="w-10 h-10 rounded-full bg-emerald-100 text-emerald-700 flex items-center justify-center font-bold text-lg mr-4 border border-emerald-200 group-hover:scale-110 transition-transform">
                    {{ idx + 1 }}
                 </div>
                 <div>
                    <span class="block font-bold text-gray-900 text-lg group-hover:text-emerald-900">{{ w.exercises?.name }}</span>
                    <span class="text-xs text-gray-400 font-medium uppercase tracking-wider">Atelier {{ idx + 1 }}</span>
                 </div>
              </button>
           </div>
        </div>
     </div>

     <!-- Workshop List -->
     <div v-if="workshops.length === 0" class="text-center py-12">
        <Loader2 :size="32" class="animate-spin text-emerald-600 mx-auto" />
        <p class="text-gray-500 mt-4">Chargement des ateliers...</p>
      </div>



      <div v-else>
        <div v-if="activeTab === 'workshops'" class="space-y-6">
          <div 
            v-for="(workshop, index) in orderedWorkshops" 
          :key="workshop.id"
          class="bg-white border border-gray-200 rounded-2xl overflow-hidden shadow-sm transition-all duration-300"
          :class="{'opacity-75 grayscale': solvedWorkshops.has(workshop.id)}"
        >
          <!-- Image Header -->
          <div class="aspect-video bg-gray-100 relative group overflow-hidden">
             <!-- Video Player -->
             <div v-if="playingVideoId === workshop.id" class="w-full h-full bg-black">
                <iframe 
                  v-if="isYoutube(workshop.exercises?.video_url)"
                  :src="getEmbedUrl(workshop.exercises?.video_url)" 
                  class="w-full h-full" 
                  frameborder="0" 
                  allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" 
                  allowfullscreen
                ></iframe>
                <video 
                  v-else 
                  :src="workshop.exercises?.video_url" 
                  controls 
                  autoplay 
                  class="w-full h-full object-contain"
                ></video>
                <button 
                  @click.stop="playingVideoId = null" 
                  class="absolute top-2 right-2 bg-black/50 text-white p-1 rounded-full hover:bg-black/70 transition-colors z-10"
                >
                  <X :size="16" />
                </button>
             </div>

             <!-- Image + Play Button -->
             <div v-else class="w-full h-full relative cursor-pointer" @click="workshop.exercises?.video_url ? playingVideoId = workshop.id : null">
                <img 
                  :src="workshop.workshop_image_url || workshop.exercises?.image_url" 
                  class="w-full h-full object-contain bg-gray-50 transition-transform duration-700 hover:scale-105"
                />
                
                <!-- Overlay Gradient -->
                <div class="absolute inset-0 bg-gradient-to-t from-black/60 via-transparent to-transparent opacity-60"></div>

                <div class="absolute top-2 left-2 bg-white/90 backdrop-blur-md px-3 py-1 rounded-full text-emerald-800 text-xs font-bold border border-emerald-100 shadow-sm z-10">
                  Atelier {{ workshops.findIndex(w => w.id === workshop.id) + 1 }}
                </div>

                <!-- Play Button if Video Exists -->
                <div 
                  v-if="workshop.exercises?.video_url" 
                  class="absolute inset-0 flex items-center justify-center z-20 group-hover:scale-110 transition-transform duration-300"
                >
                   <div class="w-16 h-16 bg-white/20 backdrop-blur-sm rounded-full flex items-center justify-center border-2 border-white pl-1 shadow-2xl group-active:scale-95">
                      <Play :size="32" class="text-white drop-shadow-md" fill="currentColor" />
                   </div>
                   <span class="absolute mt-24 text-white font-bold text-sm tracking-wider uppercase drop-shadow-lg bg-red-600 px-3 py-1 rounded-full shadow-md animate-pulse">Voir la vidéo</span>
                </div>

                <div v-if="solvedWorkshops.has(workshop.id)" class="absolute inset-0 bg-white/60 backdrop-blur-[2px] flex flex-col items-center justify-center z-30 group-hover:bg-white/40 transition-all">
                  <div class="bg-white p-3 rounded-full shadow-xl mb-2">
                     <CheckCircle2 :size="32" class="text-emerald-500" />
                  </div>
                  <span class="text-emerald-800 text-xs font-bold bg-white/90 px-2 py-1 rounded shadow-sm">Validé ({{ workshopPoints[workshop.id] || 0 }} pts)</span>
                  <span class="text-emerald-600 text-[10px] font-medium mt-1 opacity-0 group-hover:opacity-100 transition-opacity">Cliquer pour modifier</span>
                </div>
             </div>
          </div>

          <!-- Body -->
          <div class="p-5">
            <h3 class="font-bold text-xl text-gray-900 mb-4 flex items-center">
              {{ workshop.exercises?.name }}
            </h3>

            <!-- Mission du jour -->
            <div v-if="workshop.mission" class="mb-6 bg-amber-100 text-black px-5 py-4 rounded-xl text-base whitespace-pre-line border-l-4 border-amber-500 shadow-md ring-1 ring-amber-200">
               <div class="flex items-center font-bold mb-2 text-amber-800 uppercase text-sm tracking-wider">
                 <Target :size="20" class="mr-2" /> 
                 Mission du jour
               </div>
               {{ workshop.mission }}
            </div>

            <!-- Niveaux (Toujours visible) -->
            <div v-if="workshop.exercises?.levels" class="mb-4 bg-blue-50 text-blue-950 px-4 py-3 rounded-xl text-sm font-semibold whitespace-pre-line border border-blue-200 shadow-sm">
               <div class="flex items-center font-bold mb-1 text-blue-800">
                 <Info :size="16" class="mr-2" /> 
                 Niveaux
               </div>
               {{ workshop.exercises.levels }}
            </div>


            <!-- Placement (Visible if enabled) -->
            <div v-if="workshop.show_placement && workshop.exercises?.placement" class="mb-4 bg-emerald-50 text-emerald-950 px-4 py-3 rounded-xl text-sm font-semibold whitespace-pre-line border border-emerald-200 shadow-sm">
               <div class="flex items-center font-bold mb-1 text-emerald-800 uppercase text-xs tracking-wider">
                 <Shield :size="16" class="mr-2" /> 
                 Placement & Sécurité
               </div>
               {{ workshop.exercises.placement }}
            </div>

            <!-- Tempo (Visible if enabled) -->
            <div v-if="workshop.show_tempo && workshop.exercises?.tempo" class="mb-4 bg-purple-50 text-purple-950 px-4 py-3 rounded-xl text-sm font-semibold whitespace-pre-line border border-purple-200 shadow-sm">
               <div class="flex items-center font-bold mb-1 text-purple-800 uppercase text-xs tracking-wider">
                 <Clock :size="16" class="mr-2" /> 
                 Tempo
               </div>
               {{ workshop.exercises.tempo }}
            </div>

            <!-- Respiration (Visible if enabled) -->
            <div v-if="workshop.show_respiration && workshop.exercises?.respiration" class="mb-6 bg-cyan-50 text-cyan-950 px-4 py-3 rounded-xl text-sm font-semibold whitespace-pre-line border border-cyan-200 shadow-sm">
               <div class="flex items-center font-bold mb-1 text-cyan-800 uppercase text-xs tracking-wider">
                 <Wind :size="16" class="mr-2" /> 
                 Respiration
               </div>
               {{ workshop.exercises.respiration }}
            </div>
            
            <div v-if="!solvedWorkshops.has(workshop.id)">
               <div class="space-y-4">
                 <div v-for="type in ['principal', 'secondaire', 'tertiaire']" :key="type">
                    <label class="text-xs uppercase font-bold text-gray-500 mb-1.5 block tracking-wide">Muscle {{ type }}</label>
                    <div class="relative">
                       <!-- Dropdown Trigger -->
                       <button 
                         @click="openDropdown === `${workshop.id}-${type}` ? openDropdown = null : openDropdown = `${workshop.id}-${type}`"
                         class="w-full text-left px-4 py-3 rounded-xl border flex items-center justify-between transition-all"
                         :class="answers[workshop.id][type] 
                            ? getMuscleStyle(answers[workshop.id][type], false).replace('hover:bg-white', '') + ' shadow-sm' 
                            : 'bg-white border-gray-300 text-gray-500 hover:border-emerald-500'"
                       >
                         <span :class="{'font-bold text-gray-900': answers[workshop.id][type]}">
                           {{ answers[workshop.id][type] || 'Sélectionner un muscle...' }}
                         </span>
                         <ChevronDown :size="18" class="text-gray-400 transition-transform" :class="{'rotate-180': openDropdown === `${workshop.id}-${type}`}" />
                       </button>
                       
                       <!-- Dropdown Menu -->
                       <div 
                         v-if="openDropdown === `${workshop.id}-${type}`" 
                         class="absolute z-10 top-full left-0 right-0 mt-2 bg-white border border-gray-200 rounded-xl shadow-xl max-h-64 overflow-y-auto p-2 space-y-1 custom-scrollbar animate-in fade-in zoom-in-95 duration-100"
                       >
                         <button
                           v-for="m in muscleList"
                           :key="m"
                           @click="answers[workshop.id][type] = m; openDropdown = null"
                           class="w-full text-left px-3 py-2 rounded-lg transition-all flex items-center justify-between text-xs border border-transparent"
                           :class="getMuscleStyle(m, answers[workshop.id][type] === m)"
                         >
                           <span>{{ m }}</span>
                           <CheckCircle2 v-if="answers[workshop.id][type] === m" :size="16" class="text-emerald-600" />
                         </button>
                       </div>
                       
                       <!-- Backdrop to close -->
                       <div 
                         v-if="openDropdown === `${workshop.id}-${type}`" 
                         class="fixed inset-0 z-0" 
                         @click="openDropdown = null"
                       ></div>
                    </div>
                 </div>
               </div>

               <button 
                 @click="submitWorkshop(workshop)"
                 class="w-full mt-8 bg-emerald-700 hover:bg-emerald-800 text-white font-bold py-3.5 rounded-xl transition-all shadow-lg shadow-emerald-700/20 active:scale-95 disabled:opacity-50 disabled:cursor-not-allowed"
                 :disabled="!isComplete(workshop.id)"
               >
                 Valider mes réponses
               </button>
            </div>
            
            <!-- Result Display -->
            <div v-else class="bg-emerald-50 border border-emerald-100 rounded-xl p-4 text-center mt-2">
               <span class="text-emerald-700 font-bold block mb-1 text-lg">Terminé !</span>
               <span class="text-emerald-600/80 text-sm font-medium block mb-4">Points gagnés : +{{ workshopPoints[workshop.id] || 0 }} pts</span>
               
               <!-- Placement & Respiration (Visible après validation) -->
               <div class="space-y-3 text-left">
                  <div v-if="workshop.show_placement && workshop.exercises?.placement" class="bg-white/60 p-3 rounded-lg border border-emerald-200/50">
                    <span class="font-bold text-emerald-800 text-xs uppercase tracking-wider block mb-1">Placement & Sécurité</span>
                    <p class="text-emerald-900 text-sm whitespace-pre-line leading-relaxed">{{ workshop.exercises.placement }}</p>
                  </div>

                  <div v-if="workshop.show_respiration && workshop.exercises?.respiration" class="bg-white/60 p-3 rounded-lg border border-emerald-200/50">
                    <span class="font-bold text-emerald-800 text-xs uppercase tracking-wider block mb-1">Respiration</span>
                    <p class="text-emerald-900 text-sm whitespace-pre-line leading-relaxed">{{ workshop.exercises.respiration }}</p>
                  </div>
               </div>
            </div>

          </div>
        </div>
      </div>


      <!-- Notebook (Carnet) Tab -->
      <!-- Notebook (Carnet) Tab -->
      <div v-else-if="activeTab === 'notebook'" class="space-y-6">
         <!-- Performer Tabs (if multiple members) -->
         <div v-if="groupMembers.length > 1" class="flex p-1 bg-gray-100 rounded-xl space-x-1">
            <button
              v-for="member in groupMembers"
              :key="member"
              @click="activePerformer = member"
              class="flex-1 py-2 px-4 rounded-lg text-sm font-medium transition-all"
              :class="activePerformer === member ? 'bg-white text-emerald-700 shadow-sm' : 'text-gray-500 hover:text-gray-700'"
            >
              {{ member }}
            </button>
         </div>

         <!-- Coach Select -->
         <div class="bg-white border border-gray-200 rounded-xl p-4 shadow-sm">
            <label class="block text-sm font-bold text-gray-700 mb-2">Coach pour {{ activePerformer }} :</label>
            <select v-model="selectedCoach" class="w-full bg-gray-50 border border-gray-300 rounded-lg px-3 py-2 text-gray-900 focus:outline-none focus:ring-2 focus:ring-emerald-500">
               <option value="" disabled>Sélectionner un coach...</option>
               <option 
                 v-for="m in groupMembers.filter(n => n !== activePerformer)" 
                 :key="m" 
                 :value="m"
               >
                 {{ m }}
               </option>
            </select>
         </div>

         <!-- Notebook Table -->
         <div class="bg-white border border-gray-200 rounded-xl overflow-hidden shadow-sm">

            <!-- Mobile Card View (Visible on small screens) -->
            <div class="md:hidden divide-y divide-gray-100">
               <div 
                  v-for="workshop in orderedWorkshops" 
                  :key="workshop.id" 
                  class="p-4 space-y-3"
               >
                  <div class="flex items-center space-x-3 mb-2">
                     <span class="w-8 h-8 rounded-full bg-emerald-100 text-emerald-700 flex items-center justify-center font-bold text-sm border border-emerald-200 shrink-0">
                       {{ workshops.findIndex(w => w.id === workshop.id) + 1 }}
                     </span>
                     <h4 class="font-bold text-gray-900 leading-tight">{{ workshop.exercises?.name }}</h4>
                  </div>

                  <div class="grid grid-cols-2 gap-3 text-sm">
                     <div v-if="roomConfig.notebook_visible_level" class="col-span-2">
                        <label class="block text-xs uppercase text-gray-400 font-bold mb-1">Niveau</label>
                           <select 
                             v-model="getEntry(workshop.id).level_selected" 
                             @change="updateEntry(workshop.id)"
                             class="w-full text-sm bg-white border border-gray-300 rounded-lg px-2 py-2 focus:ring-1 focus:ring-emerald-500"
                           >
                              <option value="">--</option>
                              <option value="Niveau 1">Niveau 1</option>
                              <option value="Niveau 2">Niveau 2</option>
                              <option value="Niveau 3">Niveau 3</option>
                           </select>
                     </div>

                     <div v-if="roomConfig.notebook_visible_placement" class="col-span-2">
                        <label class="block text-xs uppercase text-gray-400 font-bold mb-1">Placement</label>
                        <CounterInput 
                             v-model="getEntry(workshop.id).placement_errors"
                             @update:modelValue="updateEntry(workshop.id)" 
                        />
                     </div>

                     <div v-if="roomConfig.notebook_visible_tempo" class="col-span-2">
                        <label class="block text-xs uppercase text-gray-400 font-bold mb-1">Tempo</label>
                        <CounterInput 
                             v-model="getEntry(workshop.id).tempo_errors"
                             @update:modelValue="updateEntry(workshop.id)" 
                        />
                     </div>

                     <div v-if="roomConfig.notebook_visible_respiration" class="col-span-2">
                        <label class="block text-xs uppercase text-gray-400 font-bold mb-1">Respiration</label>
                        <CounterInput 
                             v-model="getEntry(workshop.id).respiration_errors"
                             @update:modelValue="updateEntry(workshop.id)" 
                        />
                     </div>

                     <div v-if="roomConfig.notebook_visible_feeling" class="col-span-2">
                        <label class="block text-xs uppercase text-gray-400 font-bold mb-1">Ressentis</label>
                           <select 
                             v-model="getEntry(workshop.id).feeling" 
                             @change="updateEntry(workshop.id)"
                             class="w-full text-sm bg-white border border-gray-300 rounded-lg px-2 py-2 focus:ring-1 focus:ring-emerald-500 font-medium"
                             :class="{
                               'text-emerald-700 bg-emerald-50 border-emerald-200': getEntry(workshop.id).feeling == 1 || getEntry(workshop.id).feeling == 2,
                               'text-amber-700 bg-amber-50 border-amber-200': getEntry(workshop.id).feeling == 3 || getEntry(workshop.id).feeling == 4,
                               'text-red-700 bg-red-50 border-red-200': getEntry(workshop.id).feeling == 5
                             }"
                           >
                              <option :value="null">--</option>
                              <option :value="1">1 - Très facile</option>
                              <option :value="2">2 - Effort léger</option>
                              <option :value="3">3 - Effort un peu dur</option>
                              <option :value="4">4 - Effort difficile</option>
                              <option :value="5">5 - Effort maximal</option>
                           </select>
                     </div>
                  </div>
               </div>
            </div>

            <div class="hidden md:block overflow-x-auto">
               <table class="w-full text-sm text-left">
                  <thead class="text-xs text-gray-700 uppercase bg-gray-50 border-b border-gray-200">
                     <tr>
                        <th class="px-4 py-3 min-w-[120px]">Atelier</th>
                        <th v-if="roomConfig.notebook_visible_level" class="px-2 py-3 min-w-[100px] text-center">Niveau</th>
                        <th v-if="roomConfig.notebook_visible_placement" class="px-2 py-3 min-w-[100px] text-center">Placement</th>
                        <th v-if="roomConfig.notebook_visible_tempo" class="px-2 py-3 min-w-[100px] text-center">Tempo</th>
                        <th v-if="roomConfig.notebook_visible_respiration" class="px-2 py-3 min-w-[100px] text-center">Respiration</th>
                        <th v-if="roomConfig.notebook_visible_feeling" class="px-2 py-3 min-w-[120px] text-center">Ressentis</th>
                     </tr>
                  </thead>
                  <tbody>
                     <tr v-for="workshop in orderedWorkshops" :key="workshop.id" class="border-b border-gray-100 last:border-0 hover:bg-gray-50">
                        <!-- Workshop Name -->
                        <td class="px-4 py-3 font-medium text-gray-900">
                           <div class="flex items-center space-x-2">
                             <div class="w-6 h-6 rounded-full bg-emerald-100 text-emerald-800 flex items-center justify-center font-bold text-xs border border-emerald-200">
                               {{ workshops.findIndex(w => w.id === workshop.id) + 1 }}
                             </div>
                             <span>{{ workshop.exercises?.name }}</span>
                           </div>
                        </td>

                        <!-- Level -->
                        <td v-if="roomConfig.notebook_visible_level" class="px-2 py-3 text-center">
                           <select 
                             v-model="getEntry(workshop.id).level_selected" 
                             @change="updateEntry(workshop.id)"
                             class="w-full text-xs bg-white border border-gray-300 rounded px-1 py-1 focus:ring-1 focus:ring-emerald-500"
                           >
                              <option value="">--</option>
                              <option value="Niveau 1">Niveau 1</option>
                              <option value="Niveau 2">Niveau 2</option>
                              <option value="Niveau 3">Niveau 3</option>
                           </select>
                        </td>

                        <!-- Placement -->
                        <!-- Placement -->
                        <td v-if="roomConfig.notebook_visible_placement" class="px-2 py-3">
                           <CounterInput 
                             v-model="getEntry(workshop.id).placement_errors"
                             @update:modelValue="updateEntry(workshop.id)" 
                           />
                        </td>

                        <!-- Tempo -->
                        <!-- Tempo -->
                        <td v-if="roomConfig.notebook_visible_tempo" class="px-2 py-3">
                           <CounterInput 
                             v-model="getEntry(workshop.id).tempo_errors"
                             @update:modelValue="updateEntry(workshop.id)" 
                           />
                        </td>

                        <!-- Respiration -->
                        <!-- Respiration -->
                        <td v-if="roomConfig.notebook_visible_respiration" class="px-2 py-3">
                           <CounterInput 
                             v-model="getEntry(workshop.id).respiration_errors"
                             @update:modelValue="updateEntry(workshop.id)" 
                           />
                        </td>

                        <!-- Ressentis (RPE) -->
                        <td v-if="roomConfig.notebook_visible_feeling" class="px-2 py-3">
                           <select 
                             v-model="getEntry(workshop.id).feeling" 
                             @change="updateEntry(workshop.id)"
                             class="w-full text-xs bg-white border border-gray-300 rounded px-1 py-1.5 focus:ring-1 focus:ring-emerald-500 font-medium"
                             :class="{
                               'text-emerald-700 bg-emerald-50 border-emerald-200': getEntry(workshop.id).feeling == 1 || getEntry(workshop.id).feeling == 2,
                               'text-amber-700 bg-amber-50 border-amber-200': getEntry(workshop.id).feeling == 3 || getEntry(workshop.id).feeling == 4,
                               'text-red-700 bg-red-50 border-red-200': getEntry(workshop.id).feeling == 5
                             }"
                           >
                              <option :value="null">--</option>
                              <option :value="1">1 - Très facile</option>
                              <option :value="2">2 - Effort léger</option>
                              <option :value="3">3 - Effort un peu dur</option>
                              <option :value="4">4 - Effort difficile</option>
                              <option :value="5">5 - Effort maximal</option>
                           </select>
                        </td>
                     </tr>
                  </tbody>
               </table>
            </div>

      </div>
      </div>
      </div>

    </main>
    
    <!-- Bottom Navigation -->
    <div class="fixed bottom-0 left-0 right-0 bg-white border-t border-gray-200 pb-safe z-50 flex justify-around items-center h-20 shadow-[0_-4px_6px_-1px_rgba(0,0,0,0.05)]">
      <button 
        @click="activeTab = 'workshops'"
        class="flex flex-col items-center justify-center w-full h-full space-y-1.5 transition-colors duration-200"
        :class="activeTab === 'workshops' ? 'text-emerald-600 bg-emerald-50/50' : 'text-gray-400 hover:text-gray-600 hover:bg-gray-50'"
      >
        <Dumbbell :size="28" :stroke-width="activeTab === 'workshops' ? 2.5 : 2" />
        <span class="text-xs font-bold uppercase tracking-wider">Ateliers</span>
      </button>

      <button 
        @click="activeTab = 'notebook'"
        class="flex flex-col items-center justify-center w-full h-full space-y-1.5 transition-colors duration-200"
        :class="activeTab === 'notebook' ? 'text-emerald-600 bg-emerald-50/50' : 'text-gray-400 hover:text-gray-600 hover:bg-gray-50'"
      >
        <ClipboardList :size="28" :stroke-width="activeTab === 'notebook' ? 2.5 : 2" />
        <span class="text-xs font-bold uppercase tracking-wider">Carnet</span>
      </button>
    </div>


    <!-- Muscle Sheet FAB -->
    <button 
      @click="showMuscleSheet = true"
      class="fixed bottom-24 right-4 bg-white hover:bg-gray-50 text-white w-14 h-14 md:w-16 md:h-16 rounded-full shadow-2xl shadow-emerald-900/20 transition-all hover:scale-110 active:scale-95 z-40 flex items-center justify-center border-4 border-white overflow-hidden"
      title="Fiche Muscle"
    >
      <img src="/muscle-icon.png" alt="Muscles" class="w-full h-full object-cover" />
    </button>

    <!-- Muscle Sheet Modal -->
    <div v-if="showMuscleSheet" class="fixed inset-0 z-[60] flex items-center justify-center p-4 bg-black/80 backdrop-blur-sm" @click.self="showMuscleSheet = false">
       <div class="bg-white rounded-xl w-full max-w-4xl max-h-[90vh] overflow-hidden flex flex-col relative animate-in zoom-in-95 duration-200">
          <button @click="showMuscleSheet = false" class="absolute top-4 right-4 bg-white/90 p-2 rounded-full shadow-lg text-gray-800 hover:bg-gray-100 mb-4 z-10 transition-colors">
             <X :size="24" />
          </button>
          <div class="overflow-y-auto p-4 flex items-center justify-center h-full">
             <img src="/muscle-sheet.png" alt="Fiche Muscle" class="w-full h-auto object-contain max-h-[85vh]" />
          </div>
       </div>
    </div>


    <!-- Feedback Modal (Replaces Alert) -->
    <div v-if="feedbackState.isVisible" class="fixed inset-0 z-[70] flex items-center justify-center p-4 bg-black/60 backdrop-blur-sm animate-in fade-in duration-200">
       <div class="bg-white rounded-2xl w-full max-w-sm p-6 shadow-2xl transform transition-all scale-100 animate-in zoom-in-95 duration-200">
          <div class="flex flex-col items-center text-center space-y-4">
             <div class="p-4 rounded-full" :class="feedbackState.type === 'success' ? 'bg-emerald-100 text-emerald-600' : 'bg-amber-100 text-amber-600'">
                <Trophy v-if="feedbackState.type === 'success'" :size="32" />
                <AlertTriangle v-else :size="32" />
             </div>
             
             <div>
                <h3 class="text-xl font-bold text-gray-900 mb-1">{{ feedbackState.title }}</h3>
                <p class="text-gray-600 text-sm leading-relaxed">{{ feedbackState.message }}</p>
             </div>

             <button 
               @click="feedbackState.isVisible = false"
               class="w-full py-3 rounded-xl font-bold text-white shadow-lg transition-transform active:scale-95"
               :class="feedbackState.type === 'success' ? 'bg-emerald-600 hover:bg-emerald-700 shadow-emerald-600/20' : 'bg-amber-600 hover:bg-amber-700 shadow-amber-600/20'"
             >
               Continuer
             </button>
          </div>
       </div>
    </div>
    
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onBeforeUnmount, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { supabase } from '../../supabase'
import { calculateTimerState, TIMER_COLORS } from '../../utils/timer'
import { useStudentStore } from '../../stores/student'
import { MUSCLE_LIST } from '../../constants/muscles'
import { User, Timer, Trophy, Loader2, CheckCircle2, LogOut, RotateCcw, Play, Pause, Info, X, FileText, ChevronDown, Target, ClipboardList, Shield, Clock, Wind, AlertTriangle } from 'lucide-vue-next'
import CounterInput from '../../components/CounterInput.vue'

const route = useRoute()
const router = useRouter()
const studentStore = useStudentStore()
const studentInfo = computed(() => studentStore.studentInfo)

if (!studentInfo.value) {
  router.push('/student/join')
}

const workshops = ref([])
const muscleList = MUSCLE_LIST

const getMuscleStyle = (muscle, isSelected) => {
  if (isSelected) {
    return 'bg-emerald-600 text-white font-bold ring-2 ring-emerald-600 shadow-md transform scale-[1.02]'
  }
  return 'bg-white text-gray-700 border border-gray-200 hover:bg-gray-50 hover:border-gray-300 transition-colors'
}
const answers = ref({})
const solvedWorkshops = ref(new Set())
const workshopPoints = ref({})

const currentScore = ref(0) 
const showMuscleSheet = ref(false)
const openDropdown = ref(null)
const activeTab = ref('workshops')

const roomConfig = ref({})
const notebookEntries = ref({})
// const otherStudents = ref([]) // Removed as requested
const selectedCoach = ref('')

// Group Logic
const groupMembers = computed(() => {
  if (!studentInfo.value?.name) return []
  return studentInfo.value.name.split(' & ').map(s => s.trim())
})
const activePerformer = ref('') // The member tab currently selected

// Timer Logic
const time = ref(0)
const timerRunning = ref(false)
let timerInterval = ref(null)

// Global Timer Logic
const timerConfig = ref({ repeats: 1, phases: [] })
const timerState = ref({ state: 'idle', start_timestamp: null, paused_timestamp: null, elapsed_before_pause: 0 })
const localTimerCalc = ref({})
const startWorkshopId = ref(null)
const playingVideoId = ref(null)
const feedbackState = ref({ isVisible: false, title: '', message: '', type: 'success' })
const takenWorkshopIds = ref(new Set())

const orderedWorkshops = computed(() => {
  if (!startWorkshopId.value || workshops.value.length === 0) return []
  
  const startIdx = workshops.value.findIndex(w => w.id === startWorkshopId.value)
  if (startIdx === -1) return workshops.value

  const ordered = [
    ...workshops.value.slice(startIdx),
    ...workshops.value.slice(0, startIdx)
  ]
  
  // Return only the current one based on index loop
  const index = currentWorkshopIndex.value % ordered.length
  return [ordered[index]]
})

const currentWorkshopIndex = ref(0) // Tracks local progress in the loop


const setStartWorkshop = async (wId) => {
   startWorkshopId.value = wId
   // Save to DB
   await supabase.from('students').update({ start_workshop_id: wId }).eq('id', studentInfo.value.id)
}

let globalTimerInterval
let syncPollingInterval // Backup polling

const getTimerBgClass = (phase) => {
   if (!phase) return 'bg-gray-100'
   return TIMER_COLORS.find(c => c.value === phase.color)?.light || 'bg-gray-100'
}
const getTimerTextClass = (phase) => {
   if (!phase) return 'text-gray-600'
   return TIMER_COLORS.find(c => c.value === phase.color)?.text || 'text-gray-900'
}
const formatGlobalTime = (ms) => {
   if (ms <= 0) return '00:00'
   const totalSec = Math.ceil(ms / 1000)
   const m = Math.floor(totalSec / 60)
   const s = totalSec % 60
   return `${m.toString().padStart(2, '0')}:${s.toString().padStart(2, '0')}`
}
const formattedTime = computed(() => {
  const m = Math.floor(time.value / 60).toString().padStart(2, '0')
  const s = (time.value % 60).toString().padStart(2, '0')
  return `${m}:${s}`
})

const toggleTimer = () => {
  if (timerRunning.value) {
    clearInterval(timerInterval.value)
  } else {
    timerInterval.value = setInterval(() => time.value++, 1000)
  }
  timerRunning.value = !timerRunning.value
}

const resetTimer = () => {
  clearInterval(timerInterval.value)
  time.value = 0
  timerRunning.value = false
}

// Data Fetching
const fetchWorkshops = async () => {
  console.log("Fetching workshops for room:", route.params.id)
  const { data, error } = await supabase
    .from('workshops')
    .select('*, exercises(*), show_placement, show_respiration, show_tempo')
    .eq('room_id', route.params.id)
    .order('order_index')
  
  if (error) {
    console.error("Error fetching workshops:", error)
    return
  }

  if (data) {
    console.log("Workshops data:", data)
    data.forEach(w => {
       console.log(`Workshop ${w.id}: show_p=${w.show_placement}, show_t=${w.show_tempo}, show_r=${w.show_respiration}`)
       console.log(`Exercise Content:`, w.exercises)
    })
    workshops.value = data
    data.forEach(w => {
      if (!answers.value[w.id]) {
        answers.value[w.id] = { principal: '', secondaire: '', tertiaire: '' }
      }
    })
  }
}

const isComplete = (workshopId) => {
  const a = answers.value[workshopId]
  return a && a.principal && a.secondaire && a.tertiaire
}

// Validation Logic
const submitWorkshop = async (workshop) => {
  // if (!confirm('Confirmer vos réponses ? Vous ne pourrez plus modifier.')) return

  const userRes = answers.value[workshop.id]
  let points = 0
  
  const normalize = (s) => s?.toLowerCase().trim()
  
  const expected = {
    p: normalize(workshop.muscle_primary),
    s: normalize(workshop.muscle_secondary),
    t: normalize(workshop.muscle_tertiary)
  }
  
  const actual = {
    p: normalize(userRes.principal),
    s: normalize(userRes.secondaire),
    t: normalize(userRes.tertiaire)
  }

  const pMatch = expected.p === actual.p
  const sMatch = expected.s === actual.s
  const tMatch = expected.t === actual.t

  if (pMatch && sMatch && tMatch) {
    points = 100
  } else {
    if (pMatch) points += 10
    if (sMatch) points += 5
    if (tMatch) points += 3
    
    const allExpected = [expected.p, expected.s, expected.t].filter(Boolean)
    
    if (!pMatch && allExpected.includes(actual.p)) points += 1
    if (!sMatch && allExpected.includes(actual.s)) points += 1
    if (!tMatch && allExpected.includes(actual.t)) points += 1
  }

  // Differential Scoring Logic
  const previousPoints = workshopPoints.value[workshop.id] || 0
  const pointDelta = points - previousPoints
  
  if (pointDelta !== 0) {
     currentScore.value += pointDelta
     workshopPoints.value[workshop.id] = points // Update to new score
     
     // Update DB
     await supabase
      .from('students')
      .update({ score: currentScore.value })
      .eq('id', studentInfo.value.id)
      
     if (pointDelta > 0) {
        showFeedback('Bravo !', `Vous avez gagné ${pointDelta} points supplémentaires.`, 'success')
     } else if (pointDelta < 0) {
        showFeedback('Attention', `Votre nouveau score est inférieur (${pointDelta} pts).`, 'warning')
     } else {
        showFeedback('Mis à jour', 'Vos réponses ont été enregistrées (score inchangé).', 'success')
     }
  } else {
     showFeedback('Mis à jour', 'Vos réponses ont été enregistrées (score inchangé).', 'success')
  }
  
  solvedWorkshops.value.add(workshop.id)

  // Auto advance
  currentWorkshopIndex.value++ 
  window.scrollTo({ top: 0, behavior: 'smooth' })
}

const showFeedback = (title, message, type = 'success') => {
   feedbackState.value = { isVisible: true, title, message, type }
}

const isYoutube = (url) => {
  return url && (url.includes('youtube.com') || url.includes('youtu.be'))
}

const getEmbedUrl = (url) => {
  if (!url) return ''
  let videoId = ''
  
  try {
    // Handle m.youtube.com, youtube.com, youtu.be
    const cleanUrl = url.replace('m.youtube.', 'youtube.')
    const urlObj = new URL(cleanUrl)

    if (cleanUrl.includes('youtu.be')) {
       videoId = cleanUrl.split('/').pop().split('?')[0]
    } else if (cleanUrl.includes('youtube.com')) {
       if (urlObj.pathname.includes('/embed/')) {
          return cleanUrl // Already embed url
       }
       if (urlObj.pathname.includes('/shorts/')) {
          videoId = urlObj.pathname.split('/shorts/')[1]
       } else {
          videoId = urlObj.searchParams.get('v')
       }
    }
  } catch (e) {
    // Fallback for simple youtu.be if URL parsing fails
    if (url.includes('youtu.be')) {
       videoId = url.split('/').pop().split('?')[0]
    } else {
       console.error("Error parsing Youtube URL:", e)
       return url
    }
  }
  
  return videoId ? `https://www.youtube.com/embed/${videoId}?autoplay=1&rel=0&modestbranding=1` : url
}

// Notebook Logic
const getEntry = (workshopId) => {
  if (!notebookEntries.value[workshopId]) {
    notebookEntries.value[workshopId] = {
      level_selected: '',
      placement_errors: 0,
      tempo_errors: 0,
      respiration_errors: 0,
      feeling: null
    }
  }
  return notebookEntries.value[workshopId]
}

const updateEntry = async (workshopId) => {
  const entry = notebookEntries.value[workshopId]
  if (!activePerformer.value) return

  const { error } = await supabase
    .from('notebook_entries')
    .upsert({
      student_id: studentInfo.value.id, // Group ID
      room_id: route.params.id,
      workshop_id: workshopId,
      performer_name: activePerformer.value, // Specific member
      coach_name: selectedCoach.value,
      level_selected: entry.level_selected,
      placement_errors: entry.placement_errors,
      tempo_errors: entry.tempo_errors,
      respiration_errors: entry.respiration_errors,
      feeling: entry.feeling
    }, { onConflict: 'student_id, workshop_id, performer_name' })
    
  if (error) console.error("Error saving notebook:", error)
}

const fetchNotebookEntries = async () => {
  if (!activePerformer.value) return 
  
  // Clear entries locally
  // Note: ideally we might want to cache per performer but simpler to refetch/clear for now
  notebookEntries.value = {}

  console.log("Fetching notebook for performer:", activePerformer.value)
  const { data: entries } = await supabase
    .from('notebook_entries')
    .select('*')
    .eq('student_id', studentInfo.value.id)
    .eq('room_id', route.params.id)
    .eq('performer_name', activePerformer.value)
  
  if (entries) {
    entries.forEach(e => {
       notebookEntries.value[e.workshop_id] = e
       if (e.coach_name) selectedCoach.value = e.coach_name
    })
  } else {
     selectedCoach.value = ''
  }
}

const fetchTakenWorkshops = async () => {
  const { data, error } = await supabase
    .from('students')
    .select('start_workshop_id')
    .eq('room_id', route.params.id)
    .not('start_workshop_id', 'is', null)

  if (data) {
    const taken = data.map(s => s.start_workshop_id)
    takenWorkshopIds.value = new Set(taken)
  }
}

const subscribeToRoom = () => {
  supabase
    .channel(`room-locks-${route.params.id}`)
    .on(
      'postgres_changes', 
      { event: '*', schema: 'public', table: 'students', filter: `room_id=eq.${route.params.id}` }, 
      () => fetchTakenWorkshops()
    )
    .subscribe()
}

const handleBeforeUnload = (e) => {
  e.preventDefault()
  e.returnValue = ''
}

const leaveSession = () => {
  if (!confirm("Voulez-vous vraiment quitter ? Votre score sera perdu.")) return
  sessionStorage.removeItem('student')
  router.push('/')
}

watch(activePerformer, async (newVal) => {
  if (newVal) {
     // Assuming fetchNotebookEntries is defined above line 957
     // If not, we might need to redefine it, but based on view_file it should be there.
     // However, to be safe, I'll ensure we call it if it exists.
     try {
       // We can iterate notebookEntries if needed or just rely on existing logic
        const { data: entries } = await supabase
        .from('notebook_entries')
        .select('*')
        .eq('student_id', studentInfo.value.id)
        .eq('room_id', route.params.id)
        .eq('performer_name', newVal)
      
      if (entries) {
        entries.forEach(e => {
           if (notebookEntries.value) notebookEntries.value[e.workshop_id] = e
           if (e.coach_name) selectedCoach.value = e.coach_name
        })
      }
     } catch (e) { console.error(e) }
  }
})

onMounted(async () => {
  const roomId = route.params.id
  window.addEventListener('beforeunload', handleBeforeUnload)
  
  // Set initial Performer
  if (groupMembers.value.length > 0 && !activePerformer.value) {
     activePerformer.value = groupMembers.value[0]
  }

  await Promise.all([
    fetchWorkshops(),
    fetchTakenWorkshops()
  ])

  // Timer Subscription
  supabase
    .channel(`room-timer-${roomId}`)
    .on(
      'postgres_changes',
      { event: '*', schema: 'public', table: 'rooms', filter: `id=eq.${roomId}` },
      (payload) => {
        if (payload.new) {
          syncTimer(payload.new)
        }
      }
    )
    .subscribe()

  // Locks Subscription
  subscribeToRoom()

  // Initial Room Data (Timer & Config)
  const { data: roomData } = await supabase.from('rooms').select('*').eq('id', roomId).single()
  if (roomData) {
     syncTimer(roomData)
     roomConfig.value = roomData
  }

  // Fetch My Start Workshop
  if (studentInfo.value?.id) {
     const { data: studentData } = await supabase.from('students').select('start_workshop_id').eq('id', studentInfo.value.id).single()
     if (studentData?.start_workshop_id) {
        startWorkshopId.value = studentData.start_workshop_id
     }
  }

  // Timers
  globalTimerInterval = setInterval(() => {
     if (localTimerCalc.value.isRunning && localTimerCalc.value.remainingInPhase > 0) {
        localTimerCalc.value.remainingInPhase -= 1000
        if (localTimerCalc.value.remainingInPhase < 0) localTimerCalc.value.remainingInPhase = 0
     } else if (localTimerCalc.value.isRunning) {
        localTimerCalc.value = calculateTimerState(timerConfig.value, timerState.value)
     }
  }, 1000)

  syncPollingInterval = setInterval(async () => {
     const { data } = await supabase.from('rooms').select('*').eq('id', roomId).single()
     if (data) syncTimer(data)
  }, 10000) 
})

onBeforeUnmount(() => {
  window.removeEventListener('beforeunload', handleBeforeUnload)
  if (globalTimerInterval) clearInterval(globalTimerInterval)
  if (syncPollingInterval) clearInterval(syncPollingInterval)
  if (timerInterval.value) clearInterval(timerInterval.value)
  supabase.removeAllChannels()
})
</script>
```
