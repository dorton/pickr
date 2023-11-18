<template>
  <div>
    <v-tooltip location="top" text="Remove Self From Group">
      <template v-slot:activator="{ props }">
        <v-btn v-bind="props" @click="dialog = !dialog" class="float-right" flat icon="mdi-close" size="x-small"></v-btn>
      </template>
    </v-tooltip>

      <v-dialog v-model="dialog" width="400">
        <v-card>
          <v-card-text>
            You are about to remove yourself from this group. To join again either find in the drop down menu if it is a
            public group, or enter the private group code.
          </v-card-text>
          <v-card-actions>
            <v-btn color="error" block @click="removeFromGroup()">Confirm</v-btn>
          </v-card-actions>
        </v-card>
      </v-dialog>
  </div>
</template>

<script>
import axios from 'axios'
import { router } from '@inertiajs/vue3'
export default {
  name: "RemoveFromGroup",
  created() { },
  data() {
    return {
      dialog: false
    };
  },
  props: ['user', 'group', 'config'],
  methods: {
    removeFromGroup() {
      let data = { user_id: this.user.id, group_id: this.group.id, group_slug: this.group.slug }
      let url = '/removeuser'
      axios.post(url, data, this.config).then(r => {
        if (r.status < 400) {
          this.dialog = false
          router.reload()
        }
      })
    },
  },
};
</script>

<style lang="scss" scoped></style>