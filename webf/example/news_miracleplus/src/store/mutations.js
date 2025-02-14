export default {
  SET_LOADING(state, status) {
    state.isLoading = status
  },
  SET_ERROR(state, message) {
    state.errorMessage = message
  }
} 