import { createStore } from 'vuex'

export const store = createStore({
    state () {
      return {
        matchups: null,
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
      setMatchups (state, payload) {
        state.matchups = payload
      },
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
    },
    getters: {
      all_games_complete (state) {
        return state.weekly_games.map(a => a.status.type.completed).every(s => s)
      },
      all_games_pre (state) {
        return state.weekly_games.map(a => a.status.type.state).every(s => s === 'pre')
      },
      getRemoteFromSaved: (state) => (saved_game) => {
        return state.matchups.events.find(s => s.id === saved_game.remote_game_id.toString())
      },

    },
    actions: {}
  })