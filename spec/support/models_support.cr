def create_player_with_mock_user(tag : String? = nil, password : String? = nil, verified : Bool = true)
  name = Random::Secure.hex
  user = User.create!(
    name: name,
    email: "#{name}@test.com",
    receive_email_notifications: false,
    verification_code: Random::Secure.hex(8),
    activated_at: verified ? Time.local : nil,
    password_digest: password ? Crypto::Bcrypt::Password.create(password, cost: 10).to_s : "$2y$10$2usLfyPcXzxmM4prDXg/J.qXlqbijcpVj5eHcYR0CBp7p38Ts8PEe"  # "password"
  )

  Player.create!(
    user_id: user.id,
    tag: tag || "player_#{Random::Secure.hex(4)}"
  )
end

def create_league(name : String? = nil, description : String? = nil, visibility : String = League::OPEN, start_rating : Int32? = nil, k_factor : Float64? = nil)
  League.create!(
    name: name || Random::Secure.hex,
    description: description || Random::Secure.hex,
    visibility: visibility,
    start_rating: start_rating || League::DEFAULT_START_RATING,
    k_factor: k_factor || League::DEFAULT_K_FACTOR
  )
end

def create_and_pit_players(league : League)
  player_one = create_player_with_mock_user
  player_two = create_player_with_mock_user
  player_three = create_player_with_mock_user

  Membership.create!(player_id: player_one.id, league_id: league.id, joined_at: Time.local)
  Membership.create!(player_id: player_two.id, league_id: league.id, joined_at: Time.local)
  Membership.create!(player_id: player_three.id, league_id: league.id, joined_at: Time.local)

  game_logger = League::LogGame.new(league: league, winner: player_one, loser: player_three, logger: player_one)
  game_logger.call
  game = game_logger.game
  Game::Confirm.new(game: game, confirming_player: player_three).call

  game_logger = League::LogGame.new(league: league, winner: player_two, loser: player_three, logger: player_three)
  game_logger.call
  game = game_logger.game
  Game::Confirm.new(game: game, confirming_player: player_two).call

  [player_one, player_two, player_three]
end

def set_player_rating(league : League, player : Player, rating : Int32)
  if !player.participations_query.exists?
    # if the player hasn't participated, make a new player, log a game and then remove the player
    another_player = create_player_with_mock_user
    membership = Membership.create!(player_id: another_player.id, league_id: league.id, joined_at: Time.local)
    game_logger = League::LogGame.new(league: league, winner: player, loser: another_player, logger: player)
    game_logger.call
    game = game_logger.game
    Game::Confirm.new(game: game, confirming_player: another_player).call
    membership.update!(left_at: Time.local)
  end

  participation = player.participations_query.order(created_at: :desc).first.not_nil!
  participation.rating = rating
  participation.save
end

def create_notification(player : Player, type : String? = "GeneralNotification", source : Jennifer::Model::Base? = nil, title : String? = nil, content : String? = nil, sent_at : Time? = Time.local, read_at : Time? = nil)
  core_attributes = {
    type: type,
    player_id: player.id,
    title: title || "New Notification",
    content: content || "with some descriptive content",
    sent_at: sent_at,
    read_at: read_at
  }

  notification_attributes = core_attributes

  if source
    source_attributes = {
      source_type: source.nil? ? nil : source.class.name,
      source_id: source.try(&.id),
    }

    notification_attributes.merge(source_attributes)
  end

  Notification.create!(notification_attributes)
end
