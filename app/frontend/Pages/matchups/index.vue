<template>
  <v-container class="h-75">
    <v-row class="justify-center align-center">
      <v-col>
        <v-btn variant="outlined" color="info" @click="backToGroup">Back</v-btn>
      </v-col>
      <v-col>
        <div class="d-flex justify-center">
          <div class="text-h4">{{ getCalendarDetail }}</div>
        </div>
      </v-col>
      <v-col class="d-none d-sm-flex">
        <v-select hide-details density="compact" flat single-line :items="calendars" item-value="value" item-title="label"
          v-model="selected_calendar" @update:modelValue="navToWeek"></v-select>
      </v-col>
    </v-row>
    <v-row v-if="weekly_games.length > 0">
      <v-col>
        <v-card-title>
          <div class="title-wrapper">
            <div class="title">{{ user.username }} Picks</div>
            <div class="submit" v-if="canSubmit"><v-btn :loading="loading" color="success"
                @click="handleSubmit()">{{ button_text }}</v-btn></div>
          </div>
        </v-card-title>
        <div v-for="(day, gd_index) in game_dates" :key="gd_index">
          <div :class="['text-subtitle-1', mobile ? '' : 'text-right', 'bg-grey-darken-2', 'px-3', 'py-1', 'font-weight-bold']">{{ day }}</div>
          <v-card color="grey-lighten-4" class="mb-2" elevation="5">
            <v-card-text class="team-pick-card">
              <TeamPickLine v-for="(game, i) in gamesOnDay(day)" :key="game.id" :remote_game="game" :picks="weekly_picks"
                @confChange="setConf" :week="handleWeek" :saved_game="getSavedGame(game)" :admin_override="admin_override"
                :user="user">
                <v-divider v-if="i + 1 !== gamesOnDay(day).length" class="" thickness="3px"></v-divider>
              </TeamPickLine>
            </v-card-text>
          </v-card>
        </div>
      </v-col>
    </v-row>
    <v-row v-else class="align-center justify-center fill-height">
      <div class="text-h4 text-center">Games For This Week Not Selected</div>
    </v-row>
    <v-row class="d-sm-none">
      <v-col>
        <v-select hide-details density="compact" flat single-line :items="calendars" item-value="value" item-title="label"
          v-model="selected_calendar" @update:modelValue="navToWeek"></v-select>
      </v-col>
    </v-row>
  </v-container>
</template>
  
<script>
import axios from 'axios'
import moment from 'moment'
import { Link } from '@inertiajs/vue3'
import TeamPickLine from './TeamPickLine.vue'
import { mapState } from 'vuex'
import { router } from '@inertiajs/vue3'
export default {
  props: ['matchups', 'user', 'week', 'current_group', 'current_week', 'users', 'saved_games', 'saved_picks', 'calendars', 'current_calendar',],
  components: {
    Link,
    TeamPickLine,
  },
  data() {
    return {
      loading: false,
      button_text: "Submit",
      // admin_override: false,
      drawer: false,
      selected_calendar: '',
      // weekly_games: [],
      // weekly_picks: [],
      // config: {
      //   headers: {
      //     "Content-Type": "application/json",
      //     "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content,
      //   }
      // }
    }
  },
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
  computed: {
    mobile () {
        const { xs } = this.$vuetify.display
        return xs
    },
    sorted_games() {
      return this.weekly_games.sort((a, b) => this.findIndex(a.id) - this.findIndex(b.id))
    },
    group_url() {
      return `/${this.current_group.slug}/week_${this.selected_calendar}`
    },
    pick_url() {
      return `/${this.current_group.slug}/week_${this.selected_calendar}/picks`
    },
    getCalendarDetail() {
      if (this.calendars && !!this.selected_calendar) {
        return this.calendars.find(c => c.value === this.selected_calendar).detail
      }
      return ''
    },
    ...mapState(['admin_override', 'weekly_games', 'weekly_picks', 'config']),
    mappedGames() {
      if (this.saved_games) {
        return this.saved_games.map(g => g.remote_game_id)
      }
      return []
    },
    noDups() {
      return Array.from(new Set(this.weekly_picks.map(p => p.confidence))).length === this.weekly_picks.length;
    },
    canSubmit() {
      if (this.admin_override) {
        return true
      }
      if (this.weekly_games && this.weekly_games[0]) {
        if (moment().isBefore(moment(this.weekly_games[0].date))) {
          return (this.weekly_picks.length === 10 && this.noDups)
        }
        return moment().isBefore(moment(this.weekly_games[0].date))
      }
      return false
    },
    events() {
      return this.matchups.events
    },
    handleWeek() {
      if (typeof this.week === 'string' || this.week instanceof String) {
        return this.week
      }
      return this.week[0].value
    },
    game_dates() {
      return [...new Set(this.sorted_games.map(e => this.formatDate(e.date)))]
    }
  },
  methods: {
    gamesOnDay(day) {
      return this.sorted_games.filter(e => day === this.formatDate(e.date))
    },
    formatDate(date) {
      return moment(date).format('dddd, MMMM Do')
    },
    findIndex(id) {
      return this.matchups.events.findIndex(e => e.id === id)
    },
    // checkUrl() {
    //   let params = window.location.search
    //   if (params === '?force') {
    //     this.admin_override = true
    //   }
    // },
    backToGroup() {
      router.get(this.group_url)
    },
    navToWeek() {
      router.get(this.pick_url)
    },
    navWeeks(direction) {
      let diff = direction === 'back' ? -1 : 1
      let week = parseInt(this.handleWeek) + diff
      return `/${this.current_group.slug}/week_${week}/picks`
    },
    currentOdds(matchup) {
      let comps = matchup.competitions
      if (comps && comps.length > 0) {
        let odds = comps[0].odds
        if (odds && odds.length > 0) {
          return odds[0].details || 'No Current Odds'
        }
      }
      return 'No Current Odds'
    },
    getSavedGame(game) {
      return this.saved_games.find(g => g.remote_game_id.toString() === game.id.toString())
    },
    handleSubmit() {
      this.loading = true
      axios.post('/picks', { pick: this.weekly_picks, group: this.current_group }, this.config).then(r => {
        if (r.status === 200) {
          this.button_text = "Updated"
          this.loading = false
        }

      }).catch(() => {
        this.loading = false
      }).finally(() => {
        this.loading = false
      })
    },
    gameInConf(pick) {
      return this.getConfIndex(pick) > -1
    },
    getConfIndex(pick) {
      return this.weekly_picks.findIndex(g => g.remote_game_id.toString() === pick.remote_game_id.toString())
    },
    setConf(pick) {
      this.button_text = "Submit"
      if (!this.gameInConf(pick)) {
        this.$store.commit('pushWeeklyPicks', pick)
      } else {
        this.$store.commit('spliceWeeklyPicks', { pick: pick, index: this.getConfIndex(pick) })
      }
    },
    manageWeeklyGames(game) {
      if (this.gameInWeek(game)) {
        this.removeGame(game)
      } else {
        this.addGame(game)
      }
    },
    gmIndex(game) {
      return this.weekly_games.findIndex(g => g.id === game.id)
    },
    gameInWeek(game) {
      return this.gmIndex(game) > -1
    },
    getAddGameText(game) {
      if (this.gameInWeek(game)) {
        return 'Remove Game'
      }
      return 'Add Game'
    },
    removeGame(game) {
      axios.delete(`/games/${game.id}`, this.config).then(() => {
        if (this.gameInWeek(game)) {
          this.weekly_games.splice(this.gmIndex(game), 1)
        }
      })
    },
    addGame(game) {
      if (this.weekly_games.length < 10) {
        let data = { game: { week: this.handleWeek, remote_game_id: game.id, set_odds: null }, group: this.current_group }
        console.log('data: ', data);
        axios.post('/games', data, this.config).then(r => {
          console.log('response: ', r.data);
          if (!this.gameInWeek(game) && this.weekly_games.length < 10) {
            this.weekly_games.push(game)
          }
        })
      }
    },
    getTeam(homeAway, matchup) {
      return matchup.competitions[0].competitors.find(c => c.homeAway === homeAway)
    },
    getTeamName(homeAway, matchup) {
      return this.getTeam(homeAway, matchup).team.abbreviation
    },
    getTeamRank(homeAway, matchup) {
      return this.getTeam(homeAway, matchup).curatedRank.current <= 25 ? `(${this.getTeam(homeAway, matchup).curatedRank.current})` : ''
    },
    findMostFrequent(arr) {
      return arr
        .reduce((acc, cur, ind, arr) => {
          if (arr.indexOf(cur) === ind) {
            return [...acc, [cur, 1]];
          } else {
            acc[acc.indexOf(acc.find(e => e[0] === cur))] = [
              cur,
              acc[acc.indexOf(acc.find(e => e[0] === cur))][1] + 1
            ];
            return acc;
          }
        }, [])
        .sort((a, b) => b[1] - a[1])
        .filter((cur, ind, arr) => cur[1] === arr[0][1])
        .map(cur => cur[0]);
    },
    getAverageTeam(matchup) {
      let bm = JSON.parse(matchup.bookmakers)
      if (bm) {
        let homeCount = bm.map(b => b.markets[0].outcomes.filter(o => o.point < 0).map(fav => fav.name)[0])
        return this.findMostFrequent(homeCount)[0];
      }
    },
    getAverage(matchup) {
      let bm = JSON.parse(matchup.bookmakers)
      if (bm) {
        let outcomes = bm.map(b => b.markets[0].outcomes.filter(o => o.point < 0).map(fav => fav.point)[0])
        let avg = outcomes.reduce((a, b) => a + b, 0) / outcomes.length
        return `${this.getAverageTeam(matchup)} (${avg.toFixed(1)})`
      }
      return ''
    },
    getOdds(matchup) {
      let o = JSON.parse(matchup.bookmakers)
      if (o) {
        return o.map(bm => {
          let favorites = bm.markets[0].outcomes.find(outcome => outcome.point < 0)
          if (favorites) {
            return `${bm.title}: ${favorites.name} (${favorites.point})`
          }
        }).join('<br>')
      }
      return ''
    },
    getScore(matchup) {
      let j = JSON.parse(matchup.scores)
      if (j) {
        return j.map(s => Object.values(s).join(' - ')).join('<br>')
      }
    },
    adjustWeek(weeks) {
      this.week = this.week + weeks
    },
    getTitle(matchup) {
      return matchup.shortName
    },
    getSubtitle(matchup) {
      return this.handleDate(matchup)
    },
    handleDate(matchup) {
      return ` ${moment(matchup.date).format("MMM Do h:mm")} ${moment(matchup.date).fromNow()}`
    }
  },
}
</script>
<style>
.v-card-text.team-pick-card {
  padding: 0rem 1rem 0rem 1rem;
}

.title-wrapper {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.clicky {
  color: blue;
  cursor: pointer;
}
</style>