import { defineStore } from 'pinia'
import { ref } from 'vue'
import { useRouter } from 'vue-router'

export const useAuthStore = defineStore('auth', () => {
    const isTeacherAuthenticated = ref(localStorage.getItem('isTeacherAuthenticated') === 'true')
    const router = useRouter()

    function login(password) {
        if (password === 'testeur5') {
            isTeacherAuthenticated.value = true
            localStorage.setItem('isTeacherAuthenticated', 'true')
            return true
        }
        return false
    }

    function logout() {
        isTeacherAuthenticated.value = false
        localStorage.removeItem('isTeacherAuthenticated')
        // Router might not be available here depending on call context, usually handled in component
    }

    return { isTeacherAuthenticated, login, logout }
})
