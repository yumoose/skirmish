.row
  h2.col.justify-content-between.btn-toolbar
    span.heading-text Tournament
    .btn-group
      span.toggle-button-group
        .btn-group
          - if tournament.open?
            - if current_entrant
              == link_to(t("tournament.actions.leave"), "/leagues/#{league.id}/tournaments/#{tournament.id}/leave?_csrf=#{csrf_token}", "data-method": "delete", "data-confirm": "Are you sure you want to leave the tournament?", class: "btn btn-warning")
            - elsif current_player.try(&.member_of?(league))
              == form(action: "/leagues/#{league.id}/tournaments/#{tournament.id}/join", method: :post) do
                == csrf_tag
                == submit(t("tournament.actions.join"), class: "btn btn-primary")
          - elsif tournament.in_progress? && current_entrant
            == link_to(t("league.actions.log_game"), "/leagues/#{league.id}/games/new", class: "btn btn-primary")
      - if current_player.try(&.admin_of?(league))
        span.toggle-button-group
          .btn-group
            button type="button" class="btn btn-dark dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false"
              | Admin Tools
            .dropdown-menu.dropdown-menu-right
              - if tournament.open?
                == form(action: "/leagues/#{league.id}/tournaments/#{tournament.id}/start", method: :patch) do
                  == csrf_tag
                  == submit(t("tournament.actions.start"), class: "dropdown-item")
                .dropdown-dividerw
              == link_to(t("general.actions.delete"), "/leagues/#{league.id}/tournaments/#{tournament.id}?_csrf=#{csrf_token}", "data-method": "delete", "data-confirm": "Are you sure you want to delete the tournament?", class: "dropdown-item danger")

p
  | For
  == link_to(league.name, "/leagues/#{league.id}")

p.description == tournament.description.to_s

- if tournament.in_progress?
  == render(partial: "_in_progress.slang")
- elsif tournament.open?
  == render(partial: "_open.slang")
- elsif tournament.finished?
  == render(partial: "_finished.slang")
