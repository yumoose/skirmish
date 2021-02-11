class RegistrationController < ApplicationController
  def new
    user = User.build(name: "", email: "", verification_code: "")
    player = Player.build(tag: "")

    auth_provider_details = fetch_provider_details

    if auth_provider_details
      user.name = auth_provider_details["name"]?.to_s
      user.email = auth_provider_details["email"]?.to_s
      player.tag = auth_provider_details["tag"]?.to_s
    end

    render("new.slang")
  end

  def create
    Jennifer::Adapter.default_adapter.transaction do
      user = create_user_from_params
      player = create_player_from_params(user)

      if auth_provider_details = fetch_provider_details
        AuthProvider.create!(
          provider: auth_provider_details["provider"].to_s,
          token: auth_provider_details["token"].to_s,
          user_id: user.id
        )

        user.update!(activated_at: Time.local)
        session.delete("auth_provider_details")

        session[:user_id] = user.id
        session[:player_id] = user.player!.id

        flash[:info] = I18n.translate("session.logged_in_successfully")

        redirect_to("/profile")
      else
        WelcomeMailer.new(player).send

        redirect_to "/verification?email=#{user.email}"
      end
    end
  rescue ex : Jennifer::RecordInvalid
    user = build_user_from_params.tap(&.valid?)
    player = build_player_from_params.tap(&.valid?)
    auth_provider_details = fetch_provider_details

    flash["danger"] = "Could not complete registration!"
    render("new.slang")
  end

  private def build_user_from_params
    user = User.build(
      name: params[:name]? || "",
      email: params[:email]? || "",
      verification_code: Random::Secure.hex(8),
      receive_email_notifications: true
    )

    if params["password"]?
      user.password = params["password"].to_s
    end

    user
  end

  private def build_player_from_params
    Player.build(tag: params["tag"])
  end

  private def create_user_from_params
    build_user_from_params.tap(&.save!)
  end

  private def create_player_from_params(user : User)
    build_player_from_params.tap do |player|
      player.add_user(user.not_nil!)
      player.save!
    end
  end

  private def registration_params
    params.validation do
      required(:tag) { |f| !f.nil? }
      required(:name) { |f| !f.nil? }
      required(:email) { |f| !f.nil? }
      required(:password) { |f| !f.nil? }
    end
  end

  private def fetch_provider_details
    if auth_provider_details = session[:auth_provider_details]
      JSON.parse(auth_provider_details)
    end
  end
end
