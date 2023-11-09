<template>
    <v-row dense align="center" align-content="space-around">
        <v-col>
            <div :class="['team', {'team-selected': isSelected('away')}]" @click="setSelection('away')">
                <div class="team-rank mx-1">{{ getTeamRank('away') }}</div>
                <div class="team-name mx-1">{{ getTeamName('away') }}</div>
                <div class="team-record mx-1">({{ getTeamRecord('away') }})</div>
            </div>
        </v-col>
        <v-col>
            <div class="odds-wrapper">
                <div class="favored">{{ favored_team ? favored_team.team.abbreviation : '' }}</div>
                <div class="odds ml-2">{{ saved_odds }}</div>
            </div>
        </v-col>
        <v-col>
            <div :class="['team', {'team-selected': isSelected('home')}]" @click="setSelection('home')">
                <div class="mx-1">@</div>
                <div class="team-rank mx-1">{{ getTeamRank('home') }}</div>
                <div class="team-name mx-1">{{ getTeamName('home') }}</div>
                <div class="team-record mx-1">({{ getTeamRecord('home') }})</div>
            </div>
        </v-col>
        <v-col class="confidence-wrapper">
            <div class="confidence">
                <v-select :bg-color="handleDropColor" :disabled="shouldDisableDrop" :items="confidence_selections" v-model="confidence" density="compact" flat single-line
                    variant="outlined" :error="pickTaken">
                    <template v-slot:item="{ props, item }">
                        <v-list-item v-bind="props" :color="getActiveColor(item)" :active="isActive(item)" ></v-list-item>
                      </template>
                </v-select>
            </div>
        </v-col>
        <v-col>
            <div class="game-info" v-if="gameState === 'pre'">
                <div class="time mx-1"> {{ gameTime }} </div>
                <div class="station mx-1"> {{ gameStation }} </div>
            </div>
            <div class="game-info" v-else>
                <div class="away-score mx-1"> {{ getScore('away') }} </div>
                <div class="mx-1">-</div>
                <div class="home-score mx-1"> {{ getScore('home') }} </div>
            </div>
        </v-col>
        <v-divider thickness="3px"></v-divider>
    </v-row>
</template>
<script>
import moment from 'moment'
export default {
    props: ['game', 'picks', 'week', 'saved_game', 'admin_override'],
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
            let pick = this.picks.find(p => p.game_id.toString() === this.game.id.toString())
            if (pick) {
                this.pick_id = pick.id
                this.team_id = pick.team_id.toString()
                this.confidence = pick.confidence
            }
        }
    },
    watch: {
        confidence(v) {
            let out = {id: this.pick_id, week: this.week, game_id: this.game.id, confidence: v, team_id: this.team_id }
            this.$emit('confChange', out)
        },
        team_id(v) {
            let out = {id: this.pick_id, week: this.week, game_id: this.game.id, confidence: this.confidence, team_id: v }
            this.$emit('confChange', out)
        }
    },
    computed: {
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
            return this.team_id === null || (this.gameState && this.gameState !== 'pre')
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
            return this.picks.filter(p => p.game_id.toString() !== this.game.id.toString()).map(fp => fp.confidence)
        },
        pickTaken() {
            return this.otherPicks.includes(this.confidence)
        },
        hasPick() {
            return this.picks.find(p => p.game_id.toString() === this.game.id.toString()) || false
        },
        gameOdds() {
            // return this.game.competitions[0].odds[0].details
            return this.saved_game.odds

        },
        gameStation() {
            let comps = this.game.competitions[0]
            return comps.broadcasts && comps.broadcasts[0] && comps.broadcasts[0].names ? comps.broadcasts[0].names[0] : ''
        },
        gameTime() {
            return moment(this.game.competitions[0].date).format('h:mma')
        },
        gameCompleted() {
            return this.game.status.type.completed
        },
        gameState() {
            return this.game.status.type.state
        },
        shouldDisableSelect() {
            if (this.admin_override) {
                return false
            }
            return this.gameState !== 'pre'
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
            return this.game.competitions[0].competitors.find(c => c.id.toString() === id.toString())
        },
        getTeam(homeAway) {
            return this.game.competitions[0].competitors.find(c => c.homeAway === homeAway)
        },
        getScore(homeAway) {
            return this.getTeam(homeAway).score
        },
        getTeamRecord(homeAway) {
            return this.getTeam(homeAway).records.find(r => r.type === 'total').summary
        },
        getTeamName(homeAway) {
            return this.getTeam(homeAway).team.abbreviation
        },
        getTeamRank(homeAway) {
            return this.getTeam(homeAway).curatedRank.current <= 25 ? `#${this.getTeam(homeAway).curatedRank.current}` : ''
        },
    },
}
</script>
<style>
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
    min-height: 45px;
}

.team-rank {}

.team-name {}

.team-record {}

.odds-wrapper {
    display: flex;
    justify-content: center;
}
.odds {
    text-align: center;
}

.confidence-wrapper {
    display: flex;
    justify-content: center;
    max-height: 60px;
}

.confidence {
    padding-top: 3px;
    max-width: 80px;
}

.game-info {
    display: flex;
    align-items: right;
    align-self: right;
}
.team-selected {
    background: blue;
    color: white;
}
</style>