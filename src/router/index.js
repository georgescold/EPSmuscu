import { createRouter, createWebHistory } from 'vue-router'
import HomeView from '../views/HomeView.vue'

const router = createRouter({
    history: createWebHistory(import.meta.env.BASE_URL),
    routes: [
        {
            path: '/',
            name: 'home',
            component: HomeView
        },
        {
            path: '/teacher/login',
            name: 'teacher-login',
            component: () => import('../views/teacher/TeacherLogin.vue')
        },
        {
            path: '/teacher/dashboard',
            name: 'teacher-dashboard',
            component: () => import('../views/teacher/TeacherDashboard.vue'),
            meta: { requiresAuth: true }
        },
        {
            path: '/teacher/room/:id',
            name: 'teacher-room-detail',
            component: () => import('../views/teacher/RoomDetail.vue'),
            meta: { requiresAuth: true }
        },
        {
            path: '/student/join',
            name: 'student-join',
            component: () => import('../views/student/StudentJoin.vue')
        },
        {
            path: '/student/room/:id',
            name: 'student-room',
            component: () => import('../views/student/StudentRoom.vue'),
            // Meta guard could be added here to check studentStore
        }
    ]
})

router.beforeEach((to, from, next) => {
    if (to.meta.requiresAuth) {
        const isAuthenticated = sessionStorage.getItem('isTeacherAuthenticated') === 'true'
        if (!isAuthenticated) {
            next('/teacher/login')
        } else {
            next()
        }
    } else {
        next()
    }
})

export default router
