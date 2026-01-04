import { defineStore } from 'pinia'
import { ref } from 'vue'

export const useStudentStore = defineStore('student', () => {
    const studentInfo = ref(JSON.parse(localStorage.getItem('studentInfo')))

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
