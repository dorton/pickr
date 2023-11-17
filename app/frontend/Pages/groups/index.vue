<template>
  <v-container fluid class="h-75">
    <v-row class="justify-center align-center">
      <v-col>
        <div class="d-flex justify-center">
          <div class="text-h4">{{ current_group.name }}</div>
        </div>
      </v-col>
      <v-col>
        <div class="d-flex justify-center">
          <div class="text-h4">{{ getCalendarDetail }}</div>
        </div>
      </v-col>
      <v-col class="d-none d-sm-flex">
        <v-select hide-details density="compact" flat single-line :items="calendars" item-value="value" item-title="label" v-model="selected_calendar"
          @update:modelValue="navToWeek"></v-select>
      </v-col>
    </v-row>
    <v-row class="d-sm-none">
      <v-col>
        <v-select hide-details density="compact" flat single-line :items="calendars" item-value="value" item-title="label" v-model="selected_calendar"
          @update:modelValue="navToWeek"></v-select>
      </v-col>
    </v-row>
    <v-row v-if="saved_games.length > 0">
      <v-table density="compact">
        <thead>
          <tr>
            <th colspan="2" v-if="saved_games.length > 0" class="text-left">
              <v-btn @click="szn_view = !szn_view">{{ szn_text }}</v-btn>
            </th>
            <th v-if="szn_view && saved_games.length > 0 && !all_games_pre" class="text-left"></th>
            <th :class="['text-center', handleBgColor(remote_game)]" v-for="remote_game in sorted_headers" :key="remote_game.id">
              <div class="text-body-2" v-if="!isComplete(remote_game)">
                <div v-if="gameState(remote_game) === 'pre'" class="d-flex flex-column">
                  <div class="score-wrapper">
                    {{ remote_game.shortName }}
                  </div>
                  <div class="description-wrapper">
                    <div> {{ getBroadcast(remote_game) }}</div>
                    <div>{{ getTime(remote_game.date) }}</div>
                  </div>
                </div>
                <div v-else :class="['d-flex', 'flex-column', 'ma-2', 'font-weight-bold']">
                  <div class="score-wrapper">
                    <div v-for="(homeAway,i) in ['away', 'home']" :key="i" class="d-flex justify-space-between">
                      <div class="">{{ getTeam(remote_game, homeAway) ? getTeam(remote_game, homeAway).team.abbreviation : 'No Game' }}</div>
                      <div class="ml-2">{{ getScore(remote_game, homeAway) }}</div>
                    </div>
                  </div>
                  <div class="description-wrapper text-no-wrap">
                    <div> {{ handleBroadcast(remote_game) }}</div>
                    <div>{{ remote_game.status.type.shortDetail }}</div>
                  </div>
                </div>
              </div>
              <div class="text-body-2 ma-2" v-if="isComplete(remote_game)">
                <div class="d-flex flex-column">
                  <div class="score-wrapper">
                    <div class="d-flex justify-space-between">
                      <div class="">{{ getTeam(remote_game, 'away') ? getTeam(remote_game, 'away').team.abbreviation : 'No Game' }}</div>
                      <div class="ml-2">{{ getScore(remote_game, 'away') }}</div>
                    </div>
                    <div class="d-flex justify-space-between">
                      <div class="">{{ getTeam(remote_game, 'home') ? getTeam(remote_game, 'home').team.abbreviation : 'No Game' }}</div>
                      <div class="ml-2">{{ getScore(remote_game, 'home') }}</div>
                    </div>
                  </div>
                  <div class="description-wrapper text-no-wrap">
                    <div>{{ remote_game.status.type.shortDetail }}</div>
                  </div>
                </div>
              </div>
            </th>
            <th class="text-left d-sm-none" v-if="saved_games.length > 0 && szn_view"></th>
            <th colspan="2" class="text-left d-sm-none" v-if="saved_games.length > 0">
              <v-btn @click="szn_view = !szn_view">{{ szn_text }}</v-btn>
            </th>
          </tr>
          <tr>
            <th class="text-left text-caption">
            </th>
            <th v-if="szn_view && saved_games.length > 0 && !all_games_pre" class="text-center text-caption text-no-wrap">Szn</th>
            <th class="text-center text-caption text-no-wrap">
              <div class="d-flex" v-if="!all_games_pre">
                <div>Pts</div>
                <div v-if="!all_games_complete">
                  <span class="mx-1">|</span> <span>Max</span>
                </div>
              </div>
            </th>
            <th :class="['text-center', handleBgColor(header)]" v-for="header in sorted_headers" :key="header.id">
              <div class="table-odds-wrapper d-flex justify-center">
                <div class="text-caption fav mr-1">
                  {{ getFavoredTeam(header) ? getFavoredTeam(header).team.abbreviation : 'No Team' }}
                </div>
                <div class="text-caption odds">
                  {{ getSavedOdds(header) }}
                </div>
              </div>
            </th>
            <th class="text-center text-caption text-no-wrap d-sm-none" v-if="saved_games.length > 0">
              <div class="d-flex" v-if="!all_games_pre">
                <div>Pts</div>
                <div v-if="!all_games_complete">
                  <span class="mx-1">|</span> <span>Max</span>
                </div>
              </div>
            </th>
            <th class="text-center text-caption text-no-wrap d-sm-none" v-if="szn_view && saved_games.length > 0 && !all_games_pre">
              <div>Szn</div>
            </th>
            <th class="text-center text-caption text-no-wrap d-sm-none" v-if="saved_games.length > 0 && !all_games_pre"></th>
          </tr>
        </thead>
        <tbody class="pb-4">
          <tr v-for="u in sorted_users" :key="u.id" :class="{'bg-blue-lighten-5': handleRowClass(u.id)}" @click="handleRowClick(u.id)">
            <td>
              <div class="text-no-wrap d-flex justify-left align-center" v-if="u.email === user.email">
                <Link :href="current_pick_url">{{ u.username }}</Link>
              </div>
              <div v-else>
                <div class="d-flex justify-left align-center">
                  <div class="text-caption mr-2" v-if="user.is_admin && admin_override">
                    <Link :href="admin_edit_url(u.id)">edit</Link>
                  </div>
                  <div class="text-no-wrap">
                    {{ u.username }}
                  </div>
                </div>
              </div>
            </td>
            <td v-if="szn_view && !all_games_pre">{{ getSeasonPoints(u.id) }}</td>
            <td v-if="!all_games_pre" class="text-center text-no-wrap">
              <div class="d-flex">
                <div>
                  {{ getWeeklyPoints(u.id) }}
                </div>
                <div v-if="getWeeklyMaxPoints(u.id) > 0">
                  <span class="mx-1">|</span><span>{{ getWeeklyMaxPoints(u.id) }}</span>
                </div>
              </div>
            </td>
            <td v-if="all_games_pre" class="text-left">
              <div :class="[allGamesPickedClass(u.id), 'text-no-wrap']">
                {{ allGamesPickedText(u.id) }}
              </div>
            </td>
            <td v-for="remote_game in sorted_headers" :key="remote_game.id">
              <div :class="['d-flex flex-column align-center mt-1', handleScoreClass(remote_game, u.id)]" v-if="!all_games_pre">
                <div class="team-pick">
                  {{ getTeamPickFromRemote(remote_game, u.id) ? getTeamPickFromRemote(remote_game, u.id).team.abbreviation : 'No Pick' }}
                </div>
                <div class="">
                  {{ getConfidenceFromRemote(remote_game, u.id) | '' }}
                </div>
              </div>
            </td>

            <td v-if="!all_games_pre" class="text-center text-no-wrap d-sm-none">
              <div class="d-flex">
                <div>
                  {{ getWeeklyPoints(u.id) }}
                </div>
                <div v-if="getWeeklyMaxPoints(u.id) > 0">
                  <span class="mx-1">|</span><span>{{ getWeeklyMaxPoints(u.id) }}</span>
                </div>
              </div>
            </td>
            <td v-if="szn_view && !all_games_pre" class="text-center text-no-wrap d-sm-none">{{ getSeasonPoints(u.id) }}</td>
            <td class="d-sm-none" v-if="saved_games.length > 0">
              <div class="text-no-wrap d-flex justify-left align-center" v-if="u.email === user.email">
                <Link :href="current_pick_url">{{ u.username }}</Link>
              </div>
              <div v-else>
                <div class="d-flex justify-left align-center">
                  <div class="text-caption mr-2" v-if="user.is_admin && admin_override">
                    <Link :href="admin_edit_url(u.id)">edit</Link>
                  </div>
                  <div class="text-no-wrap">
                    {{ u.username }}
                  </div>
                </div>
              </div>
            </td>
            
          </tr>
        </tbody>
      </v-table>
    </v-row>
    <v-row v-else class="align-center justify-center fill-height">
      <div class="text-h4 text-center">Games For This Week Not Selected</div>
    </v-row>
  </v-container>
</template>

<script>
import { Link } from '@inertiajs/vue3'
import { router } from '@inertiajs/vue3'
import moment from 'moment'
import { mapState, mapGetters } from 'vuex'
export default {
  name: "Group",
  created() {
    this.selected_calendar = this.week
    this.$store.commit('setMatchups', this.matchups)
    this.$store.commit('setWeeklyPicks', []) 
    if (this.saved_picks && this.saved_picks.length > 0) {
      this.saved_picks.forEach(pick => {
        if (!this.gameInConf(pick)) {
          this.$store.commit('pushWeeklyPicks', pick)
        }
      })
    }
    this.$store.commit('setWeeklyGames', [])
    if (this.saved_games && this.mappedGames.length > 0) {
      this.mappedGames.forEach(id => {
        if (id) {
          let game = this.matchups.events.find(e => e ? e.id === id.toString() : false)
          if (game && !this.gameInWeek(game)) {
            this.$store.commit('pushWeeklyGames', game)
          }
        }
      })
    }
  },
  components: {
    Link,
  },
  data() {
    return {
      selected_calendar: '',
      rows_clicked: [],
      szn_view: false,
    };
  },
  props: ['matchups', 'current_week', 'user', 'week', 'saved_picks', 'saved_games', 'current_group', 'users', 'user_groups', 'current_calendar', 'calendars', 'all_picks', 'all_games'],
  computed: {
    ...mapState(['weekly_picks', 'weekly_games', 'admin_override']),
    ...mapGetters(['all_games_pre', 'all_games_complete']),
    szn_text() {
      return this.szn_view ? 'Week View' : 'Season View'
    },
    sorted_users() {
      let getPoints = this.szn_view ? 'getSeasonPoints' : 'getWeeklyPoints'
      return this.users.sort((a,b) => this[getPoints](b.id) - this[getPoints](a.id))
    },
    mappedGames() {
      if (this.saved_games) {
        return this.saved_games.map(g => g.remote_game_id)
      }
      return []
    },
    getCalendarDetail() {
      if (this.calendars && !!this.selected_calendar) {
        return this.calendars.find(c => c.value === this.selected_calendar).detail
      }
      return ''
    },
    current_pick_url() {
      return `/${this.current_group.slug}/${this.week}/picks`
    },
    headers() {
      return this.saved_games.map(g => this.matchups.events.find(e => e.id === g.remote_game_id.toString()))
    },
    sorted_headers () {
      return this.headers.sort((a,b) => this.findIndex(a.id) - this.findIndex(b.id))
    },
    all_pick_winners () {
      return this.all_picks.filter(p => p.winner).map(w => {
        let user = this.users.find(u => u.id === w.user_id)
        let game = this.all_games.find(g => g.id === w.game_id)
        let winner = game.home_team_id === w.remote_team_id ? game.home_team : game.away_team
        return {user: user.username, game: game, pick: w, winner: winner}
      })
    }
  },
  methods: {
    handleBroadcast(game) {
      let comps = game.competitions[0]
      return comps.broadcasts && comps.broadcasts[0] && comps.broadcasts[0].names ? comps.broadcasts[0].names[0] : ''
    },
    findIndex (id) {
      return this.matchups.events.findIndex(e=>e.id === id)
    },
    handleRowClass(id) {
      return this.rows_clicked.includes(id)
    },
    handleRowClick(id) {
      let index = this.rows_clicked.findIndex(r => r === id)
      if (index > -1) {
        this.rows_clicked.splice(index, 1)
      } else {
        this.rows_clicked.push(id)
      }
    },
    getBroadcast(remote_game) {
      let comps = remote_game.competitions
      if (comps && comps.length > 0) {
          let broadcasts = comps[0].broadcasts
          if (broadcasts && broadcasts.length > 0) {
            let names = broadcasts[0].names
            if (names && names.length > 0) {
              return names[0]
            }
          }
      }
      return ''
    },
    admin_edit_url(id) {
      return `/${this.current_group.slug}/${this.week}/picks/${id}`
    },
    handleBgColor(remote_game) {
      if (this.gameState(remote_game) === 'in') {
        return 'bg-blue-lighten-5'
      }
      if (this.gameState(remote_game) === 'post') {
        return 'bg-grey-darken-1'
      }
      return 'bg-grey-lighten-3'
    },
    gmIndex(game) {
      return this.weekly_games.findIndex(g => g.id === game.id)
    },
    gameInWeek(game) {
      return this.gmIndex(game) > -1
    },
    gameInConf(pick) {
      return this.getConfIndex(pick) > -1
    },
    getConfIndex(pick) {
      return this.weekly_picks.findIndex(g => g.remote_game_id.toString() === pick.remote_game_id.toString())
    },
    getTime(datetime) {
      return moment(datetime).format('h:mma')
    },
    allGamesPickedClass(user_id) {
      return this.hasTenPicks(user_id) ? 'text-green-darken-3' : 'text-red-darken-3'
    },
    allGamesPickedText(user_id) {
      return this.hasTenPicks(user_id) ? 'Picks In' : 'Picks Not In'
    },
    hasTenPicks(user_id) {
      return this.saved_picks.filter(s => s.user_id === user_id).length === 10
    },
    getSeasonPoints(user_id) {
      let winner_picks = this.all_picks.filter(p => p.user_id === user_id && p.winner).map(w => w.confidence)
      if (winner_picks.length > 0) {
        return winner_picks.reduce((a,b) => a + b)
      }
      return 0
    },
    getWeeklyPoints(user_id) {
      let all_picks = this.saved_picks.filter(p => p.user_id === user_id)
      let won_picks = all_picks.map(a => {
        let cp = this.correctPick(this.getRemoteFromSaved(a),user_id)
        return cp ? a.confidence : 0
      })
      if (won_picks.length > 0) {
        return won_picks.reduce((a,b) => a + b)
      } else {
        return 0
      }
    },
    getWeeklyMaxPoints(user_id) {
      let in_progress = this.saved_picks.filter(p => p.user_id === user_id && this.gamesNotComplete(p)).map(p => p.confidence)
      if (in_progress.length > 0) {
        return in_progress.reduce((a,b) => a + b) + this.getWeeklyPoints(user_id)
      } else {
        return 0
      }
    },
    gamesNotComplete(saved_game) {
      return !this.getRemoteFromSaved(saved_game).status.type.completed
    },
    handleScoreClass(remote_game, user_id) {
      if (this.gameState(remote_game) !== 'post') {
        return ''
      }
      return this.correctPick(remote_game, user_id) ? 'text-body-2 text-green-darken-3 font-weight-bold' : 'text-body-2 text-red-darken-3 text-decoration-line-through'
    },
    gameState(remote_game) {
      return remote_game.status.type.state
    },
    homeScore(remote_game) {
      return parseInt(this.getScore(remote_game, 'home'))
    },
    awayScore(remote_game) {
      return parseInt(this.getScore(remote_game, 'away'))
    },
    pickedTeamHomeAway(picked_team) {
      return picked_team ? picked_team.homeAway : null;
    },
    otherTeamHomeAway(picked_team) {
      return this.pickedTeamHomeAway(picked_team) && this.pickedTeamHomeAway(picked_team) === 'home' ? 'away' : 'home';
    },
    correctPick(remote_game, user_id) {
      if (!this.isComplete(remote_game)) {
        return false
      }
      let favored_team = this.getFavoredTeam(remote_game)
      let picked_team = this.getTeamPickFromRemote(remote_game, user_id)
      let saved_odds = this.getSavedOdds(remote_game)
      if (favored_team && picked_team) {
        let line = favored_team.id === picked_team.id ? Math.abs(saved_odds) : saved_odds
        return this[`${this.pickedTeamHomeAway(picked_team)}Score`](remote_game) - this[`${this.otherTeamHomeAway(picked_team)}Score`](remote_game) > line
      }
      return false
    },
    isComplete(remote_game) {
      return remote_game.status.type.completed
    },
    getTeam(remote_game, homeAway) {
      return remote_game.competitions[0].competitors.find(c => c.homeAway === homeAway)
    },
    getScore(remote_game, homeAway) {
      return this.getTeam(remote_game, homeAway).score
    },
    navToWeek() {
      let url = `/${this.current_group.slug}/${this.selected_calendar}`
      router.get(url)
    },
    getSavedFromRemote(remote_game) {
      return this.saved_games.find(s => s.remote_game_id.toString() === remote_game.id)
    },
    getRemoteFromSaved(saved) {
      return this.matchups.events.find(s => s.id === saved.remote_game_id.toString())
    },
    getSavedOdds(remote_game) {
      return this.getSavedFromRemote(remote_game).odds
    },
    getRemoteTeamFromId(remote_game, remote_team_id) {
      if (remote_team_id) {
        return remote_game.competitions[0].competitors.find(c => c.id === remote_team_id.toString())
      }
    },
    getFavoredTeam(remote_game) {
      let remote_team_id = this.getSavedFromRemote(remote_game).favored_team_id
      if (remote_team_id) {
        return this.getRemoteTeamFromId(remote_game, remote_team_id)
      }
    },
    getSavedPickFromRemoteGame(remote_game_id, user_id) {
      return this.saved_picks.find(s => s.remote_game_id.toString() === remote_game_id && s.user_id === user_id)
    },
    getPickTeam(saved_pick) {
      let remote_game = this.getRemoteFromSaved(saved_pick)
      return this.getRemoteTeamFromId(remote_game, saved_pick.remote_team_id)
    },
    getTeamPickFromRemote(remote_game, user_id) {
      let saved_pick = this.getSavedPickFromRemoteGame(remote_game.id, user_id)
      if (saved_pick) {
        return this.getPickTeam(saved_pick)
      }
    },
    getConfidenceFromRemote(remote_game, user_id) {
      let saved_pick = this.getSavedPickFromRemoteGame(remote_game.id, user_id)
      if (saved_pick) {
        return saved_pick.confidence
      }
    },
  },
};
</script>

<style></style>