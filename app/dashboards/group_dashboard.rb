require "administrate/base_dashboard"

class GroupDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    defaults: Field::HasMany,
    games: Field::HasMany,
    group_games: Field::HasMany,
    group_managers: Field::HasMany,
    group_picks: Field::HasMany,
    is_private: Field::Boolean,
    league: Field::String,
    managers: Field::HasMany,
    max_picks: Field::Number,
    name: Field::String,
    over_under: Field::Boolean,
    picks: Field::HasMany,
    post_season: Field::Boolean,
    regular_season: Field::Boolean,
    slug: Field::String,
    sport: Field::String,
    spread: Field::Boolean,
    user_group_defaults: Field::HasMany,
    user_groups: Field::HasMany,
    users: Field::HasMany,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i[
    id
    defaults
    games
    group_games
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    id
    defaults
    games
    group_games
    group_managers
    group_picks
    is_private
    league
    managers
    max_picks
    name
    over_under
    picks
    post_season
    regular_season
    slug
    sport
    spread
    user_group_defaults
    user_groups
    users
    created_at
    updated_at
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
    defaults
    games
    group_games
    group_managers
    group_picks
    is_private
    league
    managers
    max_picks
    name
    over_under
    picks
    post_season
    regular_season
    slug
    sport
    spread
    user_group_defaults
    user_groups
    users
  ].freeze

  # COLLECTION_FILTERS
  # a hash that defines filters that can be used while searching via the search
  # field of the dashboard.
  #
  # For example to add an option to search for open resources by typing "open:"
  # in the search field:
  #
  #   COLLECTION_FILTERS = {
  #     open: ->(resources) { resources.where(open: true) }
  #   }.freeze
  COLLECTION_FILTERS = {}.freeze

  # Overwrite this method to customize how groups are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(group)
  #   "Group ##{group.id}"
  # end
end
