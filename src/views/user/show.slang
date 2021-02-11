.row
  h2.col.justify-content-between.btn-toolbar
    span.heading-text Profile
    - if is_own_profile
      .button-group
        == link_to(t("profile.actions.edit"), "/profile/edit", class: "btn btn-primary")
        == link_to(t("authentication.sign_out"), "/signout", class: "btn btn-dark")

.player-profile.animated.zoomIn.fast
  img.gravatar src="#{gravatar_src_for(player)}"
  h3.tag = player.tag
  h3.name = user.name

- if is_own_profile
  h3 Unconfirmed Games
  .unconfirmed_games.tiles
    - player.unconfirmed_games.each do |game|
      == render(partial: "_game_tile.slang")

h3 Leagues
.leagues
  - player.active_leagues_query.where { _id.in(League.visible_to(current_player.not_nil!).pluck(:id)) }.each do |league|
    == render(partial: "_league_stats.slang")
