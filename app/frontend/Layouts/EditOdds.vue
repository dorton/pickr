<template>
    <div class="">
        <div class="favored-team">
            <v-select
                :items="teams"
                v-model="favored_team_id"
                item-title="abbreviation"
                item-value="id"
            ></v-select>
        </div>
        <div class="set-odds">
            <v-text-field v-model="odds" density="compact" type="number"></v-text-field>
        </div>
        <v-btn :color="button_text === 'Submit' ? 'success' : ''" @click="submit()" v-if="canSubmit">{{ button_text }}</v-btn>
    </div>
</template>
<script>
import axios from 'axios'
import { mapState } from 'vuex'
import { router } from '@inertiajs/vue3'
export default {
    props: ['game', 'saved_games', 'config'],
    data() {
        return {
            odds: null,
            favored_team_id: null,
            button_text: 'Submit'
        }
    },
    created () {
        if (this.saved_game) {
            this.odds = this.saved_game.odds ? this.saved_game.odds : this.remote_odds;
            this.favored_team_id = this.saved_game.favored_team_id ? this.saved_game.favored_team_id.toString() : this.remote_favored_team_id;
        }
    },
    computed: {
        ...mapState(['admin_override']),
        canSubmit() {
            if (this.admin_override) {
                return true
            }
            return this.odds !== null && this.favored_team_id !== null
        },
        saved_game() {
            return this.saved_games.find(g => g.remote_game_id.toString() === this.game.id) 
        },
        teams() {
            return this.game.competitions[0].competitors.map(c => c.team)
        },
        remote_odds() {
            if (this.game.competitions[0].odds && this.game.competitions[0].odds.length > 0) {
                if(this.game.competitions[0].odds[0].details){
                    return this.game.competitions[0].odds[0].details.split(' ')[1]
                }
                return ''
            }
            return ''
        },
        remote_favored_team_id() {
            if (this.game.competitions[0].odds && this.game.competitions[0].odds.length > 0) {
                if(this.game.competitions[0].odds[0].details){
                    let team_name = this.game.competitions[0].odds[0].details.split(' ')[0]
                    let team_obj = this.game.competitions[0].competitors.find(c => c.team.abbreviation === team_name)
                    if (team_obj) {
                        return team_obj.id.toString()
                    }
                    return ''
                }
                return ''
            }
            return ''
        },
    },
    methods: {
        submit() {
            if (this.odds !== null && this.favored_team_id !== null) {
                axios.patch(`/games/${this.saved_game.id}`, {game: {odds: this.odds, favored_team_id: this.favored_team_id}}, this.config).then(r => {
                    router.reload()
                    this.button_text = 'Saved'
                })
            }
        }
    },
}
</script>
<style>
.odds-wrapper{
    display: flex;
    align-items: center;
    justify-content: space-around;
}
.favored-team{}
.set-odds{}
</style>