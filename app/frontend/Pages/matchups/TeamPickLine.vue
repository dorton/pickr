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
            <div class="odds">{{ gameOdds }}</div>
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
                <v-select :disabled="selection === null" :items="confidence_selections" v-model="confidence" density="compact" flat single-line
                    variant="outlined" :error="pickTaken">
                    <template v-slot:item="{ props, item }">
                        <v-list-item v-bind="props" :color="getActiveColor(item)" :active="isActive(item)" ></v-list-item>
                      </template>
                </v-select>
            </div>
        </v-col>
        <v-col>
            <div class="game-info">
                <div class="time mx-1"> {{ gameTime }} </div>
                <div class="station mx-1"> {{ gameStation }} </div>
            </div>
        </v-col>
        <v-divider thickness="3px"></v-divider>
    </v-row>
</template>
<script>
import moment from 'moment'
export default {
    props: ['game', 'picks'],
    data() {
        return {
            confidence_selections: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
            confidence: '',
            height: '90px',
            selection: null,
        }
    },
    created () {
        if (this.picks.length > 0) {
            let pick = this.picks.find(p => p.id === this.game.id)
            if (pick) {
                this.selection = pick.selection
                this.confidence = pick.conf
            }
        }
    },
    watch: {
        confidence(v) {
            let out = { id: this.game.id, conf: v, selection: this.selection }
            this.$emit('confChange', out)
        }
    },
    computed: {
        getColor() {
            if (this.confidence.length < 1) {
                return ''
            }
            return this.pickTaken ? 'error' : 'blue-darken-4'
        },
        allPicks() {
            return this.picks.map(fp => fp.conf)
        },
        otherPicks() {
            return this.picks.filter(p => p.id !== this.game.id).map(fp => fp.conf)
        },
        pickTaken() {
            return this.otherPicks.includes(this.confidence)
        },
        hasPick() {
            return this.picks.find(p => p.id === this.game.id) || false
        },
        gameOdds() {
            return this.game.competitions[0].odds[0].details
        },
        gameStation() {
            let comps = this.game.competitions[0]
            return comps.broadcasts && comps.broadcasts[0] && comps.broadcasts[0].names ? comps.broadcasts[0].names[0] : ''
        },
        gameTime() {
            return moment(this.game.competitions[0].date).format('h:mma')
        },
    },
    methods: {
        isSelected(homeAway) {
            return this.getTeam(homeAway).id === this.selection
        },
        setSelection(homeAway) {
            this.selection = this.getTeam(homeAway).id
            if (this.confidence.length < 1) {
                this.confidence = 10 - this.otherPicks.length
            }
        },
        getActiveColor(item) {
            if (this.confidence === item.value) {
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
        getTeam(homeAway) {
            return this.game.competitions[0].competitors.find(c => c.homeAway === homeAway)
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