require "./spec_helper"
require "../../src/models/player.cr"

describe Player do
  player = create_player_with_mock_user

  describe "validations" do
    describe "user" do
      it "must exist" do
        player.user_id = 9999.to_i64
        player.valid?.should be_false
        player.errors.full_messages.join(",").should match /User must exist/
      end

      it "must be unique" do
        another_player = create_player_with_mock_user

        player.user_id = another_player.user!.id
        player.valid?.should be_false
        player.errors.full_messages.join(",").should match /User has already been taken/
      end
    end

    describe "tag" do
      it "must be between 3 and 16 characters in length" do
        player.tag = "a"
        player.valid?.should be_false
        player.errors.full_messages.join(",").should match /Tag is too short/

        player = player.reload
        player.tag = "a" * 17
        player.valid?.should be_false
        player.errors.full_messages.join(",").should match /Tag is too long/

        player = player.reload
        player.tag = "nametag"
        player.valid?.should be_true
      end

      it "must only letters, numbers, or symbols" do
        player.tag = "a a a 1 2 3"
        player.valid?.should be_false
        player.errors.full_messages.join(",").should match /Tag must start with a letter and can only include letters, numbers, or symbols/

        player = player.reload
        player.tag = "_sexgod_"
        player.valid?.should be_false
        player.errors.full_messages.join(",").should match /Tag must start with a letter and can only include letters, numbers, or symbols/

        player = player.reload
        player.tag = "N-4_.n._D-4"
        player.valid?.should be_true
      end
    end
  end

  describe "#rating_for" do
    context "when the player hasn't particpated in any games" do
      it "is the league's default rating" do
        league = create_league

        Membership.create!(
          player_id: player.id,
          league_id: league.id
        )

        player.rating_for(league).should eq league.start_rating

        new_start_rating = 1500
        league.update!(start_rating: new_start_rating)
        player.rating_for(league).should eq new_start_rating
      end
    end
  end

  describe "#member_of?" do
    context "when the player has a membership in the league" do
      league = create_league

      membership = Membership.create!(
        player_id: player.id,
        league_id: league.id
      )

      context "that is active" do
        it "is true" do
          player.member_of?(league).should be_true
        end
      end

      context "that has ended" do
        it "is false" do
          membership.update!(
            left_at: Time.local
          )

          player.member_of?(league).should be_false
        end
      end
    end

    context "when the player has no membership in the league" do
      it "is false" do
        league = create_league

        player.member_of?(league).should be_false
      end
    end
  end

  describe "#active_leagues_query" do
    league = create_league
    joined_league = create_league
    left_league = create_league

    Membership.create!(
      player_id: player.id,
      league_id: joined_league.id
    )

    Membership.create!(
      player_id: player.id,
      league_id: left_league.id,
      left_at: Time.local
    )

    it "doesn't contain leagues the player has never joined" do
      player.active_leagues_query.to_a.map(&.id).should_not contain league.id
    end

    it "contains leagues the player has joined" do
      player.active_leagues_query.to_a.map(&.id).should contain joined_league.id
    end

    it "doesn't contain leagues the player has left" do
      player.active_leagues_query.to_a.map(&.id).should_not contain left_league.id
    end
  end

  describe "#display_name" do
    context "a player with a tag that matches their name" do
      name_and_tag = "Player"

      player.user!.name = name_and_tag
      player.tag = name_and_tag

      player.display_name.should eq name_and_tag
    end

    context "a player with a tag that differs from their name" do
      player.user!.name = "Jeffers"
      player.tag = "Sir"

      player.display_name.should eq "Sir (Jeffers)"
    end
  end

  describe "to_h" do
    it "includes the player's name" do
      player.to_h[:id].should eq player.id
    end

    it "includes the player's tag" do
      player.to_h[:tag].should eq player.tag
    end

    it "includes the player's avatar image url" do
      player.to_h[:image_url].should_not eq nil
    end
  end

  pending do
    it "has specs"
  end
end
