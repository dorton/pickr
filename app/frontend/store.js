import { createStore } from 'vuex'

export const store = createStore({
    state () {
      return {
        saved_games: null,
        saved_picks: null,
        admin_override: false,
        weekly_picks: [],
        weekly_games: [],
        config: {
            headers: {
              "Content-Type": "application/json",
              "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content,
            }
          }
      }
    },
    mutations: {
      setSavedGames (state, payload) {
        state.saved_games = payload
      },  
      setSavedPicks (state, payload) {
        state.saved_picks = payload
      },  
      setAdminOverride (state, payload) {
        state.admin_override = payload
      },
      setWeeklyPicks (state, payload) {
        state.weekly_picks = payload
      },
      pushWeeklyPicks (state, payload) {
        state.weekly_picks.push(payload)
      },
      spliceWeeklyPicks (state, payload) {
        state.weekly_picks.splice(payload.index, 1, payload.pick)
      },
      setWeeklyGames (state, payload) {
        state.weekly_games = payload
      },
      pushWeeklyGames (state, payload) {
        state.weekly_games.push(payload)
      },
      spliceWeeklyGames (state, index) {
        state.weekly_games.splice(index, 1)
      },
    }
  })