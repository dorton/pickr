<template>
  <v-dialog width="800">
    <template v-slot:activator="{ props }">
      <v-btn v-bind="props" :text="front_button_text"> </v-btn>
    </template>

    <template v-slot:default="{ isActive }">
      <v-card>
        <v-card-title>
          <v-row class="d-flex align-center justify-space-between">
            <v-col>
              <div v-if="edit"> <v-text-field v-model="local_name" hide-details density="compact"></v-text-field> </div>
              <div v-else>{{ group.name }}</div>
            </v-col>
            <v-col class="d-flex justify-end">
              <div v-if="current_user_manager" class="edit-group text-caption" @click="edit = !edit">{{ edit_text }}</div>
            </v-col>
          </v-row>
        </v-card-title>
        <v-card-text>
          <v-row>
            <v-col>
              <v-list>
                <v-list-item v-for="user in group.users" :key="user.id">
                  <v-list-item-title>
                    <div class="d-flex align-center justify-space-between">
                      <div>{{ user.username }} <span v-if="isManager(user)">(manager)</span></div>
                      <div v-if="current_user_manager">
                        <div v-if="isManager(user)"> <v-btn :disabled="last_manager_standing" @click="handleRemoveManager(user)">remove manager</v-btn></div>
                        <div v-else> <v-btn @click="handleMakeManager(user)">make manager</v-btn></div>
                      </div>
                    </div>
                  </v-list-item-title>
                </v-list-item>
              </v-list>
            </v-col>
            <v-col v-if="current_user_manager">
              <v-select
                    label="Sport"
                    v-model="local_sport"
                    :items="sports"
                    :rules="[v => !!v || 'Sport is required']"
                    required
                    hide-details
                    density="compact"
                  ></v-select>
                  <v-select
                    label="League"
                    v-model="local_league"
                    :items="leagues"
                    :rules="[v => !!v || 'League is required']"
                    required
                    hide-details
                    density="compact"
                  ></v-select>
              <v-text-field label="Max Picks/Week" v-model="local_max" hide-details density="compact"></v-text-field>
            </v-col>
            <v-col v-else>
              <div>Sport: {{ local_sport }}</div>
              <div>League: {{ local_league }}</div>
              <div>Max Picks/Week : {{ local_max }}</div>
            </v-col>
          </v-row>
        </v-card-text>

        <v-card-actions>
          <v-spacer></v-spacer>

          <v-btn v-if="current_user_manager" text="Submit" @click="handleSubmit(isActive)"></v-btn>
        </v-card-actions>
      </v-card>
    </template>
  </v-dialog>
</template>

<script>
import axios from 'axios'
import { router } from '@inertiajs/vue3'
import { mapState } from 'vuex'
export default {
  name: "Manage Group",
  created() {
    this.local_name = this.group.name
    this.local_league = this.group.league
    this.local_sport = this.group.sport
    this.local_max = this.group.max_picks
  },
  data() {
    return {
      edit: false,
      local_name: '',
      local_league: '',
      local_sport: '',
      local_max: '',

    };
  },
  props: ['group', 'current_user'],
  computed: {
    ...mapState(['config', 'admin_override']),
    sports() {
      return ['football']
    },
    leagues() {
      return ['nfl', 'college-football']
    },
    edit_text() {
      return this.edit ? 'lock' : 'edit'
    },
    group_object() {
      return { group: { name: this.local_name, league: this.local_league, sport: this.local_sport, max_picks: this.local_max } }
    },
    url() {
      return `/groups/${this.group.id}`
    },
    current_user_manager() {
      return this.isManager(this.current_user) || (this.current_user.is_admin && this.admin_override)
    },
    front_button_text() {
      return this.current_user_manager ? 'Manage Group' : 'View Group'
    },
    last_manager_standing() {
      return this.group.managers.length <= 1
    }
  },
  methods: {
    isManager(user) {
      return this.group.managers.map(m => m.id).includes(user.id)
    },
    handleMakeManager(user) {
      console.log(user);
      let data = { user: user, group: this.group  }
      console.log(data);
      axios.post('/add-user-as-admin', data, this.config).then(r => {
        if (r.status < 400) {
          router.reload()
        }
      })
    },
    handleRemoveManager(user) {
      if (!this.last_manager_standing) {
        let data = { user: user, group: this.group  }
        console.log(data);
        axios.post('/remove-user-as-admin', data, this.config).then(r => {
          if (r.status < 400) {
            router.reload()
          }
        })
      }
    },
    handleSubmit(isActive, keepOpen = false) {
      axios.patch(this.url, this.group_object, this.config).then(r => {
        if (r.status < 400) {
          router.reload()
          this.edit = false
          isActive.value = keepOpen
        }
      })
    }
  },
};
</script>

<style>
.edit-group {
  text-decoration: underline;
  cursor: pointer;
}
</style>