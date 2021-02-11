require "./spec_helper"

include GarnetSpec::RequestHelper

describe MembershipController do
  describe "#create" do
    context "when logged in as a player" do
      it "creates a membership" do
        league = create_league
        memberships_before = Membership.all.count

        post "/leagues/#{league.id}/join", headers: basic_authenticated_headers

        Membership.all.count.should eq memberships_before + 1
      end

      it "redirects back to the league" do
        league = create_league
        response = post "/leagues/#{league.id}/join", headers: basic_authenticated_headers

        response.status_code.should eq(302)
        response.headers["Location"].should eq "/leagues/#{league.id}"
      end

      describe "the created membership" do
        it "belongs to the authenticated player" do
          league = create_league
          player = create_player_with_mock_user

          post "/leagues/#{league.id}/join", headers: authenticated_headers_for(player)

          Membership.all.last!.player.should eq player
        end

        it "is active" do
          league = create_league
          post "/leagues/#{league.id}/join", headers: basic_authenticated_headers

          Membership.all.last!.active?.should be_true
        end
      end
    end

    context "when the membership already exists" do
      it "doesn't create another membership" do
        league = create_league
        player = create_player_with_mock_user
        membership = Membership.create!(league_id: league.id, player_id: player.id, joined_at: Time.local)
        memberships_before = Membership.all.count

        post "/leagues/#{league.id}/join", headers: authenticated_headers_for(player.user.not_nil!)

        Membership.all.count.should eq memberships_before
      end

      it "redirects back to the league" do
        league = create_league
        player = create_player_with_mock_user
        membership = Membership.create!(league_id: league.id, player_id: player.id, joined_at: Time.local)

        response = post "/leagues/#{league.id}/join", headers: authenticated_headers_for(player.user.not_nil!)

        response.status_code.should eq(302)
        response.headers["Location"].should eq "/leagues/#{league.id}"
      end
    end

    context "when logged out" do
      it "doesn't create a membership" do
        league = create_league
        memberships_before = Membership.all.count

        response = post "/leagues/#{league.id}/join"

        Membership.all.count.should eq memberships_before
      end

      it "redirects to the login page" do
        league = create_league
        response = post "/leagues/#{league.id}/join"

        response.status_code.should eq(302)
        response.headers["Location"].should match(/\/signin/)
      end
    end
  end

  describe "#update" do
    context "leaving a league" do
      it "deactivates the membership" do
        league = create_league
        player = create_player_with_mock_user
        membership = Membership.create!(league_id: league.id, player_id: player.id, joined_at: Time.local)

        patch "/leagues/#{league.id}/leave", headers: authenticated_headers_for(player.user.not_nil!)

        membership = Membership.find!(membership.id)
        membership.active?.should be_false
      end

      it "doesn't destroy any memberships" do
        league = create_league
        player = create_player_with_mock_user
        membership = Membership.create!(league_id: league.id, player_id: player.id, joined_at: Time.local)

        memberships_before = Membership.all.count
        patch "/leagues/#{league.id}/leave", headers: authenticated_headers_for(player.user.not_nil!)

        Membership.all.count.should eq memberships_before
      end

      it "redirects back to the league" do
        league = create_league
        player = create_player_with_mock_user
        membership = Membership.create!(league_id: league.id, player_id: player.id, joined_at: Time.local)

        response = patch "/leagues/#{league.id}/leave", headers: authenticated_headers_for(player.user.not_nil!)

        response.status_code.should eq(302)
        response.headers["Location"].should eq "/leagues/#{league.id}"
      end

      context "when logged out" do
        it "doesn't deactivate the membership" do
          league = create_league
          player = create_player_with_mock_user
          membership = Membership.create!(league_id: league.id, player_id: player.id, joined_at: Time.local)

          response = patch "/leagues/#{league.id}/leave"

          membership = Membership.find!(membership.id)
          membership.active?.should be_true
        end

        it "redirects to the login page" do
          league = create_league
          player = create_player_with_mock_user
          membership = Membership.create!(league_id: league.id, player_id: player.id, joined_at: Time.local)

          response = patch "/leagues/#{league.id}/leave"

          response.status_code.should eq(302)
          response.headers["Location"].should match(/\/signin/)
        end
      end
    end

    context "re-joining a league" do
      it "re-activates the membership" do
        league = create_league
        player = create_player_with_mock_user
        membership = Membership.create!(league_id: league.id, player_id: player.id, joined_at: Time.local, left_at: Time.local)

        patch "/leagues/#{league.id}/join", headers: authenticated_headers_for(player.user.not_nil!)

        membership = Membership.find!(membership.id)
        membership.active?.should be_true
      end

      it "doesn't create another membership" do
        league = create_league
        player = create_player_with_mock_user
        membership = Membership.create!(league_id: league.id, player_id: player.id, joined_at: Time.local, left_at: Time.local)

        memberships_before = Membership.all.count
        patch "/leagues/#{league.id}/join", headers: authenticated_headers_for(player.user.not_nil!)

        Membership.all.count.should eq memberships_before
      end

      it "redirects back to the league" do
        league = create_league
        player = create_player_with_mock_user
        membership = Membership.create!(league_id: league.id, player_id: player.id, joined_at: Time.local, left_at: Time.local)

        response = patch "/leagues/#{league.id}/join", headers: authenticated_headers_for(player.user.not_nil!)

        response.status_code.should eq(302)
        response.headers["Location"].should eq "/leagues/#{league.id}"
      end

      context "when logged out" do
        it "doesn't re-activate the membership" do
          league = create_league
          player = create_player_with_mock_user
          membership = Membership.create!(league_id: league.id, player_id: player.id, joined_at: Time.local, left_at: Time.local)

          response = patch "/leagues/#{league.id}/join"

          membership = Membership.find!(membership.id)
          membership.active?.should be_false
        end

        it "redirects to the login page" do
          league = create_league
          player = create_player_with_mock_user
          membership = Membership.create!(league_id: league.id, player_id: player.id, joined_at: Time.local, left_at: Time.local)

          response = patch "/leagues/#{league.id}/join"

          response.status_code.should eq(302)
          response.headers["Location"].should match(/\/signin/)
        end
      end
    end
  end
end
