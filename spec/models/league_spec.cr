require "./spec_helper"
require "../../src/models/league.cr"

def create_league!
  League.create!(
    name: "a newly created league",
    description: "some description",
    visibility: League::OPEN,
    start_rating: League::DEFAULT_START_RATING,
    k_factor: League::DEFAULT_K_FACTOR
  )
end

describe League do
  league = League.build(
    name: "a newly built league",
    description: "some description",
    visibility: League::OPEN,
    start_rating: League::DEFAULT_START_RATING,
    k_factor: League::DEFAULT_K_FACTOR
  )

  describe "validations" do
    describe "name" do
      it "must be present" do
        league.name = ""
        league.valid?.should be_false

        league.name = "Bob"
        league.valid?.should be_true
      end

      it "must be unique" do
        existing_league = create_league!
        league.name = existing_league.name

        league.valid?.should be_false
        league.errors.full_messages.join(", ").should match /Name has already been taken/
      end
    end

    describe "description" do
      it "must be present" do
        league.description = ""
        league.valid?.should be_false

        league.description = "Bob"
        league.valid?.should be_true
      end
    end

    describe "accent color" do
      it "must be present" do
        league.accent_color = ""
        league.valid?.should be_false

        league.accent_color = "#abc123"
        league.valid?.should be_true
      end

      it "must be of hex format" do
        league.accent_color = "rgb(123,123,123)"
        league.valid?.should be_false

        league.accent_color = "#abc123"
        league.valid?.should be_true
      end
    end

    describe "custom image URL" do
      it "is optional" do
        league.custom_icon_url = nil

        league.valid?.should be_true
      end

      it "must be a valid URL" do
        league.custom_icon_url = "not-a-url.com"
        league.valid?.should be_false

        league.custom_icon_url = "https://some-valid-looking-url.com/image"
        league.valid?.should be_true
      end
    end

    describe "start rating" do
      it "must be between 100 and 3000" do
        league.start_rating = 99
        league.valid?.should be_false
        league.errors.full_messages.join(", ").should match /Start rating must be greater than or equal to 100/

        league.start_rating = 3001
        league.valid?.should be_false
        league.errors.full_messages.join(", ").should match /Start rating must be less than or equal to 3000/

        league.start_rating = 1000
        league.valid?.should be_true
        league.errors.size.should eq 0
      end
    end

    describe "k-factor" do
      # TODO: Re-enable once Jennifer Numericality is fixed. Float64#even? and #odd? removed in 0.27.0.
      pending "must be between 1 and 100" do
        league.k_factor = 0.9
        league.valid?.should be_false
        league.errors.full_messages.join(", ").should match /K factor must be greater than or equal to 1/

        league.k_factor = 100.1
        league.valid?.should be_false
        league.errors.full_messages.join(", ").should match /K factor must be less than or equal to 100/

        league.k_factor = 32.0
        league.valid?.should be_true
        league.errors.size.should eq 0
      end
    end
  end

  describe "#active_players" do
    league = create_league!

    context "a brand new league" do
      it "has no active players" do
        league.active_players.size.should eq 0
      end
    end

    context "when there is a player with a membership in the league" do
      player = create_player_with_mock_user("player_one")
      membership = Membership.create!(
        league_id: league.id,
        player_id: player.id,
        joined_at: Time.local
      )

      it "has an active player" do
        league.active_players.size.should eq 1
      end

      context "but the membership is expired" do
        membership.update!(
          left_at: Time.local
        )

        it "has no active players" do
          league.active_players.size.should eq 0
        end
      end
    end
  end

  describe "#icon_url" do
    context "when the league has no custom icon URL set" do
      it "is the default trophy image URL" do
        league.custom_icon_url = nil

        league.icon_url.should eq League::TROPHY_GLYPH_URL
      end
    end

    context "when the league has a custom icon URL set" do
      custom_image_url = "http://some.image/url"
      league.custom_icon_url = custom_image_url

      league.icon_url.should eq custom_image_url
    end
  end
end
