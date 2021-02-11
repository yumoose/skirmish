require "./spec_helper"

include GarnetSpec::RequestHelper

describe SessionController do
  describe "#show" do
    context "when a user is already signed in" do
      it "redirects to the landing page" do
        player = create_player_with_mock_user
        response = get "/signin", headers: authenticated_headers_for(player)

        response.status_code.should eq(302)
        response.headers["Location"].should eq "/leagues"
      end
    end

    context "when the user is not signed in" do
      it "successfully renders the page" do
        response = get "/signin"

        response.status_code.should eq(200)
      end

      it "contains a form to sign in" do
        response = get "/signin"

        response.body.should contain("Email")
        response.body.should contain("Password")
        response.body.should contain("Sign In")
      end

      it "contains a link for new users to create an account" do
        response = get "/signin"

        response.body.should contain("Don't have an account yet?")
        response.body.should contain("/signup")
      end
    end
  end

  describe "#create" do
    context "when the user for the email address isn't verified" do
      it "redirects to the verification page" do
        password = "abc123"
        user = create_player_with_mock_user(password: password, verified: false).user!

        login_params = { email: user.email, password: password }.to_h
        response = post "/session", body: params_from_hash(login_params)

        response.status_code.should eq(302)
        response.headers["Location"].should eq "/verification?email=#{user.email}"
      end
    end

    context "when a user for the email doesn't exist" do
      it "renders the sign in form" do
        login_params = { email: "non_existent_user", password: "password" }.to_h
        response = post "/session", body: params_from_hash(login_params)

        response.status_code.should eq(200)
        response.body.should contain "Invalid email or password"
      end
    end

    context "when trying to login with a password that doesn't match" do
      it "renders the sign in form" do
        user = create_player_with_mock_user(password: "abc123").user!
        user.activate!

        login_params = { email: user.email, password: "321cba" }.to_h
        response = post "/session", body: params_from_hash(login_params)

        response.status_code.should eq(200)
        response.body.should contain "Invalid email or password"
      end
    end

    context "when authenticating an activated user with the correct password" do
      it "redirects to the landing page" do
        password = "abc123"
        user = create_player_with_mock_user(password: password).user!
        user.activate!

        login_params = { email: user.email, password: password }.to_h
        response = post "/session", body: params_from_hash(login_params)

        response.status_code.should eq(302)
        response.headers["Location"].should eq "/leagues"
      end
    end
  end
end
