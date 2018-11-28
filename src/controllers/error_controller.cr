class ErrorController < Amber::Controller::Error
  LAYOUT = "application.slang"

  include ProfileHelper

  def current_user
    context.current_user
  end

  def current_player
    context.current_player
  end

  def forbidden
    render("forbidden.slang", layout: nil)
  end

  def not_found
    render("not_found.slang", layout: nil)
  end

  def internal_server_error
    if !Amber.env.development?
      ExceptionMailer.new(exception: @ex, user: current_user).send
    end

    render("internal_server_error.slang", layout: nil)
  end
end
