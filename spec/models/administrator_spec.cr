require "./spec_helper"
require "../../src/models/administrator.cr"

def build_admin
  player = create_player_with_mock_user
  league = create_league

  Administrator.build.tap do |admin|
    admin.player_id = player.id.not_nil!
    admin.league_id = league.id.not_nil!
  end
end

describe Administrator do
  describe "validations" do
    context "player" do
      context "a valid player" do
        it "is valid" do
          admin = build_admin

          admin.valid?.should be_true
          admin.errors.size.should eq 0
        end
      end

      context "when no player is given" do
        it "is invalid" do
          admin = build_admin
          admin.update_attributes(player_id: nil)

          admin.valid?.should be_false
          admin.errors.full_messages.join(", ").should match /Player can't be blank/
        end
      end

      context "when the player doesn't exist" do
        it "is invalid" do
          admin = build_admin
          admin.player_id = 9999

          admin.valid?.should be_false
          admin.errors.full_messages.join(", ").should match /Player must exist/
        end
      end
    end

    context "league" do
      context "a valid league" do
        it "is valid" do
          admin = build_admin

          admin.valid?.should be_true
          admin.errors.size.should eq 0
        end
      end

      context "when no league is given" do
        it "is invalid" do
          admin = build_admin
          admin.update_attributes(league_id: nil)

          admin.valid?.should be_false
          admin.errors.full_messages.join(", ").should match /League can't be blank/
        end
      end

      context "when the league doesn't exist" do
        it "is invalid" do
          admin = build_admin
          admin.update_attributes(league_id: 9999.to_i64)

          admin.valid?.should be_false
          admin.errors.full_messages.join(", ").should match /League must exist/
        end
      end
    end
  end
end
