export default {
  setLoading({ commit }, status) {
    commit('SET_LOADING', status)
  },
  setError({ commit }, message) {
    commit('SET_ERROR', message)
  }
} 