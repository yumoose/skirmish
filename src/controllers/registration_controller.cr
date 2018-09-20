class RegistrationController < ApplicationController
  def new
    user = User.new
    render("new.slang")
  end

  def create
    user = User.new(registration_params.validate!)
    user.receive_email_notifications = true
    user.password = params["password"].to_s

    if user.valid? && user.save
      session[:user_id] = user.id

      player = Player.create!(
        tag: params["username"],
        user_id: user.id
      )

      WelcomeMailer.new(player).send

      flash["success"] = "Created User successfully."
      redirect_to "/"
    else
      flash["danger"] = "Could not create User!"
      render("new.slang")
    end
  end

  private def registration_params
    params.validation do
      required(:username) { |f| !f.nil? }
      required(:email) { |f| !f.nil? }
      required(:password) { |f| !f.nil? }
    end
  end
end
