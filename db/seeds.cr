require "../config/application.cr"
# Automatically load schema and run migrations on the test database

if Amber.env.development?
  Jennifer::Adapter.default_adapter.transaction do
    default_password_digest = Crypto::Bcrypt::Password.create("password", cost: 10).to_s

    alice_user = User.create(
      name: "Alice",
      email: "alice@skirmish.online",
      receive_email_notifications: false,
      verification_code: Random::Secure.hex(8),
      activated_at: Time.local,
      password_digest: default_password_digest
    )
    alice = Player.create!(
      tag: "Alice",
      user_id: alice_user.id
    )

    bob_user = User.create(
      name: "Bob",
      email: "bob@skirmish.online",
      receive_email_notifications: false,
      verification_code: Random::Secure.hex(8),
      activated_at: Time.local,
      password_digest: default_password_digest
    )
    bob = Player.create!(
      tag: "Bob",
      user_id: bob_user.id
    )

    charlie_user = User.create(
      name: "Charlie",
      email: "charlie@skirmish.online",
      receive_email_notifications: false,
      verification_code: Random::Secure.hex(8),
      activated_at: Time.local,
      password_digest: default_password_digest
    )
    charlie = Player.create!(
      tag: "Charlie",
      user_id: charlie_user.id
    )

    danielle_user = User.create(
      name: "Danielle",
      email: "danielle@skirmish.online",
      receive_email_notifications: false,
      verification_code: Random::Secure.hex(8),
      activated_at: Time.local,
      password_digest: default_password_digest
    )
    danielle = Player.create!(
      tag: "Danielle",
      user_id: danielle_user.id
    )

    erik_user = User.create(
      name: "Erik",
      email: "erik@skirmish.online",
      receive_email_notifications: false,
      verification_code: Random::Secure.hex(8),
      activated_at: Time.local,
      password_digest: default_password_digest
    )
    erik = Player.create!(
      tag: "Erik",
      user_id: erik_user.id
    )

    hotdog_league = League.create!(
      name: "Hotdog Eating League (HEL)",
      description: "Down a hotdog as fast as possible!",
      visibility: League::OPEN,
      start_rating: League::DEFAULT_START_RATING,
      k_factor: League::DEFAULT_K_FACTOR,
    )

    Administrator.create!(
      player_id: alice.id,
      league_id: hotdog_league.id
    )

    [alice, bob, charlie].each do |player|
      Membership.create!(
        player_id: player.id,
        league_id: hotdog_league.id,
        joined_at: Time.local
      )
    end

    # danielle gets invited
    invite = Invitation::Create.new(league: hotdog_league, player: danielle, approver: alice).call.not_nil!
    Invitation::Accept.new(invitation: invite, player: danielle).call

    # erik goes through the requesting process
    request = Invitation::Create.new(league: hotdog_league, player: erik).call.not_nil!
    Invitation::Approve.new(invitation: request, approver: alice).call

    tournament = Tournament::Open.new(league: hotdog_league, description: "A new hotdog league!").call.not_nil!
    [alice, bob, charlie, danielle, erik].each do |player|
      Tournament::Enter.new(player: player, tournament: tournament).call
    end
    Tournament::Start.new(tournament: tournament).call

    game_logger = League::LogGame.new(
      league: hotdog_league,
      winner: alice,
      loser: bob,
      logger: alice
    )
    game_logger.call
    logged_hotdog_game = game_logger.game

    Game::Confirm.new(
      game: logged_hotdog_game,
      confirming_player: bob
    ).call

    game_logger = League::LogGame.new(
      league: hotdog_league,
      winner: charlie,
      loser: danielle,
      logger: charlie
    )
    game_logger.call
    logged_hotdog_game = game_logger.game

    Game::Confirm.new(
      game: logged_hotdog_game,
      confirming_player: danielle
    ).call
  end
end
