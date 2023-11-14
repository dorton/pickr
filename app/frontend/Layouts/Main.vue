<template>
  <v-layout class="h-screen">
    <v-app-bar :elevation="2">
      <v-app-bar-title>
        <Link href="/" class="main-header">{{ titleBarTitle }}</Link>
      </v-app-bar-title>
      <v-spacer></v-spacer>
      <v-menu v-if="user_groups.length > 1">
        <template v-slot:activator="{ props }">
          <v-btn icon="mdi-dots-vertical" v-bind="props"></v-btn>
        </template>

        <v-list>
          <v-list-item
            v-for="(group, i) in user_groups"
            :key="i"
          >
            <v-list-item-title @click="changeGroups(group)">{{ group.name }}</v-list-item-title>
          </v-list-item>
        </v-list>
      </v-menu>
      <v-btn icon>
        <v-icon @click="drawer = !drawer">mdi-cog</v-icon>
      </v-btn>
    </v-app-bar>
    <v-navigation-drawer location="right" v-model="drawer" temporary>
      <v-list-item>
        <v-btn block href="/manage/groups">
          {{ user.username }}
        </v-btn>
      </v-list-item>
      <v-list-item>
        <v-btn block @click="signOut">
          Logout
        </v-btn>
      </v-list-item>
      <AdminGames v-if="drawer" :user="user" :week="week" :current_group="current_group" :current_calendar="current_calendar" :matchups="matchups" :saved_games="saved_games" />
    </v-navigation-drawer>
    <v-main>
      <slot></slot>
    </v-main>
  </v-layout>
</template>

<script>
import AdminGames from './AdminGames.vue'
import { Link } from '@inertiajs/vue3'
import { mapState } from 'vuex'
import { router } from '@inertiajs/vue3'
import axios from 'axios'
export default {
  name: "Main Layout",
  components: {
    Link,
    AdminGames
  },
  created() {
    this.$store.commit('setMatchups', this.matchups)
    this.$store.commit('setWeekCalendar', this.week_calendar)
  },
  data() {
    return {
      drawer: false
    };
  },
  props: ['matchups', 'user', 'saved_games', 'saved_picks', 'current_group', 'week', 'user_groups', 'current_calendar', 'week_calendar'],
  computed: {
    ...mapState(['weekly_picks', 'weekly_games', 'admin_override', 'config']),
    mobile () {
        const { xs } = this.$vuetify.display
        return xs
    },
    titleBarTitle() {
      return this.mobile ? 'SBP' : 'Sports Ball Pickr'
    },
  },
  methods: {
    changeGroups(group) {
      router.get(`/${group.slug}`)
    },
    signOut() {
      axios.delete('/users/sign_out', this.config).then(() => {
        window.location.reload();
      })
    },
    checkUrl() {
      let params = window.location.search
      if (params === '?force') {
        this.$store.commit('setAdminOverride', true)
      }
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
  },
};
</script>

<style>
a.main-header {
  color: black;
  text-decoration: none;
}
</style>