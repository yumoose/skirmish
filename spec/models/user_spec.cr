require "./spec_helper"
require "../../src/models/user.cr"

describe User do
  describe "scopes" do
    describe "unverified" do
      it "includes users that haven't been activated" do
        unverified_user = create_player_with_mock_user(verified: false).user!

        User.unverified.pluck(:id).should contain unverified_user.id
      end

      it "excludes users that have been activated" do
        verified_user = create_player_with_mock_user.user!

        User.unverified.pluck(:id).should_not contain verified_user.id
      end
    end
  end

  describe "validations" do
    describe "name" do
      it "must be present" do
        user = User.new({
          name: "",
          email: "lebron.james@skirmish.online",
          verification_code: Random::Secure.hex(8),
          receive_email_notifications: false
        })
        user.password = Random::Secure.hex

        user.valid?.should be_false

        user.name = "LeBron James"
        user.valid?.should be_true
      end
    end

    describe "email_address" do
      it "must be present" do
        user = User.new({
          name: "Cristiano Ronaldo",
          email: "",
          verification_code: Random::Secure.hex(8),
          receive_email_notifications: false
        })
        user.password = Random::Secure.hex

        user.valid?.should be_false

        user.email = "#{Random::Secure.hex}@test.com"
        user.valid?.should be_true
      end

      it "must be a valid email address" do
        user = User.new({
          name: "Cristiano Ronaldo",
          email: "#{Random::Secure.hex}@test.com",
          verification_code: Random::Secure.hex(8),
          receive_email_notifications: false
        })
        user.password = Random::Secure.hex

        user.valid?.should be_true

        user.email = "#{Random::Secure.hex}"
        user.valid?.should be_false

        user.email = "a@a.com"
        user.valid?.should be_true

        user.email = "@gmail.com"
        user.valid?.should be_false

        user.email = "alice@skirmish.online"
        user.valid?.should be_true
      end
    end

    describe "verification_code" do
      it "must be present" do
        user = User.new({
          name: "Cristiano Ronaldo",
          email: "#{Random::Secure.hex}@test.com",
          verification_code: "",
          receive_email_notifications: false
        })
        user.password = Random::Secure.hex

        user.valid?.should be_false

        user.verification_code = Random::Secure.hex(8)
        user.valid?.should be_true
      end

      it "must be 16 characters long" do
        user = User.new({
          name: "Cristiano Ronaldo",
          email: "#{Random::Secure.hex}@test.com",
          verification_code: "123456789012345",
          receive_email_notifications: false
        })
        user.password = Random::Secure.hex

        user.valid?.should be_false

        user.verification_code = "1234567890123456"
        user.valid?.should be_true

        user.verification_code = "12345678901234567"
        user.valid?.should be_false
      end

      it "must not contain special characters" do
        user = User.new({
          name: "Cristiano Ronaldo",
          email: "#{Random::Secure.hex}@test.com",
          verification_code: "abc456789012345",
          receive_email_notifications: false
        })
        user.password = Random::Secure.hex

        user.verification_code = "!234567890123456"
        user.valid?.should be_false
      end

      it "must be lowercase" do
        user = User.new({
          name: "Cristiano Ronaldo",
          email: "#{Random::Secure.hex}@test.com",
          verification_code: "abc4567890123456",
          receive_email_notifications: false
        })
        user.password = Random::Secure.hex

        user.valid?.should be_true

        user.verification_code = "ABCDEFGH90123456"
        user.valid?.should be_false

        user.verification_code = "abcdefgh90123456"
        user.valid?.should be_true
      end
    end
  end

  describe "#activate!" do
    context "when the user is unverified/inactive" do
      it "sets the activated time of the user" do
        user = create_player_with_mock_user(verified: false).user!

        user.activated_at.should eq nil
        user.activate!
        user.activated_at.should_not eq nil
        user.activated_at.should be_a(Time)
      end

      it "activates/verifies the user" do
        user = create_player_with_mock_user(verified: false).user!
        user.activate!

        user.activated?.should be_true
        user.unverified?.should be_false
      end
    end

    context "when the user is already activated" do
      it "doesn't update the activation time" do
        user = create_player_with_mock_user(verified: false).user!

        original_activation_time = Time.epoch(0)
        user.update!(activated_at: original_activation_time)

        user.activate!
        user.activated_at.should eq original_activation_time
      end
    end
  end

  describe "#activated?" do
    context "when the user has not yet been activated" do
      it "is false" do
        user = create_player_with_mock_user(verified: false).user!

        user.activated?.should be_false
      end
    end

    context "when the user has been activated" do
      it "is true" do
        user = create_player_with_mock_user.user!

        user.activated?.should be_true
      end
    end
  end

  describe "#unverified?" do
    context "when the user has not yet been activated" do
      it "is true" do
        user = create_player_with_mock_user(verified: false).user!

        user.unverified?.should be_true
      end
    end

    context "when the user has been activated" do
      it "is false" do
        user = create_player_with_mock_user.user!

        user.unverified?.should be_false
      end
    end
  end
end
