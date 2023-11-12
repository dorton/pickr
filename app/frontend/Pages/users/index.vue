<template>
  <v-container class="">
    <v-row class="flex-column align-center justify-center text-center">
      <v-col :class="title_text">Welcome {{ user.username }}!</v-col>
      <v-col v-if="user_groups.length < 1" :class="other_text">Looks like you are not in any groups :(</v-col>
      <v-col v-else :class="other_text">Maybe You'd Like To Join Another Group?</v-col>
      <v-col :class="other_text">No Problemo! Pick a public group below to join!</v-col>
      <div class="d-flex align-center justify-center w-50">
        <v-select class="" :items="groups" clearable item-value="id" item-title="name" label="Select Public Group"
          v-model="group_id"></v-select>
        <v-btn @click="joinGroup" color="info" class="mb-4 ml-2" v-if="!!group_id">Join Public Group</v-btn>
      </div>
      <v-col :class="other_text">Or input the code for the private group you would like to join.</v-col>
      <div class="d-flex align-center justify-center w-50">
        <v-text-field class="" label="Private Id Code" v-model="private_slug_id" single-line></v-text-field>
        <v-btn @click="joinGroup" color="info" class="mb-4 ml-2" v-if="!!private_slug_id">Join Private Group</v-btn>
      </div>
      <v-col class="text-h6">Don't know the code? Contact the group manager and demand they do their job better!</v-col>
    </v-row>
    <v-divider class="my-2"></v-divider>
    <v-row v-if="user_groups.length > 0">
      <v-col>
        <div class="text-h5 text-center">Your Groups</div>
      </v-col>
    </v-row>
    <v-row>
      <v-col v-for="group in user_groups" :key="group.id" cols="12" sm="12" md="6">
        <v-card>
          <v-card-title class="d-flex align-center">
            <h4>{{ group.name }}</h4>
          </v-card-title>
          <v-card-actions>
            <v-btn color="info" @click="getGroupUrl(group)">Go To Group</v-btn>
            <v-btn color="error" @click="removeFromGroup(group, user)">Remove Self From Group</v-btn>
          </v-card-actions>
        </v-card>
      </v-col>
    </v-row>
  </v-container>
</template>
<script>
import axios from 'axios'
import { mapState } from 'vuex'
import { router } from '@inertiajs/vue3'
export default {
  name: "ResolveNoGroup",
  created() {
    this.$store.commit('setMatchups', this.matchups)
  },
  data() {
    return {
      group_id: null,
      private_slug_id: '',
      title_text: "text-h2",
      other_text: "text-h5",
    };
  },
  props: ['user', 'week', 'groups', 'calendars', 'user_groups'],
  computed: {
    ...mapState(['config'])
  },
  methods: {
    getGroupUrl(group) {
      router.get(`/${group.slug}`)
    },
    joinGroup() {
      if (!!this.group_id || !!this.private_slug_id) {
        let data = { user_id: this.user.id, group_id: this.group_id, group_slug: this.private_slug_id }
        let url = '/adduser'
        axios.post(url, data, this.config).then(r => {
          if (r.statusText === 'OK') {
            if (this.user_groups.length < 1) {
              router.get('/')
            } else {
              let slug = !!this.private_slug_id ? this.private_slug_id : this.groups.find(g=>g.id === this.group_id)
              if (slug) {
                router.get(`/${slug}`)
              } else {
                router.reload()
              }
            }
          }
        })
      }
    },
    removeFromGroup(group, user) {
        let data = { user_id: user.id, group_id: group.id, group_slug: group.slug }
        let url = '/removeuser'
        axios.post(url, data, this.config).then(r => {
          if (r.statusText === 'OK') {
            router.reload()
          }
        })
      }
    },
  };
</script>

<style lang="scss" scoped></style>
