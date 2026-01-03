<template>
  <div class="min-h-screen bg-gray-50 flex flex-col">
    <!-- Navbar -->
    <header class="bg-white border-b border-gray-200 sticky top-0 z-50">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex justify-between items-center h-16">
          <div class="flex items-center space-x-3">
            <div class="bg-emerald-100 p-2 rounded-lg text-emerald-700">
              <ShieldCheck :size="24" />
            </div>
            <span class="text-xl font-bold text-gray-900 tracking-tight">Espace Prof</span>
          </div>
          
          <button @click="logout" class="text-gray-500 hover:text-red-600 text-sm font-medium transition-colors flex items-center bg-gray-50 hover:bg-red-50 px-3 py-2 rounded-lg border border-gray-200 hover:border-red-200">
            <LogOut :size="16" class="mr-2" />
            Déconnexion
          </button>
        </div>
      </div>
    </header>

    <!-- Main Content -->
    <main class="flex-1 max-w-7xl w-full mx-auto px-4 sm:px-6 lg:px-8 py-8">
      
      <!-- Tabs -->
      <div class="flex space-x-1 bg-white p-1 rounded-xl mb-8 w-fit border border-gray-200 shadow-sm">
        <button 
          v-for="tab in tabs" 
          :key="tab.id"
          @click="currentTab = tab.id"
          :class="[
            'px-4 py-2 rounded-lg text-sm font-medium transition-all duration-200 flex items-center',
            currentTab === tab.id 
              ? 'bg-emerald-700 text-white shadow-md shadow-emerald-700/20' 
              : 'text-gray-500 hover:text-gray-900 hover:bg-gray-100'
          ]"
        >
          <component :is="tab.icon" :size="16" class="mr-2" />
          {{ tab.name }}
        </button>
      </div>

      <!-- Tab Content -->
      <div class="transition-all duration-300 ease-in-out">
        <keep-alive>
          <component :is="activeTabComponent" />
        </keep-alive>
      </div>

    </main>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '../../stores/auth'
import { ShieldCheck, LogOut, LayoutDashboard, Dumbbell, Users } from 'lucide-vue-next'
import RoomManager from './tabs/RoomManager.vue'
import ExerciseBank from './tabs/ExerciseBank.vue'
import TeacherClasses from './TeacherClasses.vue'

const router = useRouter()
const authStore = useAuthStore()

const tabs = [
  { id: 'rooms', name: 'Leçons', icon: LayoutDashboard },
  { id: 'exercises', name: 'Banque d\'exercices', icon: Dumbbell },
  { id: 'classes', name: 'Gestion de Classe', icon: Users },
]

const currentTab = ref('rooms')

const activeTabComponent = computed(() => {
  switch (currentTab.value) {
    case 'rooms': return RoomManager
    case 'exercises': return ExerciseBank
    case 'classes': return TeacherClasses
    default: return RoomManager
  }
})

const logout = () => {
  authStore.logout()
  router.push('/')
}
</script>
