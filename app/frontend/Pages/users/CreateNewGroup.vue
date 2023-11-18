<template>
  <v-dialog width="800">
    <template v-slot:activator="{ props }">
      <v-card v-bind="props" class="h-100">
        <v-card-text class="d-flex align-center justify-center w-100 h-100 flex-column">
            <v-icon flat icon="mdi-plus" size="x-large"></v-icon>
            <div class="">Add New Group</div>
        </v-card-text>
      </v-card>
    </template>
    <template v-slot:default="{ isActive }">
      <v-card>
        <v-card-title>
          <v-row class="d-flex align-center justify-space-between">
            <v-col>
              <div> New Group </div>
            </v-col>
            <v-col class="d-flex justify-end">
            </v-col>
          </v-row>
        </v-card-title>
        <v-card-text>
          <v-row>
            <v-col>
                <v-form v-model="valid" ref="form" lazy-validation>
                  <v-text-field
                    label="Name"
                    v-model="group.name"
                    :rules="nameRules"
                    required
                  ></v-text-field>
                  <v-text-field
                    label="Slug"
                    v-model="group.slug"
                    disabled                    
                  ></v-text-field>
                  <v-select
                    label="Sport"
                    v-model="group.sport"
                    :items="sports"
                    :rules="[v => !!v || 'Sport is required']"
                    required
                  ></v-select>
                  <v-select
                    label="League"
                    v-model="group.league"
                    :items="leagues"
                    :rules="[v => !!v || 'League is required']"
                    required
                  ></v-select>
                  <v-checkbox
                    label="Regular Season Games?"
                    v-model="group.regular_season"
                  ></v-checkbox>
                  <v-checkbox
                    label="Post Season Games?"
                    v-model="group.post_season"
                  ></v-checkbox>
                  <v-checkbox
                    label="Private Group?"
                    v-model="group.is_private"
                  ></v-checkbox>
                  <v-text-field
                    label="Max Picks/Week"
                    v-model="group.max_picks"
                  ></v-text-field>
                  <v-btn
                    @click="submit(isActive)"
                    :disabled="!valid"
                  >
                    submit
                  </v-btn>
                  <v-btn @click="clear">clear</v-btn>
                </v-form>
            </v-col>
          </v-row>
        </v-card-text>
      </v-card>
    </template>
  </v-dialog>
</template>

<script>
import axios from "axios";
import { mapState } from 'vuex'
import { router } from '@inertiajs/vue3'
export default {
  data: () => ({
    group: {
      name: "",
      slug: "",
      sport: null,
      regular_season: true,
      league: null,
      post_season: true,
      max_picks: 10,
      is_private: true,
    },
    valid: true,
    nameRules: [v => !!v || "Name is required"],
  }),
  watch: {
    'group.name'(v) {
      this.group.slug = v.split(' ').map(w => w.toLowerCase()).join('_')
    }
  },
  props: ['current_user'],
  computed: {
    ...mapState(['config']),
    sports() {
      return ['football']
    },
    leagues() {
      return ['nfl', 'college-football']
    },
  },
  methods: {
    submit(isActive) {
      if (this.$refs.form.validate()) {
        axios.post("/groups", {group: this.group, user: this.current_user}, this.config).then(() => {
          isActive.value = false
          router.reload()
        });
      }
    },
    clear() {
      this.$refs.form.reset();
    }
  }
};
</script>

<style lang="scss" scoped></style>