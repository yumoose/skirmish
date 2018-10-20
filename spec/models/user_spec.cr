require "./spec_helper"
require "../../src/models/user.cr"

describe User do
  describe "validations" do
    describe "email_address" do
      it "must be present" do
        user = User.new({
          email: "",
          verification_code: Random::Secure.hex(8),
          receive_email_notifications: false
        })
        user.password = Random::Secure.hex

        user.valid?.should eq false

        user.email = "#{Random::Secure.hex}@test.com"
        user.valid?.should eq true
      end

      it "must be a valid email address" do
        user = User.new({
          email: "#{Random::Secure.hex}@test.com",
          verification_code: Random::Secure.hex(8),
          receive_email_notifications: false
        })
        user.password = Random::Secure.hex

        user.valid?.should eq true

        user.email = "#{Random::Secure.hex}"
        user.valid?.should eq false

        user.email = "a@a.com"
        user.valid?.should eq true

        user.email = "@gmail.com"
        user.valid?.should eq false
      end
    end

    describe "verification_code" do
      it "must be present" do
        user = User.new({
          email: "#{Random::Secure.hex}@test.com",
          verification_code: "",
          receive_email_notifications: false
        })
        user.password = Random::Secure.hex

        user.valid?.should eq false

        user.verification_code = Random::Secure.hex(8)
        user.valid?.should eq true
      end

      it "must be 16 characters long" do
        user = User.new({
          email: "#{Random::Secure.hex}@test.com",
          verification_code: "123456789012345",
          receive_email_notifications: false
        })
        user.password = Random::Secure.hex

        user.valid?.should eq false

        user.verification_code = "1234567890123456"
        user.valid?.should eq true

        user.verification_code = "12345678901234567"
        user.valid?.should eq false
      end

      it "must not contain special characters" do
        user = User.new({
          email: "#{Random::Secure.hex}@test.com",
          verification_code: "abc456789012345",
          receive_email_notifications: false
        })
        user.password = Random::Secure.hex

        user.verification_code = "!234567890123456"
        user.valid?.should eq false
      end

      it "must be lowercase" do
        user = User.new({
          email: "#{Random::Secure.hex}@test.com",
          verification_code: "abc4567890123456",
          receive_email_notifications: false
        })
        user.password = Random::Secure.hex

        user.valid?.should eq true

        user.verification_code = "ABCDEFGH90123456"
        user.valid?.should eq false

        user.verification_code = "abcdefgh90123456"
        user.valid?.should eq true
      end
    end
  end

  describe "#activated?" do
    context "when the user has not yet been activated" do
      it "is false" do
        user = create_player_with_mock_user.user!

        user.activated?.should eq false
      end
    end

    context "when the user has been activated" do
      it "is true" do
        user = create_player_with_mock_user.user!
        user.activated_at = Time.now

        user.activated?.should eq true
      end
    end
  end

  pending do
    it "has specs"
  end
end
