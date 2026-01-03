import { defineStore } from 'pinia'
import { ref } from 'vue'

export const useStudentStore = defineStore('student', () => {
    const studentInfo = ref(JSON.parse(sessionStorage.getItem('studentInfo')))

    function login(info) {
        studentInfo.value = info
        sessionStorage.setItem('studentInfo', JSON.stringify(info))
    }

    function logout() {
        studentInfo.value = null
        sessionStorage.removeItem('studentInfo')
    }

    return { studentInfo, login, logout }
})
