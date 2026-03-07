import { defineStore } from 'pinia'
import { ref } from 'vue'

export const useStudentStore = defineStore('student', () => {
    const studentInfo = ref(null)
    try {
        const stored = localStorage.getItem('studentInfo')
        if (stored && stored !== 'undefined') {
            studentInfo.value = JSON.parse(stored)
        }
    } catch (e) {
        console.error('Error parsing studentInfo:', e)
        localStorage.removeItem('studentInfo')
    }

    function login(info) {
        studentInfo.value = info
        localStorage.setItem('studentInfo', JSON.stringify(info))
    }

    function logout() {
        studentInfo.value = null
        localStorage.removeItem('studentInfo')
    }

    return { studentInfo, login, logout }
})
