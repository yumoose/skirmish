class HTTP::Server::Context
  property current_user : User?
  property current_player : Player?
end

class Authenticate < Amber::Pipe::Base
  PUBLIC_PATHS = ["/", "/signin", "/session", "/signup", "/registration"]

  def call(context)
    user_id = context.session["user_id"]?
    player_id = context.session["player_id"]?

    user = User.find user_id
    player = Player.find player_id

    if user && player
      context.current_user = user
      context.current_player = player
      call_next(context)
    else
      return call_next(context) if public_path?(context.request.path) || whitelisted_request?(context.request)

      context.flash[:warning] = "Please Sign In"
      context.response.headers.add "Location", "/signin"
      context.response.status_code = 302
    end
  end

  private def public_path?(path)
    PUBLIC_PATHS.includes?(path) ||
      quick_confirmation_url?(path) ||
      path.starts_with?("/verify/") ||
      path.starts_with?("/verification/")

    # Different strategies can be used to determine if a path is public
    # Example, if /admin/* paths are the only private paths
    # return false if path.starts_with?("/admin")
    #
    # Example, if only a few private paths exist
    # return false if ["/secret", "/super/secret", "/private"].includes?(path)
  end

  private def whitelisted_request?(request)
    # gross
    request.method == "GET" && request.path.match(/^\/leagues(\/[0-9]+)?$/)
  end

  private def quick_confirmation_url?(path)
    path.match(/leagues\/.*\/games\/.*\/confirm\/.*/)
  end
end
