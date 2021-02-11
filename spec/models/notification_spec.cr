require "./spec_helper"
require "../../src/models/notification.cr"

describe Notification do
  player = create_player_with_mock_user

  describe "validations" do
    describe "player" do
      it "must be a associated to an existing player" do
        notification = create_notification(player: Player.all.first!)
        notification.player_id = nil

        notification.valid?.should be_false
      end
    end

    describe "title" do
      it "must be present" do
        notification = create_notification(player: Player.all.first!)

        notification.title = ""
        notification.valid?.should be_false

        notification.title = "Some Title"
        notification.valid?.should be_true
      end
    end

    describe "content" do
      it "must be present" do
        notification = create_notification(player: Player.all.first!)

        notification.content = ""
        notification.valid?.should be_false

        notification.content = "Some Content"
        notification.valid?.should be_true
      end
    end
  end

  describe "#read?" do
    context "when the notification has no date of reading" do
      it "is false" do
        notification = create_notification(player: Player.all.first!)

        notification.read?.should be_false
      end
    end

    context "when the notification has a date of reading" do
      it "is true" do
        notification = create_notification(player: Player.all.first!)
        notification.read_at = Time.local

        notification.read?.should be_true
      end
    end
  end

  describe "#read!" do
    context "when the notification has not been read before" do
      it "marks the notification as read" do
        notification = create_notification(player: Player.all.first!)
        notification.read?.should be_false

        notification.read!
        notification.read?.should be_true
      end
    end

    context "when the notification has already been read" do
      it "keeps the notification's original read time untouched" do
        notification = create_notification(player: Player.all.first!)
        original_read_time = Time.local
        notification.read_at = original_read_time

        notification.read!
        notification.read_at.should eq original_read_time
      end
    end
  end
end
