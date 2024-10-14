require "administrate/base_dashboard"

class GameDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    away_score: Field::Number,
    away_team: Field::String,
    away_team_id: Field::Number,
    calendar: Field::BelongsTo,
    completed: Field::Boolean,
    favored_team_id: Field::Number,
    group_games: Field::HasMany,
    groups: Field::HasMany,
    home_score: Field::Number,
    home_team: Field::String,
    home_team_id: Field::Number,
    odds: Field::Number.with_options(decimals: 2),
    picks: Field::HasMany,
    remote_game_id: Field::Number,
    set_odds: Field::Number,
    week: Field::String,
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
    away_score
    away_team
    away_team_id
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    id
    away_score
    away_team
    away_team_id
    calendar
    completed
    favored_team_id
    group_games
    groups
    home_score
    home_team
    home_team_id
    odds
    picks
    remote_game_id
    set_odds
    week
    created_at
    updated_at
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
    away_score
    away_team
    away_team_id
    calendar
    completed
    favored_team_id
    group_games
    groups
    home_score
    home_team
    home_team_id
    odds
    picks
    remote_game_id
    set_odds
    week
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

  # Overwrite this method to customize how games are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(game)
  #   "Game ##{game.id}"
  # end
end
