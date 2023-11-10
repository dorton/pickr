<template>
  <span>
    <v-list-item>
      <v-btn block @click="toggleOverride">
        {{ admin_override ? 'Lock' : 'Unlock' }}
      </v-btn>
    </v-list-item>
    <v-divider></v-divider>
    <v-list-item v-if="weekly_games.length > 0" title="Current Games"></v-list-item>
    <v-list-item v-for="game in weekly_games" :key="game.remote_game_id">
      <v-card variant="tonal">
        <v-card-title>
          {{ getTeamName('away', game) }} {{ getTeamRank('away', game) }} @ {{ getTeamName('home', game) }}
          {{
            getTeamRank('home', game) }}
        </v-card-title>
        <v-card-subtitle>
          {{ handleDate(game) }}
        </v-card-subtitle>
        <v-card-text>
          {{ currentOdds(game) }}
          <EditOdds :game="game" :saved_games="saved_games" :config="config" />
        </v-card-text>
        <v-card-actions>
          <v-btn color="indigo-darken-3" @click="manageWeeklyGames(game)">
            {{ getAddGameText(game) }}
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-list-item>
    <v-divider></v-divider>
    <v-list-item title="All Games">
    </v-list-item>
    <v-list-item v-for="matchup in events" :key="matchup.id">
      <v-card variant="tonal">
        <v-card-title>
          {{ getTeamName('away', matchup) }} {{ getTeamRank('away', matchup) }} @ {{ getTeamName('home', matchup) }}
          {{
            getTeamRank('home', matchup) }}
        </v-card-title>
        <v-card-subtitle>
          {{ handleDate(matchup) }}
        </v-card-subtitle>
        <v-card-text>
          {{ currentOdds(matchup) }}
        </v-card-text>
        <v-card-actions>
          <v-btn color="indigo-darken-3" @click="manageWeeklyGames(matchup)">
            {{ getAddGameText(matchup) }}
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-list-item>
  </span>
</template>

<script>
import EditOdds from './EditOdds.vue'
import { mapState } from 'vuex'
import moment from 'moment'
import axios from 'axios'
export default {
  name: "AdminGames",
  components: {
    EditOdds,
  },
  created() {},
  data() {
    return {};
  },
  props: ['week', 'matchups', 'saved_games', 'current_group', 'saved_games'],
  computed: {
    ...mapState(['admin_override', 'weekly_games', 'config']),
    events() {
      return this.matchups.events
    },
    handleWeek() {
      if (typeof this.week === 'string' || this.week instanceof String) {
        return this.week
      }
      return this.week[0].value
    },
  },
  methods: {
    toggleOverride() {
      this.$store.commit('setAdminOverride', !this.admin_override)
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
    handleDate(matchup) {
      return ` ${moment(matchup.date).format("MMM Do h:mm")} ${moment(matchup.date).fromNow()}`
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
    gmIndex(game) {
      return this.weekly_games.findIndex(g => g.id === game.id)
    },
    gameInWeek(game) {
      return this.gmIndex(game) > -1
    },
    manageWeeklyGames(game) {
      if (this.gameInWeek(game)) {
        this.removeGame(game)
      } else {
        this.addGame(game)
      }
    },
    removeGame(game) {
      axios.delete(`/games/${game.id}`, this.config).then(() => {
        if (this.gameInWeek(game)) {
          this.$store.commit('spliceWeeklyGames', this.gmIndex(game))
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
            this.$store.commit('pushWeeklyGames', game)
          }
  
        })
      }
    },
    getAddGameText(game) {
      if (this.gameInWeek(game)) {
        return 'Remove Game'
      }
      return 'Add Game'
    },
  },
};
</script>

<style lang="scss" scoped></style>