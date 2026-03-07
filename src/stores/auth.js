import { defineStore } from 'pinia'
import { ref } from 'vue'

export const useAuthStore = defineStore('auth', () => {
    const isTeacherAuthenticated = ref(localStorage.getItem('isTeacherAuthenticated') === 'true')

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
    }

    return { isTeacherAuthenticated, login, logout }
})
