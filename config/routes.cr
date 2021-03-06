Amber::Server.configure do
  pipeline :web do
    # Plug is the method to use connect a pipe (middleware)
    # A plug accepts an instance of HTTP::Handler
    plug Amber::Pipe::PoweredByAmber.new
    # plug Amber::Pipe::ClientIp.new(["X-Forwarded-For"])
    plug Citrine::I18n::Handler.new
    plug Amber::Pipe::Error.new
    plug Amber::Pipe::Logger.new
    plug Amber::Pipe::Session.new
    plug Amber::Pipe::Flash.new
    plug Amber::Pipe::CSRF.new
    plug Authenticate.new
  end

  pipeline :api do
    plug Amber::Pipe::PoweredByAmber.new
    plug Amber::Pipe::Error.new
    plug Amber::Pipe::Logger.new
    plug Amber::Pipe::Session.new
    plug Amber::Pipe::CORS.new
  end

  # All static content will run these transformations
  pipeline :static do
    plug Amber::Pipe::PoweredByAmber.new
    plug Amber::Pipe::Error.new
    plug Amber::Pipe::Static.new("./public")
  end

  routes :web do
    resources "/notifications", NotificationController, only: [:index, :show]
    patch "/notifications/read_all", NotificationController, :read_all
    patch "/notifications/:id/read", NotificationController, :read

    post "/leagues/:league_id/join", MembershipController, :create
    patch "/leagues/:league_id/:leave_or_join", MembershipController, :update
    patch "/leagues/:league_id/membership/:id/leave", MembershipController, :leave
    patch "/leagues/:league_id/membership/:id/rejoin", MembershipController, :rejoin
    resources "/leagues/:league_id/games", GameController, except: [:index, :edit, :update]
    patch "/leagues/:league_id/games/:game_id/:action", GameController, :update
    get "/leagues/:league_id/games/:game_id/confirm/:confirmation_code", GameController, :quick_confirm
    resources "/leagues", LeagueController

    resources "/leagues/:league_id/tournaments/", TournamentController, only: [:index, :new, :show, :create, :destroy]
    patch "/leagues/:league_id/tournaments/:id/start", TournamentController, :start
    post "/leagues/:league_id/tournaments/:tournament_id/join", EntrantController, :create
    delete "/leagues/:league_id/tournaments/:tournament_id/leave", EntrantController, :destroy

    get "/leagues/:league_id/players", LeagueController, :players
    get "/leagues/:league_id/inactive_players", LeagueController, :inactive_players
    get "/leagues/:league_id/requests", LeagueController, :requests
    get "/leagues/:league_id/invites", LeagueController, :invites
    get "/leagues/:league_id/stats/:player_tag", LeagueController, :stats
    resources "/leagues/:league_id/admins", LeagueAdministratorController, only: [:index, :create, :destroy]

    resources "/leagues/:league_id/invites/", InvitationController, only: [:create, :update, :destroy]
    resources "/leagues/:league_id/requests/", RequestController, only: [:create, :update, :destroy]

    get "/profile", UserController, :show
    get "/profile/edit", UserController, :edit
    get "/profile/:player_tag", UserController, :show
    patch "/profile", UserController, :update

    get "/signin", SessionController, :new
    post "/session", SessionController, :create
    get "/signout", SessionController, :delete

    get "/signup", RegistrationController, :new
    post "/registration", RegistrationController, :create

    resources "/reset_password", PasswordResetController, only: [:new, :create, :edit, :update]

    get "/multi_auth/google", MultiAuthController, :google
    get "/multi_auth/callback", MultiAuthController, :callback
    delete "/multi_auth/unlink/:id", MultiAuthController, :unlink

    get "/verification", VerificationController, :show
    get "/verify/:verification_code", VerificationController, :verify

    get "/mailer_preview/:mailer_name", MailerPreviewController, :show

    get "/", HomeController, :index
  end

  routes :api do
  end

  routes :static do
    # Each route is defined as follow
    # verb resource : String, controller : Symbol, action : Symbol
    get "/*", Amber::Controller::Static, :index
  end
end
