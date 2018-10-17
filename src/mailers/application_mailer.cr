require "kilt"
require "jasper_helpers"


class ApplicationMailer < Mailer::Message
  include JasperHelpers

  def initialize
    super()
    self.from = "Skirmish <postmaster@mail.skirmish.online>"
  end

  def send
    return if Amber.env.test? || suppress_emails?
    super
  end

  private def suppress_emails?
    ENV["SUPPRESS_EMAILS"]? == "true" || recipient_opted_out_of_email_notifications?
  end

  private def recipient_opted_out_of_email_notifications?
    # Assumes a single recipient, if one is opted out, all will NOT receive the email
    # TODO Remove unwilling recipients and then check if any left before sending
    to.any? do |recipient|
      user = User.where { _email == recipient.email }.to_a.first

      if user
        !user.receive_email_notifications?
      else
        # Not signed up as a user, yet...
        false
      end
    end
  end

  macro render(filename, layout, *args)
    content = render("{{filename.id}}", {{*args}})
    render("layouts/{{layout.id}}")
  end

  macro render(filename, *args)
    Kilt.render("src/views/{{filename.id}}", {{*args}})
  end
end