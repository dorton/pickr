<template>
  <v-card flat class="" color="transparent">
    <v-tabs v-model="tab" color="deep-purple-accent-4" align-tabs="center">
      <v-tab :value="1">Groups</v-tab>
    </v-tabs>
    <v-window v-model="tab">
      <v-window-item v-for="n in 1" :key="n" :value="n">
        <v-container v-if="n == 1" class="">
          <v-row class="flex-column align-center justify-center text-center">
            <v-col :class="title_text">Welcome {{ user.username }}!</v-col>
            <v-col v-if="user_groups.length < 1" :class="other_text">Looks like you are not in any groups :(</v-col>
            <v-col v-else :class="other_text">Maybe You'd Like To Join Another Group?</v-col>
            <v-col :class="other_text">No Problemo! Pick a public group below to join!</v-col>
            <div :class="['d-flex', 'align-center', 'justify-center', widthClass]">
              <v-select class="" :items="groups" clearable item-value="id" item-title="name" label="Select Public Group"
                v-model="group_id"></v-select>
              <v-btn @click="joinGroup" color="info" class="mb-4 ml-2" v-if="!!group_id">Join Public Group</v-btn>
            </div>
            <v-col :class="other_text">Or input the code for the private group you would like to join.</v-col>
            <div :class="['d-flex', 'align-center', 'justify-center', widthClass]">
              <v-text-field class="" label="Private Id Code" v-model="private_slug_id" single-line></v-text-field>
              <v-btn @click="joinGroup" color="info" class="mb-4 ml-2" v-if="!!private_slug_id">Join Private Group</v-btn>
            </div>
            <v-col class="text-h6">Don't know the code? Contact the group manager and demand they do their job
              better!</v-col>
          </v-row>
          <v-divider class="my-2"></v-divider>
          <v-row v-if="user_groups.length > 0">
            <v-col>
              <div class="text-h5 text-center">Your Groups</div>
            </v-col>
          </v-row>
          <v-row>
            <v-col v-for="group in managed_groups_with_users" :key="group.id" cols="12" sm="12" md="6">
              <v-card>
                <RemoveFromGroup :group="group" :user="user" :config="config" />
                <v-card-title class="d-flex align-center">
                  <h4>{{ group.name }}</h4>
                  <v-tooltip location="top" :text="default_tooltip_text(group)">
                    <template v-slot:activator="{ props }">
                      <v-icon v-bind="props" @click="handleDefault(group)" class="ml-2" size="x-small">{{ starIcon(group) }}</v-icon>
                    </template>
                  </v-tooltip>
                </v-card-title>
                <v-card-actions class="d-flex justify-space-between">
                  <v-btn color="info" @click="getGroupUrl(group)">Go To Group</v-btn>
                  <ManageGroup :group="group" :current_user="user" :config="config" />
                </v-card-actions>
              </v-card>
            </v-col>
            <v-col cols="12" sm="12" md="6">
              <CreateNewGroup :current_user="user" />
            </v-col>
          </v-row>
        </v-container>
        <v-container v-if="n === 2">
          <v-row class="flex-column align-center justify-center text-center">
            <v-col :class="title_text">Edit Account</v-col>
            <div class="d-flex align-center justify-center w-50">
              <v-text-field class="" label="Private Id Code" v-model="local_username" single-line></v-text-field>
              <v-btn @click="updateUsername" color="info" class="mb-4 ml-2">Update Username</v-btn>
            </div>
          </v-row>
        </v-container>
      </v-window-item>
    </v-window>
  </v-card>
</template>
<script>
import axios from 'axios'
import { mapState } from 'vuex'
import { router } from '@inertiajs/vue3'
import ManageGroup from './ManageGroup.vue'
import RemoveFromGroup from './RemoveFromGroup.vue'
import CreateNewGroup from './CreateNewGroup.vue'
export default {
  name: "ResolveNoGroup",
  created() {
    this.$store.commit('setMatchups', this.matchups)
    this.local_username = this.user.username
    this.handleAnyParams()
  },
  components: {
    ManageGroup,
    RemoveFromGroup,
    CreateNewGroup,
  },
  data() {
    return {
      tab: null,
      group_id: null,
      private_slug_id: '',
      title_text: "text-h2",
      other_text: "text-h5",
      local_username: null,
      manage_group_modal: false,
    };
  },
  props: ['user', 'week', 'groups', 'calendars', 'user_groups', 'matchups', 'managed_groups_with_users'],
  computed: {
    ...mapState(['config']),
    widthClass() {
      let { xs } = this.$vuetify.display
      return xs ? 'w-100' : 'w-50'
    },
    cols() {
      const { smAndUp } = this.$vuetify.display
      return smAndUp ? 6 : 12
    },
  },
  methods: {
    default_tooltip_text(group) {
      return this.isGroupDefault(group) ? 'Default Group' : 'Make Default Group'
    },
    handleDefault(group) {
      axios.patch(`/groups/${group.id}`, { group: { toggle_default: true, id: group.id } }, this.config).then(() => {
        router.reload()
      })
    },
    starIcon(group) {
      return this.isGroupDefault(group) ? 'mdi-star' : 'mdi-star-outline'
    },
    isGroupDefault(group) {
      return this.user.group_defaults.map(d => d.id).includes(group.id)
    },
    createNewGroup() { },
    handleAnyParams() {
      const urlParams = new URLSearchParams(window.location.search);
      const pg = urlParams.get('pg');
      if (pg) {
        this.private_slug_id = pg
      }
    },
    getGroupUrl(group) {
      router.get(`/${group.slug}`)
    },
    joinGroup() {
      if (!!this.group_id || !!this.private_slug_id) {
        let data = { user_id: this.user.id, group_id: this.group_id, group_slug: this.private_slug_id }
        let url = '/adduser'
        axios.post(url, data, this.config).then(r => {
          if (r.status < 400) {
            let slug = !!this.private_slug_id ? this.private_slug_id : this.groups.find(g => g.id === this.group_id).slug
            if (slug) {
              router.get(`/${slug}`)
            } else {
              router.reload()
            }
          }
        })
      }
    },
    updateUsername() {
      let data = { user: { id: this.user.id, username: this.local_username } }
      let url = '/users'
      axios.put(url, data, this.config).then(r => {
        if (r.status < 400) {
          router.reload()
        }
      })
    },
  },
};
</script>

<style lang="scss" scoped></style>
