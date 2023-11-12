<template>
  <span>
    <v-list-item v-if="user.is_admin">
      <v-btn block @click="toggleOverride">
        {{ admin_override ? 'Lock' : 'Unlock' }}
      </v-btn>
    </v-list-item>
    <v-divider v-if="user.is_admin"></v-divider>
    <v-list-item v-if="weekly_games.length > 0 && user.is_admin" title="Current Games"></v-list-item>
    <v-list-item v-for="game in weekly_games" :key="game.remote_game_id" v-if="user.is_admin">
      <v-card variant="tonal">
        <v-card-title>
            <div v-if="!isComplete(game)">
              <div class="text-body-2" v-if="all_games_pre">
                {{ getTeamName('away', game) }} {{ getTeamRank('away', game) }} @ {{ getTeamName('home', game) }}
                {{
                  getTeamRank('home', game) }}
              </div>
              <div class="text-body-2" v-else>
                <div class="d-flex justify-space-between">
                  <div class="">{{ getTeamName('away', game) }}</div>
                  <div class="">{{ getScore('away', game) }}</div>
                </div>
                <div class="d-flex justify-space-between">
                  <div class="">{{ getTeamName('home', game) }}</div>
                  <div class="">{{ getScore('home', game) }}</div>
                </div>
              </div>
            </div>
            <div class="text-body-2" v-if="isComplete(game)">
              <div class="d-flex justify-space-between">
                <div class="">{{ getTeamName('away', game) }}</div>
                <div class="">{{ getScore('away', game) }}</div>
              </div>
              <div class="d-flex justify-space-between">
                <div class="">{{ getTeamName('home', game) }}</div>
                <div class="">{{ getScore('home', game) }}</div>
              </div>
            </div>
        </v-card-title>
        <v-card-subtitle>
          <div v-if="!isComplete(game)">
            <div v-if="all_games_pre">
              {{ handleDate(game) }}
            </div>
            <div v-else>
              <div>
                <div>
                  {{ game.status.type.shortDetail }}
                </div>
                <div>
                  {{ game.competitions[0].broadcasts[0].names[0] }}
                </div>
              </div>
            </div>
          </div>
          <div v-if="isComplete(game)">
            {{ game.status.type.description }}
          </div>
        </v-card-subtitle>
        <v-card-text v-if="showButton(game, user)">
          {{ currentOdds(game) }}
          <EditOdds :game="game" :saved_games="saved_games" :config="config" />
        </v-card-text>
        <v-card-text v-else>
          <div>
            Saved Odds {{ getSavedOdds(game) }}
          </div>
        </v-card-text>
        <v-card-actions v-if="showButton(game, user)">
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
          <div v-if="!isComplete(matchup)">
            <div class="text-body-2" v-if="gameState(matchup) === 'pre'">
              {{ getTeamName('away', matchup) }} {{ getTeamRank('away', matchup) }} @ {{ getTeamName('home', matchup) }}
              {{
                getTeamRank('home', matchup) }}
            </div>
            <div class="text-body-2" v-else>
              <div class="d-flex justify-space-between">
                <div class="">{{ getTeamName('away', matchup) }}</div>
                <div class="">{{ getScore('away', matchup) }}</div>
              </div>
              <div class="d-flex justify-space-between">
                <div class="">{{ getTeamName('home', matchup) }}</div>
                <div class="">{{ getScore('home', matchup) }}</div>
              </div>
            </div>
          </div>
          <div class="text-body-2" v-if="isComplete(matchup)">
            <div class="d-flex justify-space-between">
              <div class="">{{ getTeamName('away', matchup) }}</div>
              <div class="">{{ getScore('away', matchup) }}</div>
            </div>
            <div class="d-flex justify-space-between">
              <div class="">{{ getTeamName('home', matchup) }}</div>
              <div class="">{{ getScore('home', matchup) }}</div>
            </div>
          </div>
        </v-card-title>
        <v-card-subtitle>
          <div v-if="!isComplete(matchup)">
            <div v-if="gameState(matchup) === 'pre'">
              {{ handleDate(matchup) }}
            </div>
            <div v-else>
              {{ matchup.status.type.shortDetail }}
            </div>
          </div>
          <div v-if="isComplete(matchup)">
            {{ matchup.status.type.description }}
          </div>
        </v-card-subtitle>
        <v-card-text v-if="!isComplete(matchup)">
          {{ currentOdds(matchup) }}
        </v-card-text>
        <v-card-actions v-if="showButton(matchup, user)">
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
import { mapState, mapGetters } from 'vuex'
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
  props: ['week', 'matchups', 'saved_games', 'current_group', 'saved_games', 'user'],
  computed: {
    ...mapState(['admin_override', 'weekly_games', 'config']),
    ...mapGetters(['all_games_pre', 'all_games_complete']),
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
    showButton(_matchup, user) {
      if (this.admin_override) {
        return true
      }
      return user.is_admin && this.all_games_pre
    },
    getSavedOdds(remote_game) {
      return this.getSavedGameFromRemoteGame(remote_game).odds
    },
    getSavedGameFromRemoteGame(remote_game) {
      return this.saved_games.find(s => s.remote_game_id.toString() === remote_game.id)
    },
    gameState(matchup) {
      return matchup.status.type.state
    },
    isComplete(matchup) {
      return matchup.status.type.completed
    },
    toggleOverride() {
      this.$store.commit('setAdminOverride', !this.admin_override)
    },
    getTeam(homeAway, matchup) {
      return matchup.competitions[0].competitors.find(c => c.homeAway === homeAway)
    },
    getTeamName(homeAway, matchup) {
      return this.getTeam(homeAway, matchup).team.abbreviation
    },
    getScore(homeAway, matchup) {
      return this.getTeam(homeAway, matchup).score
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
          return odds[0].details || ''
        }
      }
      return ''
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

<style></style>