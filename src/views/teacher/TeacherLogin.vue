<template>
  <div class="flex items-center justify-center min-h-screen bg-gray-50 px-4">
    <div class="w-full max-w-md">
      <!-- Card -->
      <div class="bg-white border-2 border-gray-100 rounded-2xl shadow-xl shadow-gray-200/50 overflow-hidden">
        <div class="p-8 space-y-8">
          
          <!-- Header -->
          <div class="text-center space-y-2">
            <div class="inline-flex items-center justify-center w-12 h-12 rounded-full bg-emerald-100 text-emerald-700 ring-4 ring-emerald-50 mb-4">
              <Lock :size="24" />
            </div>
            <h1 class="text-2xl font-bold text-gray-900 tracking-tight">Accès Enseignant</h1>
            <p class="text-gray-500 text-sm">Veuillez entrer le mot de passe administrateur pour continuer.</p>
          </div>

          <!-- Form -->
          <form @submit.prevent="handleLogin" class="space-y-6">
            <div class="space-y-2">
              <label for="password" class="text-sm font-bold text-gray-700">Mot de passe</label>
              <div class="relative">
                <input 
                  type="password" 
                  id="password" 
                  v-model="password"
                  class="w-full bg-gray-50 border border-gray-200 rounded-lg px-4 py-3 pl-10 text-gray-900 placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 transition-all font-mono"
                  placeholder="••••••••"
                  required
                />
                <Key :size="16" class="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" />
              </div>
              <p v-if="error" class="text-red-500 text-xs flex items-center mt-1 animate-pulse">
                <AlertCircle :size="12" class="mr-1" />
                {{ error }}
              </p>
            </div>

            <button 
              type="submit" 
              class="w-full bg-emerald-700 hover:bg-emerald-800 text-white font-bold py-3 px-4 rounded-lg shadow-lg shadow-emerald-700/20 transition-all duration-200 focus:ring-2 focus:ring-offset-2 focus:ring-offset-white focus:ring-emerald-600 flex items-center justify-center"
              :disabled="isLoading"
            >
              <span v-if="!isLoading">Se connecter</span>
              <Loader2 v-else class="animate-spin" :size="20" />
            </button>
          </form>

          <!-- Footer -->
          <div class="text-center">
            <router-link to="/" class="text-gray-500 hover:text-gray-800 text-sm transition-colors flex items-center justify-center font-medium">
              <ArrowLeft :size="14" class="mr-1" />
              Retour au menu
            </router-link>
          </div>

        </div>
        
        <!-- Decoration -->
        <div class="h-1.5 w-full bg-gradient-to-r from-emerald-600 to-green-800"></div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '../../stores/auth'
import { Lock, Key, AlertCircle, Loader2, ArrowLeft } from 'lucide-vue-next'

const password = ref('')
const error = ref('')
const isLoading = ref(false)
const router = useRouter()
const authStore = useAuthStore()

const handleLogin = async () => {
  error.value = ''
  isLoading.value = true
  
  // Simulate network delay for UX
  setTimeout(() => {
    if (authStore.login(password.value)) {
      router.push('/teacher/dashboard')
    } else {
      error.value = 'Mot de passe incorrect'
      password.value = ''
    }
    isLoading.value = false
  }, 600)
}
</script>
