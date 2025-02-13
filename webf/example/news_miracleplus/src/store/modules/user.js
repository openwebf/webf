export default {
  namespaced: true,
  state: {
    userInfo: null,
    token: null,
    isAuthenticated: false
  },
  mutations: {
    SET_USER_INFO(state, userInfo) {
      state.userInfo = userInfo
    },
    SET_TOKEN(state, token) {
      state.token = token
    },
    SET_AUTH_STATUS(state, status) {
      state.isAuthenticated = status
    }
  },
  actions: {
    login({ commit }, { token, user}) {
      // 实现登录逻辑
      commit('SET_TOKEN', token)
      commit('SET_USER_INFO', user)
      commit('SET_AUTH_STATUS', true)

      localStorage.setItem('token', token)
    },
    logout({ commit }) {
      commit('SET_USER_INFO', null)
      commit('SET_TOKEN', null)
      commit('SET_AUTH_STATUS', false)

      localStorage.removeItem('token')
    }
  },
  getters: {
    isLoggedIn: state => state.isAuthenticated,
    userInfo: state => state.userInfo,
    token: state => state.token,

    userName: state => state.userInfo?.name || '',
    userAvatar: state => state.userInfo?.avatar || '',
    userId: state => state.userInfo?.userId || ''
  }
} 