<template>
  <div class="flex flex-col items-center justify-center min-h-screen p-6 space-y-12 bg-gray-50">
    <!-- Header -->
    <div class="text-center space-y-4">
      <div class="flex justify-center mb-6">
        <Dumbbell :size="64" class="text-emerald-700 animate-pulse" />
      </div>
      <h1 class="text-5xl font-black tracking-tighter text-gray-900 uppercase italic pr-2">
        Muscu <span class="text-transparent bg-clip-text bg-gradient-to-r from-emerald-600 to-green-800">EPS</span>
      </h1>
      <p class="text-gray-600 text-lg max-w-md mx-auto">
        L'appli qui vous permettra d'aller à la salle en toute confiance
      </p>
    </div>

    <!-- Actions -->
    <div class="grid grid-cols-1 md:grid-cols-2 gap-6 w-full max-w-2xl">
      <!-- Student Card -->
      <router-link to="/student/join" class="group relative overflow-hidden bg-white hover:bg-gray-50 border-2 border-gray-200 hover:border-emerald-600 rounded-2xl p-8 transition-all duration-300 ease-out hover:-translate-y-1 hover:shadow-xl hover:shadow-emerald-900/10">
        <div class="absolute top-0 right-0 -mt-4 -mr-4 w-24 h-24 bg-emerald-100 rounded-full blur-2xl group-hover:bg-emerald-200 transition-all"></div>
        <div class="flex flex-col items-center text-center space-y-4">
          <div class="p-4 bg-emerald-50 rounded-full ring-1 ring-emerald-100 group-hover:bg-emerald-100 transition-all">
            <Users :size="32" class="text-emerald-700" />
          </div>
          <h2 class="text-2xl font-bold text-gray-900">Espace Élève</h2>
          <p class="text-gray-500 text-sm">Rejoindre un cours, participer aux ateliers et suivre sa progression.</p>
          <span class="inline-flex items-center text-emerald-700 font-bold text-sm mt-2 group-hover:translate-x-1 transition-transform">
            Rejoindre
            <ArrowRight :size="16" class="ml-1" />
          </span>
        </div>
      </router-link>

      <!-- Teacher Card -->
      <router-link to="/teacher/login" class="group relative overflow-hidden bg-white hover:bg-gray-50 border-2 border-gray-200 hover:border-sky-600 rounded-2xl p-8 transition-all duration-300 ease-out hover:-translate-y-1 hover:shadow-xl hover:shadow-sky-900/10">
        <div class="absolute top-0 right-0 -mt-4 -mr-4 w-24 h-24 bg-sky-100 rounded-full blur-2xl group-hover:bg-sky-200 transition-all"></div>
        <div class="flex flex-col items-center text-center space-y-4">
          <div class="p-4 bg-sky-50 rounded-full ring-1 ring-sky-100 group-hover:bg-sky-100 transition-all">
            <ShieldCheck :size="32" class="text-sky-700" />
          </div>
          <h2 class="text-2xl font-bold text-gray-900">Espace Prof</h2>
          <p class="text-gray-500 text-sm">Uniquement réservé à Mr Coquelle</p>
          <span class="inline-flex items-center text-sky-700 font-bold text-sm mt-2 group-hover:translate-x-1 transition-transform">
            Connexion
            <ArrowRight :size="16" class="ml-1" />
          </span>
        </div>
      </router-link>
    </div>

    <footer class="text-gray-400 text-xs text-center mt-12">
      &copy; 2025 Muscu EPS. Développé pour l'enseignement.
    </footer>
  </div>
</template>

<script setup>
import { Users, ShieldCheck, Dumbbell, ArrowRight } from 'lucide-vue-next'
</script>
