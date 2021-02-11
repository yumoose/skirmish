require "./spec_helper"

include GarnetSpec::RequestHelper

describe VerificationController do
  describe "#show" do
    context "when the user for the email is already activated" do
      it "redirects to the sign in page" do
        user = create_player_with_mock_user.user!

        response = get "/verification?email=#{user.email}"

        response.status_code.should eq(302)
        response.headers["Location"].should match(/\/signin/)
      end
    end

    context "when a user for the email doesn't exist" do
      it "redirects to the signin page" do
        response = get "/verification?email=non_existent_email"

        response.status_code.should eq(302)
        response.headers["Location"].should eq "/signin"
      end
    end

    context "when the user for the email is unverified" do
      it "sucessfully renders the page" do
        user = create_player_with_mock_user(verified: false).user!
        response = get "/verification?email=#{user.email}"

        response.status_code.should eq(200)
      end

      it "contains the 'account created' message" do
        user = create_player_with_mock_user(verified: false).user!
        response = get "/verification?email=#{user.email}"

        response.body.should contain "Account Created"
      end

      it "contains verification instructions" do
        user = create_player_with_mock_user(verified: false).user!
        response = get "/verification?email=#{user.email}"

        response.body.should contain "An email has been sent"
      end
    end
  end

  describe "#verify" do
    context "when the user for the email is already activated" do
      it "redirects to the sign in page" do
        user = create_player_with_mock_user.user!

        response = get "/verify/#{user.verification_code}"

        response.status_code.should eq(302)
        response.headers["Location"].should match(/\/signin/)
      end
    end

    context "when a user for the email doesn't exist" do
      it "redirects to the landing page" do
        response = get "/verify/abc123"

        response.status_code.should eq(302)
        response.headers["Location"].should eq "/"
      end
    end

    context "when the user for the email is unverified" do
      it "redirects to the sign in page" do
        user = create_player_with_mock_user(verified: false).user!
        response = get "/verify/#{user.verification_code}"

        response.status_code.should eq(302)
        response.headers["Location"].should match(/\/signin/)
      end

      it "successfully activates the user" do
        user = create_player_with_mock_user(verified: false).user!
        user.activated?.should be_false

        response = get "/verify/#{user.verification_code}"
        user.reload

        user.activated?.should be_true
      end
    end
  end
end
