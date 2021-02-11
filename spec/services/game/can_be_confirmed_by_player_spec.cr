require "../spec_helper"

def can_be_confirmed?(game : Game, player : Player)
  Game::CanBeConfirmedByPlayer.new(
    game: game,
    player: player
  ).call
end

describe Game::CanBeConfirmedByPlayer do
  league = create_league
  winner = create_player_with_mock_user
  loser = create_player_with_mock_user

  [winner, loser].each do |player|
    Membership.create!(player_id: player.id, league_id: league.id, joined_at: Time.local)
  end

  describe "#call" do
    context "a game logged by the winner" do
      it "is able to be confirmed by the loser" do
        game_logger = League::LogGame.new(league: league, winner: winner, loser: loser, logger: winner)
        game_logger.call
        game = game_logger.game

        can_be_confirmed?(game, loser).should be_true
      end

      it "is unable to be confirmed by the winner" do
        game_logger = League::LogGame.new(league: league, winner: winner, loser: loser, logger: winner)
        game_logger.call
        game = game_logger.game

        can_be_confirmed?(game, winner).should be_false
      end

      it "is able to be confirmed by a league admin" do
        game_logger = League::LogGame.new(league: league, winner: winner, loser: loser, logger: winner)
        game_logger.call
        game = game_logger.game

        admin_player = create_player_with_mock_user
        Administrator.create!(player_id: admin_player.id, league_id: league.id)

        can_be_confirmed?(game, admin_player).should be_true
      end
    end

    context "a game logged by the loser" do
      it "is able to be confirmed by the winner" do
        game_logger = League::LogGame.new(league: league, winner: winner, loser: loser, logger: loser)
        game_logger.call
        game = game_logger.game

        can_be_confirmed?(game, winner).should be_true
      end

      it "is unable to be confirmed by the loser" do
        game_logger = League::LogGame.new(league: league, winner: winner, loser: loser, logger: loser)
        game_logger.call
        game = game_logger.game

        can_be_confirmed?(game, loser).should be_false
      end

      it "is able to be confirmed by a league admin" do
        game_logger = League::LogGame.new(league: league, winner: winner, loser: loser, logger: loser)
        game_logger.call
        game = game_logger.game

        admin_player = create_player_with_mock_user
        Administrator.create!(player_id: admin_player.id, league_id: league.id)

        can_be_confirmed?(game, admin_player).should be_true
      end
    end
  end
end
