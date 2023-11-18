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
                      <div>{{ user.username }}</div>
                      <div v-if="current_user_manager">
                        <div v-if="isManager(user)"> <v-btn :disabled="last_manager_standing" @click="handleRemoveManager(user)">remove manager</v-btn></div>
                        <div v-else> <v-btn @click="handleMakeManager(user)">make manager</v-btn></div>
                      </div>
                    </div>
                  </v-list-item-title>
                </v-list-item>
              </v-list>
            </v-col>
          </v-row>
        </v-card-text>

        <v-card-actions>
          <v-spacer></v-spacer>

          <v-btn text="Submit" @click="handleSubmit(isActive)"></v-btn>
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
  },
  data() {
    return {
      edit: false,
      local_name: '',
    };
  },
  props: ['group', 'current_user'],
  computed: {
    ...mapState(['config', 'admin_override']),
    edit_text() {
      return this.edit ? 'lock' : 'edit'
    },
    group_object() {
      return { group: { name: this.local_name } }
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