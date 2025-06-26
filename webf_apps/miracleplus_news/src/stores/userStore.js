import { defineStore } from 'pinia'

export const useUserStore = defineStore('user', {
  state: () => ({
    userInfo: JSON.parse(localStorage.getItem('userInfo')) || null
  }),
  actions: {
    setUserInfo(userData) {
      this.userInfo = userData
      localStorage.setItem('userInfo', JSON.stringify(userData))
    },
    clearUserInfo() {
      this.userInfo = null
      localStorage.removeItem('userInfo')
    }
  },
  getters: {
    isLoggedIn: (state) => !!state.userInfo,
    userName: (state) => state.userInfo?.name || '',
    userAvatar: (state) => state.userInfo?.avatar || ''
  }
})