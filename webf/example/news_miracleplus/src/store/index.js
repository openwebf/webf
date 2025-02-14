import { createStore } from 'vuex'
import state from './state'
import mutations from './mutations'
import actions from './actions'
import user from './modules/user'

export default createStore({
  state,
  mutations,
  actions,
  modules: {
    user,
  }
}) 