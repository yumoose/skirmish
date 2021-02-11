require "./spec_helper"

include GarnetSpec::RequestHelper

describe LeagueController do
  describe "#index" do
    context "with no leagues exist" do
      it "renders league index template" do
        response = get "/leagues"

        response.status_code.should eq(200)
        response.body.should contain("leagues")
      end
    end

    context "when a league exists" do
      it "renders league index template" do
        response = get "/leagues"

        response.status_code.should eq(200)
        response.body.should contain("leagues")
      end
    end
  end

  describe "#show" do
    it "renders league show template" do
      league = create_league
      response = get "/leagues/#{league.id}", headers: basic_authenticated_headers

      response.status_code.should eq(200)
      response.body.should contain(league.name)
    end

    context "when the league doesn't exist" do
      it "redirects back to the leagues listing" do
        response = get "/leagues/99999", headers: basic_authenticated_headers

        response.status_code.should eq(302)
        response.headers["Location"].should eq "/leagues"
      end
    end

    context "when logged out" do
      it "redirects to the login page" do
        league = create_league
        response = get "/leagues/#{league.id}"

        response.status_code.should eq(302)
        response.headers["Location"].should match(/\/signin/)
      end
    end
  end

  describe "#new" do
    context "when logged in" do
      it "renders the new league template" do
        response = get "/leagues/new", headers: basic_authenticated_headers

        response.status_code.should eq(200)
        response.body.should contain("League Details")
      end
    end

    context "when logged out" do
      it "redirects to the login page" do
        response = get "/leagues/new"

        response.status_code.should eq(302)
        response.headers["Location"].should match(/\/signin/)
      end
    end
  end

  describe "#edit" do
    context "when logged in" do
      it "renders the new league template" do
        league = create_league
        response = get "/leagues/#{league.id}/edit", headers: admin_authenticated_headers(league)

        response.status_code.should eq(200)
        response.body.should contain("League Details")
      end
    end

    context "when logged out" do
      it "redirects to the login page" do
        league = create_league
        response = get "/leagues/#{league.id}/edit"

        response.status_code.should eq(302)
        response.headers["Location"].should match(/\/signin/)
      end
    end
  end

  describe "#stats" do
    league = create_league
    player = create_player_with_mock_user

    it "returns json" do
      response = get "/leagues/#{league.id}/stats/#{player.tag}", headers: basic_authenticated_headers

      response.status_code.should eq(200)
      parsed_body = JSON.parse(response.body)

      parsed_body["league_name"].should eq league.name
      parsed_body["league_color"].should eq league.accent_color
    end

    context "when the league doesn't exist" do
      response = get "/leagues/-1/stats/#{player.tag}", headers: basic_authenticated_headers

      response.status_code.should eq(302)
      response.headers["Location"].should match(/\/leagues/)
    end

    context "when the player doesn't exist" do
      response = get "/leagues/#{league.id}/stats/mr.nobody", headers: basic_authenticated_headers

      response.status_code.should eq(302)
      response.headers["Location"].should match(/\//)
    end

    context "when the current player doesn't have visibility of the league" do
      league = create_league(visibility: League::SECRET)

      response = get "/leagues/#{league.id}/stats/mr.nobody", headers: basic_authenticated_headers

      response.status_code.should eq(302)
      response.headers["Location"].should match(/\//)
    end

    context "when logged out" do
      league = create_league

      it "redirects to the login page" do
        response = get "/leagues/#{league.id}/stats/#{player.tag}"

        response.status_code.should eq(302)
        response.headers["Location"].should match(/\/signin/)
      end
    end
  end

  describe "#create" do
    league_props = {
      name: "new league",
      description: "some description",
      accent_color: "#abc123",
      custom_icon_url: "https://some.icon/url",
      visibility: League::OPEN,
      start_rating: League::DEFAULT_START_RATING,
      k_factor: League::DEFAULT_K_FACTOR
    }.to_h

    body = params_from_hash(league_props)

    context "when logged in" do
      it "creates a league" do
        leagues_before = League.all.count
        post "/leagues", headers: basic_authenticated_headers, body: body

        League.all.count.should eq(leagues_before + 1)
      end

      it "creates an administrator" do
        administrators_before = Administrator.all.count
        post "/leagues", headers: basic_authenticated_headers, body: body

        Administrator.all.count.should eq(administrators_before + 1)
      end

      it "creates a membership" do
        administrators_before = Membership.all.count
        post "/leagues", headers: basic_authenticated_headers, body: body

        Membership.all.count.should eq(administrators_before + 1)
      end

      it "redirects to the new league" do
        response = post "/leagues", headers: basic_authenticated_headers, body: body

        league = League.all.last!

        response.status_code.should eq(302)
        response.headers["Location"].should eq "/leagues/#{league.id}"
      end

      describe "the created league" do
        it "has the properties specified in the params" do
          post "/leagues", headers: basic_authenticated_headers, body: body

          league = League.all.last!

          league.name.should eq league_props[:name]
          league.description.should eq league_props[:description]
          league.accent_color.should eq league_props[:accent_color]
          league.custom_icon_url.should eq league_props[:custom_icon_url]
          league.visibility.should eq league_props[:visibility]
          league.start_rating.should eq league_props[:start_rating]
          league.k_factor.should eq league_props[:k_factor]
        end
      end

      describe "the created admin role" do
        it "is granted to the logged in player and created league" do
          player = create_player_with_mock_user
          post "/leagues", headers: authenticated_headers_for(player.user.not_nil!), body: body

          admin = Administrator.all.last!
          league = League.all.last!

          admin.player_id.should eq player.id
          admin.league_id.should eq league.id
        end
      end

      describe "the created membership" do
        it "is created for the logged in player in the new league" do
          player = create_player_with_mock_user
          post "/leagues", headers: authenticated_headers_for(player.user.not_nil!), body: body

          membership = Membership.all.last!
          league = League.all.last!

          membership.player_id.should eq player.id
          membership.league_id.should eq league.id
        end
      end
    end

    context "when logged out" do
      it "redirects to the login page" do
        response = post "/leagues", body: body

        response.status_code.should eq(302)
        response.headers["Location"].should match(/\/signin/)
      end
    end
  end

  describe "#update" do
    league_props = {
      name: "new league",
      description: "some description",
      accent_color: "#abc123",
      custom_icon_url: "https://some.icon/url",
      visibility: League::OPEN,
      start_rating: League::DEFAULT_START_RATING,
      k_factor: League::DEFAULT_K_FACTOR
    }.to_h

    body = params_from_hash(league_props)

    context "when logged in" do
      it "redirects to the league" do
        league = create_league
        response = patch "/leagues/#{league.id}", headers: admin_authenticated_headers(league), body: body

        response.status_code.should eq(302)
        response.headers["Location"].should eq "/leagues/#{league.id}"
      end

      describe "the updated league" do
        it "has the properties specified in the params" do
          league = create_league
          patch "/leagues/#{league.id}", headers: admin_authenticated_headers(league), body: body

          # reload the league
          league = League.find!(league.id)

          league.name.should eq league_props[:name]
          league.description.should eq league_props[:description]
          league.accent_color.should eq league_props[:accent_color]
          league.custom_icon_url.should eq league_props[:custom_icon_url]
          league.visibility.should eq league_props[:visibility]
          league.start_rating.should eq league_props[:start_rating]
          league.k_factor.should eq league_props[:k_factor]
        end
      end
    end

    context "when logged out" do
      it "redirects to the login page" do
        league = create_league
        response = patch "/leagues/#{league.id}", body: body

        response.status_code.should eq(302)
        response.headers["Location"].should match(/\/signin/)
      end
    end
  end

  describe "#delete" do
    context "when logged in" do
      it "deletes the league" do
        league = create_league
        response = delete "/leagues/#{league.id}", headers: admin_authenticated_headers(league)

        response.status_code.should eq(302)
        response.headers["Location"].should eq "/leagues"
      end

      context "when a game has been played" do
        it "deletes the game as well" do
          player = create_player_with_mock_user
          league = create_league

          game = Game.create!({
            league_id: league.id,
            logged_by_id: player.id
          })
          game_id = game.id

          delete "/leagues/#{league.id}", headers: admin_authenticated_headers(league)

          Game.where { _league_id == game_id }.to_a.size.should eq 0
        end
      end
    end

    context "when logged out" do
      it "redirects to the login page" do
        response = get "/leagues/new"

        response.status_code.should eq(302)
        response.headers["Location"].should match(/\/signin/)
      end
    end
  end
end
