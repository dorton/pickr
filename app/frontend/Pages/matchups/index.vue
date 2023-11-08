<template>
  <v-layout>
    <v-app-bar :elevation="2">
      <v-app-bar-title>Pickr</v-app-bar-title>
      <v-spacer></v-spacer>
      <v-btn icon>
        <v-icon @click="drawer = !drawer">mdi-cog</v-icon>
      </v-btn>
    </v-app-bar>
    <v-navigation-drawer location="right" v-model="drawer" temporary>
      
      <v-list-item>
        <v-btn block @click="signOut">
          Logout
        </v-btn>
      </v-list-item>
      <v-divider></v-divider>
      <v-list-item title="All Games" v-if="user.username === 'dorktron'">
        <v-container>
          <v-row>
            <v-col v-for="matchup in events" :key="matchup.id">
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
                  <v-expansion-panels>
                    <v-expansion-panel>
                      <v-expansion-panel-text>
                        <v-card flat></v-card>
                      </v-expansion-panel-text>
                    </v-expansion-panel>
                  </v-expansion-panels>
                </v-card-text>
                <v-card-actions>
                  <v-btn color="indigo-darken-3" @click="manageWeeklyGames(matchup)">
                    {{ getAddGameText(matchup) }}
                  </v-btn>
                </v-card-actions>
              </v-card>
            </v-col>
          </v-row>
        </v-container>
      </v-list-item>
    </v-navigation-drawer>
    <v-main>
      <v-container>
        <v-row>
          <v-col>
            <v-card-title>
              <div class="title-wrapper">
                <div class="title">My Picks</div>
                <div class="submit" v-if="canSubmit"><v-btn color="success">Submit</v-btn></div>
              </div>
            </v-card-title>
            <v-card flat color="grey-lighten-4">
              <v-card-text>
                <TeamPickLine v-for="game in weekly_games" :key="game.id" :game="game" :picks="weekly_picks" @confChange="setConf" />
              </v-card-text>
            </v-card>
          </v-col>
        </v-row>
        <v-row class="d-flex justify-space-between">
          <div class="pa-3 clicky" @click="adjustWeek(1)">last week</div>
          <div class="pa-3 clicky" @click="adjustWeek(-1)">next week</div>
        </v-row>
      </v-container>
    </v-main>
  </v-layout>
</template>
  
<script>
import axios from 'axios'
import moment from 'moment'
import { Link } from '@inertiajs/vue3'
import TeamPickLine from './TeamPickLine.vue'
export default {
  props: ['matchups', 'user'],
  components: {
    Link,
    TeamPickLine
  },
  data() {
    return {
      week: 0,
      drawer: false,
      weekly_games: [],
      weekly_picks: [],
      saved_games: [401520394, 401524052, 401525550, 401520391, 401520382, 401525890, 401525891, 401520397, 401525549, 401524053],
      saved_picks: []
    }
  },
  created () {
    if (this.saved_picks.length > 0) {
      this.saved_picks.forEach(pick => {
        if (!this.gameInConf(pick)) {
          this.weekly_picks.push(pick)
        }
      })
    }
    if (this.saved_games.length > 0) {
      this.saved_games.forEach(id => {
        let game = this.matchups.events.find(e => e.id === id.toString())
        if (game && !this.gameInWeek(game)) {
          this.weekly_games.push(game)
        }
      })
    }
  },
  computed: {
    noDups() {
      return Array.from(new Set(this.weekly_picks.map(p => p.conf))).length === this.weekly_picks.length;
    },
    canSubmit() {
      return this.weekly_picks.length === 10 && this.noDups
    },
    events() {
      return this.matchups.events
    }
  },
  methods: {
    gameInConf(game) {
      return this.getConfIndex(game) > -1
    },
    getConfIndex(game) {
      return this.weekly_picks.findIndex(g => g.id === game.id)
    },
    setConf(game) {
      if (!this.gameInConf(game)) {
        this.weekly_picks.push(game)
      } else {
        this.weekly_picks.splice(this.getConfIndex(game), 1, game)
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
      if (this.gameInWeek(game)) {
        this.weekly_games.splice(this.gmIndex(game), 1)
      }
    },
    addGame(game) {
      if (!this.gameInWeek(game) && this.weekly_games.length < 10) {
        this.weekly_games.push(game)
      }
    },
    signOut() {
      let config = {
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content,
        }
      }
      axios.delete('/users/sign_out', config).then(() => {
        window.location.reload();
      })
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