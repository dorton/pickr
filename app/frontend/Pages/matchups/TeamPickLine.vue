<template>
    <span>
        <v-row no-gutters class="justify-space-around align-center my-2" v-if="saved_game">
            <v-col>
                <div :class="['team', {'team-selected': isSelected('away')}]" @click="setSelection('away')">
                    <div class="team-rank mr-1 d-none d-sm-flex">{{ getTeamRank('away') }}</div>
                    <div class="team-name">{{ getTeamName('away', lgScrn ? 'location' : 'abbreviation' ) }}</div>
                    <div class="team-record ml-1 d-none d-sm-flex">({{ getTeamRecord('away') }})</div>
                </div>
            </v-col>
            <v-col>
                <div class="odds-wrapper flex-column d-sm-flex flex-sm-row justify-sm-space-evenly">
                    <div class="favored">{{ favored_team ? favored_team.team.abbreviation : '' }}</div>
                    <div class="odds">{{ saved_odds }}</div>
                </div>
            </v-col>
            <v-col>
                <div :class="['team', {'team-selected': isSelected('home')}]" @click="setSelection('home')">
                    <div class="">@</div>
                    <div class="team-rank mr-1 d-none d-sm-flex">{{ getTeamRank('home') }}</div>
                    <div class="team-name">{{ getTeamName('home', lgScrn ? 'location' : 'abbreviation' ) }}</div>
                    <div class="team-record ml-1 d-none d-sm-flex">({{ getTeamRecord('home') }})</div>
                </div>
            </v-col>
            <v-col class="confidence-wrapper d-flex justify-center">
                <div class="confidence">
                    <v-select hide-details :bg-color="handleDropColor" :disabled="shouldDisableDrop" :items="confidence_selections" v-model="confidence" density="compact" flat single-line
                        variant="outlined" :error="pickTaken">
                        <template v-slot:item="{ props, item }">
                            <v-list-item v-bind="props" :color="getActiveColor(item)" :active="isActive(item)" ></v-list-item>
                          </template>
                    </v-select>
                </div>
            </v-col>
            <v-col :cols="cols" :class="[mobile ? 'pb-2' : '', 'order-first','order-sm-last',  {'font-weight-bold': mobile}]">
                <div class="game-info d-flex justify-start" v-if="gameState === 'pre'">
                    <div class="mx-1 d-flex d-sm-none">{{ getTeamRank('away') }} {{ getTeamName('away', 'location') }} @ {{ getTeamRank('home') }} {{ getTeamName('home', 'location') }}</div>
                    <div class="time mx-1"> {{ gameTime }} </div>
                    <div class="station mx-1"> {{ gameStation }} </div>
                </div>
                <div :class="['game-info', 'd-flex', 'justify-start', {'font-weight-bold': mobile}]" v-else>
                    <div class="mx-1 d-flex d-sm-none"> {{ getTeamName('away', 'location') }} </div>
                    <div class="away-score mx-1"> {{ getScore('away') }} </div>
                    <div class="mx-1">-</div>
                    <div class="mx-1 d-flex d-sm-none"> {{ getTeamName('home', 'location') }} </div>
                    <div class="home-score mx-1"> {{ getScore('home') }} </div>
                </div>
            </v-col>
        </v-row>
        <slot></slot>
    </span>
</template>
<script>
import moment from 'moment'
import { mapGetters } from 'vuex'
export default {
    props: ['remote_game', 'picks', 'week', 'saved_game', 'admin_override', 'user'],
    data() {
        return {
            confidence_selections: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
            confidence: '',
            height: '90px',
            team_id: null,
            pick_id: null
        }
    },
    created () {
        if (this.picks.length > 0) {
            let pick = this.picks.find(p => p.remote_game_id.toString() === this.remote_game.id.toString())
            if (pick) {
                this.pick_id = pick.id
                this.team_id = pick.remote_team_id.toString()
                this.confidence = pick.confidence
            }
        }
    },
    watch: {
        confidence(v) {
            if (this.saved_game) {
                let out = {id: this.pick_id, week: this.week, remote_game_id: this.remote_game.id, confidence: v, remote_team_id: this.team_id, user_id: this.user.id, game_id: this.saved_game.id }
                this.$emit('confChange', out)
            }
        },
        team_id(v) {
            if (this.saved_game) {
                let out = {id: this.pick_id, week: this.week, remote_game_id: this.remote_game.id, confidence: this.confidence, remote_team_id: v, user_id: this.user.id, game_id: this.saved_game.id }
                this.$emit('confChange', out)
            }
        }
    },
    computed: {
        ...mapGetters(['all_games_pre']),
        mobile () {
            const { xs } = this.$vuetify.display
            return xs
        },
        lgScrn () {
            const { lg } = this.$vuetify.display
            return lg
        },
        cols () {
            return this.mobile ? 12 : ''
        },
        handleDropColor() {
            if (this.gameState !== 'post') {
                return ''
            }
            return this.correctPick ? 'green' : 'red'
        },
        pickedTeam() {
            if (this.team_id) {
                return this.getTeamById(this.team_id)
            }
            return null
        },
        correctPick() {
            if (this.favored_team && this.pickedTeam) {
                let line = this.favored_team.id === this.pickedTeam.id ? Math.abs(this.saved_odds) : this.saved_odds
                return this[`${this.pickedTeamHomeAway}Score`] - this[`${this.otherTeamHomeAway}Score`] > line
            }
            return false
        },
        homeScore() {
            return parseInt(this.getScore('home'))
        },
        awayScore() {
            return parseInt(this.getScore('away'))
        },
        correctSpread() {
            if (this.favoredHomeAway) {
                let other = this.favoredHomeAway === 'home' ? 'away' : 'home'
                return (parseInt(this.getScore(this.favoredHomeAway)) + parseInt(this.saved_odds)) - parseInt(this.getScore(other)) > 0
            }
            return false
        },
        pickedTeamHomeAway() {
            return this.pickedTeam ? this.pickedTeam.homeAway : null;
        },
        otherTeamHomeAway() {
            return this.pickedTeamHomeAway && this.pickedTeamHomeAway === 'home' ? 'away' : 'home';
        },
        favoredHomeAway() {
            return this.favored_team ? this.favored_team.homeAway : null
        },
        shouldDisableDrop() {
            if (this.admin_override) {
                return false
            }
            return this.team_id === null || !this.all_games_pre
        },
        saved_odds() {
            if (this.saved_game && this.saved_game.odds) {
                return this.saved_game.odds
            }
            return ''
        },
        favored_team() {
            if (this.saved_game && this.saved_game.favored_team_id) {
                return this.getTeamById(this.saved_game.favored_team_id)
            }
            return ''
        },
        getColor() {
            if (this.confidence.length < 1) {
                return ''
            }
            return this.pickTaken ? 'error' : 'blue-darken-4'
        },
        allPicks() {
            return this.picks.map(fp => fp.confidence)
        },
        otherPicks() {
            return this.picks.filter(p => p.remote_game_id.toString() !== this.remote_game.id.toString()).map(fp => fp.confidence)
        },
        pickTaken() {
            return this.otherPicks.includes(this.confidence)
        },
        hasPick() {
            return this.picks.find(p => p.game_id.toString() === this.remote_game.id.toString()) || false
        },
        gameOdds() {
            // return this.remote_game.competitions[0].odds[0].details
            return this.saved_game.odds

        },
        gameStation() {
            let comps = this.remote_game.competitions[0]
            return comps.broadcasts && comps.broadcasts[0] && comps.broadcasts[0].names ? comps.broadcasts[0].names[0] : ''
        },
        gameTime() {
            return moment(this.remote_game.competitions[0].date).format('h:mma')
        },
        gameCompleted() {
            return this.remote_game.status.type.completed
        },
        gameState() {
            return this.remote_game.status.type.state
        },
        shouldDisableSelect() {
            if (this.admin_override) {
                return false
            }
            return !this.all_games_pre
        }
    },
    methods: {
        isSelected(homeAway) {
            let id = this.team_id ? this.team_id.toString() : ''
            return this.getTeam(homeAway).id.toString() === id
        },
        setSelection(homeAway) {
            if (!this.shouldDisableSelect) {
                this.team_id = this.getTeam(homeAway).id
                if (this.confidence.length < 1) {
                    this.confidence = 10 - this.otherPicks.length
                }
            }
        },
        getActiveColor(item) {
            if (this.confidence.toString() === item.value.toString()) {
                if (this.isDuplicate(item)) {
                    return 'error'
                } else {
                    return 'blue-accent-3'
                }
            }
            return this.isDuplicate(item) ? 'error' : ''
        },
        isDuplicate(item) {
            let set = new Set(this.allPicks)
            let dup = this.allPicks.filter(i => {
                if (set.has(i)) {
                    set.delete(i)
                } else {
                    return i
                }
            })
            return dup.includes(item.value)
        },
        isActive(item) {
            return this.allPicks.includes(item.value)
        },
        getBase(item) {
            return this.otherPicks.includes(item.value) ? 'blue-accent-4' : ''
        },
        getTeamById(id) {
            return this.remote_game.competitions[0].competitors.find(c => c.id.toString() === id.toString())
        },
        getTeam(homeAway) {
            return this.remote_game.competitions[0].competitors.find(c => c.homeAway === homeAway)
        },
        getScore(homeAway) {
            return this.getTeam(homeAway).score
        },
        getTeamRecord(homeAway) {
            return this.getTeam(homeAway).records.find(r => r.type === 'total').summary
        },
        getTeamName(homeAway, name='abbreviation') {
            return this.getTeam(homeAway).team[name]
        },
        getTeamRank(homeAway) {
            return this.getTeam(homeAway).curatedRank.current <= 25 ? `#${this.getTeam(homeAway).curatedRank.current}` : ''
        },
    },
}
</script>
<style>
.confidence .v-select__menu-icon {
    margin-inline-start: 0px !important;
  }

.confidence .v-select .v-field--dirty .v-select__selection {
    margin-inline-end: 0px !important;
  }

.game-wrapper {
    display: flex;
    align-items: center;
    justify-content: space-evenly;
    width: 100%;
}

.team {
    display: flex;
    align-items: center;
    justify-content: center;
    border: 1px solid black;
    border-radius: 5px;
    cursor: pointer;
    min-height: 40px;
}

.team-rank {}

.team-name {}

.team-record {}

.odds-wrapper {
}
.odds {
    text-align: center;
}

.confidence-wrapper {

}

.confidence {
    min-width: 77px;
    margin-left: 4px;
}

.game-info {

}
.team-selected {
    background: blue;
    color: white;
}
</style>