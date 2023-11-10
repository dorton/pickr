<template>

  <v-container>
    <v-row class="justify-center align-center">
      <v-col>
        <v-select
          :items="calendars"
          item-value="value"
          item-title="label"
          v-model="selected_calendar"
          @update:modelValue="navToWeek"
        ></v-select>
      </v-col>
      <v-col>
        <div class="d-flex justify-center">
          <div class="text-h4">{{ getCalendarDetail }}</div>
        </div>
      </v-col>
      <v-col></v-col>
    </v-row>
    <v-table>
      <thead>
        <tr>
          <th class="text-left">
            
          </th>
          <th class="text-center" v-for="header in headers" :key="header.id">
            {{ header.shortName }}
          </th>
        </tr>
        <tr>
          <th class="text-left text-caption">
            Name
          </th>
          <th class="text-left" v-for="header in headers" :key="header.id">
            <div class="table-odds-wrapper d-flex justify-center">
              <div class="text-caption fav mr-1">
                {{ getFavoredTeam(header) }}
              </div>
              <div class="text-caption odds">
                {{ getSavedOdds(header) }}
              </div>
            </div>
          </th>
        </tr>
      </thead>
      <tbody>
        <tr
          v-for="u in users"
          :key="u.id"
        >
          <td>
            <div v-if="u.email === user.email">
              <Link :href="current_pick_url">{{ u.username }}</Link>
            </div>
            <div v-else>
              {{ u.username }}
            </div>
          </td>
          <td v-for="header in headers" :key="header.id">
            <div class="pick-wrapper">
              <div class="team-pick text-center">
                {{ getTeamPickFromRemote(header, u.id) }}
              </div>
              <div class="confidence text-center">
                {{ getConfidenceFromRemote(header, u.id) }}
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
import { transformWithEsbuild } from 'vite';

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
    getCalendarDetail() {
      // if (this.calendars && !!this.selected_calendar) {
      //   return this.calendars.find(c => c.value === this.selected_calendar).detail
      // }
      return ''
    },
    current_pick_url() {
      return `/${this.current_group.slug}/week_${this.current_week}/picks` 
    },
    headers() {
      return this.saved_games.map(g => this.matchups.events.find(e => e.id === g.remote_game_id.toString()))
    }
  },
  methods: {
    navToWeek() {
      let url = `/${this.current_group.slug}/week_${this.selected_calendar}`
      window.location = url
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
        return this.getRemoteTeamFromId(remote_game, remote_team_id).team.abbreviation
      }
    },
    getSavedPickFromRemoteGame(remote_game_id, user_id) {
      return this.saved_picks.find(s => s.remote_game_id.toString() === remote_game_id && s.user_id === user_id)
    },
    getPickTeam(saved_pick) {
      let remote_game = this.getRemoteFromSaved(saved_pick)
      return this.getRemoteTeamFromId(remote_game, saved_pick.remote_team_id).team.abbreviation
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

<style lang="scss" scoped></style>