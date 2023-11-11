<template>
  <v-container>
    <v-row class="justify-center align-center">
      <v-col></v-col>
      <v-col>
        <div class="d-flex justify-center">
          <div class="text-h4">{{ getCalendarDetail }}</div>
        </div>
      </v-col>
      <v-col>
        <v-select :items="calendars" item-value="value" item-title="label" v-model="selected_calendar"
          @update:modelValue="navToWeek"></v-select>
      </v-col>
    </v-row>
    <v-table>
      <thead>
        <tr>
          <th class="text-left">

          </th>
          <th class="text-left">

          </th>
          <th class="text-center" v-for="remote_game in headers" :key="remote_game.id">
            <div class="text-body-2" v-if="!isComplete(remote_game)">
              {{ remote_game.shortName }}
            </div>
            <div class="text-body-2" v-if="isComplete(remote_game)">
              <div class="d-flex justify-space-between">
                <div class="">{{ getTeam(remote_game, 'away').team.abbreviation }}</div>
                <div class="">{{ getScore(remote_game, 'away') }}</div>
              </div>
              <div class="d-flex justify-space-between">
                <div class="">{{ getTeam(remote_game, 'home').team.abbreviation }}</div>
                <div class="">{{ getScore(remote_game, 'home') }}</div>
              </div>
            </div>
          </th>
        </tr>
        <tr>
          <th class="text-left text-caption">
          </th>
          <th class="text-left text-caption">
            Points
          </th>
          <th class="text-left" v-for="header in headers" :key="header.id">
            <div class="table-odds-wrapper d-flex justify-center">
              <div class="text-caption fav mr-1">
                {{ getFavoredTeam(header).team.abbreviation }}
              </div>
              <div class="text-caption odds">
                {{ getSavedOdds(header) }}
              </div>
            </div>
          </th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="u in users" :key="u.id">
          <td>
            <div v-if="u.email === user.email">
              <Link :href="current_pick_url">{{ u.username }}</Link>
            </div>
            <div v-else>
              {{ u.username }}
            </div>
          </td>
          <td>
            <div v-if="!all_games_pre">
              {{ getWeeklyPoints(u.id) }}
            </div>
          </td>
          <td v-for="remote_game in headers" :key="remote_game.id">
            <div :class="['d-flex flex-column align-center', handleScoreClass(remote_game, u.id)]" v-if="!all_games_pre">
              <div class="team-pick text-body-2">
                {{ getTeamPickFromRemote(remote_game, u.id).team.abbreviation }}
              </div>
              <div class="confidence text-body-2">
                {{ getConfidenceFromRemote(remote_game, u.id) }}
              </div>
            </div>
          </td>
        </tr>
      </tbody>
    </v-table>
  </v-container>
</template>

<script>
import { Link } from '@inertiajs/vue3'
import { router } from '@inertiajs/vue3'
export default {
  name: "Group",
  created() {
    this.selected_calendar = this.week
  },
  components: {
    Link,
  },
  data() {
    return {
      selected_calendar: '',
    };
  },
  props: ['matchups', 'current_week', 'user', 'week', 'saved_picks', 'saved_games', 'current_group', 'users', 'user_groups', 'current_calendar', 'calendars'],
  computed: {
    all_games_pre() {
      return this.saved_games.map(a => this.gameState(this.getRemoteFromSaved(a))).every(s => s === 'pre')
    },
    getCalendarDetail() {
      if (this.calendars && !!this.selected_calendar) {
        return this.calendars.find(c => c.value === this.selected_calendar).detail
      }
      return ''
    },
    current_pick_url() {
      return `/${this.current_group.slug}/week_${this.week}/picks`
    },
    headers() {
      return this.saved_games.map(g => this.matchups.events.find(e => e.id === g.remote_game_id.toString()))
    }
  },
  methods: {
    getWeeklyPoints(user_id) {
      let all_picks = this.saved_picks.filter(p => p.user_id === user_id)
      let won_picks = all_picks.filter(a => this.correctPick(this.getRemoteFromSaved(a),user_id))
      return won_picks.map(w => w.confidence).reduce((a,b) => a + b)
    },
    handleScoreClass(remote_game, user_id) {
      if (this.gameState(remote_game) !== 'post') {
        return ''
      }
      return this.correctPick(remote_game, user_id) ? 'text-green-darken-3 font-weight-bold' : 'text-red-darken-3 text-decoration-line-through'
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
      console.log(remote_game.status.type.completed);
      return remote_game.status.type.completed
    },
    getTeam(remote_game, homeAway) {
      return remote_game.competitions[0].competitors.find(c => c.homeAway === homeAway)
    },
    getScore(remote_game, homeAway) {
      return this.getTeam(remote_game, homeAway).score
    },
    navToWeek() {
      let url = `/${this.current_group.slug}/week_${this.selected_calendar}`
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