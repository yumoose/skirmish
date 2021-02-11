class Game::Confirm
  getter :game, :confirming_player, league : League, winner : Player, loser : Player, winner_participation : Participation, loser_participation : Participation
  property :errors, :redis

  def initialize(@game : Game, @confirming_player : Player)
    @league = game.league!
    @winner = game.winner
    @loser = game.loser

    @winner_participation = game.participations_query.where { _won == true }.to_a.first
    @loser_participation = game.participations_query.where { _won == false }.to_a.first

    @errors = [] of String
    @redis = nil
  end

  def call
    if game.confirmed?
      @errors << "Game already confirmed"
      return false
    end

    if winner && loser
      if can_be_confirmed_by_player?
        update_game
        update_ratings
        update_tournament_matches

        if game_and_participations_valid?
          save_game_and_participations
          update_league_leaderboard

          true
        else
          @errors += game_and_participation_errors.map(&.to_s).compact
          false
        end
      else
        @errors << "Game must be confirmed by an opposing player"
        false
      end
    else
      @errors << "Game must have a winner and a loser"
      return false
    end
  end

  private def can_be_confirmed_by_player?
    Game::CanBeConfirmedByPlayer.new(game: game, player: confirming_player).call
  end

  private def update_game
    game.rating_delta = rating_delta
    game.confirmed_by_id = confirming_player.id
    game.confirmed_at = Time.local
  end

  private def update_ratings
    winner_rating, loser_rating = new_ratings

    winner_participation.rating = winner_rating
    loser_participation.rating = loser_rating
  end

  private def update_tournament_matches
    # TODO find a better way to match this independent of being player_a or player_b
    league.tournaments_query.unfinished.each do |tournament|
      tournament.matches_query.where { (_winner_id == nil) & g(g((_player_a_id == winner.id) & (_player_b_id == loser.id)) | g((_player_a_id == loser.id) & (_player_b_id == winner.id))) }.each do |match|
        Match::UpdateAndProgress.new(match: match, winner: winner, loser: loser).call
      end
    end
  end

  private def old_ratings
    [winner.rating_for(league), loser.rating_for(league)]
  end

  @rating_delta : Int32?
  private def rating_delta
    @rating_delta ||= begin
      old_winner_rating, old_loser_rating = old_ratings

      Rating::DetermineDelta.new(
        winner_rating: old_winner_rating,
        loser_rating: old_loser_rating,
        league: league
      ).call
    end
  end

  private def new_ratings
    old_winner_rating, old_loser_rating = old_ratings

    new_winner_rating = old_winner_rating + rating_delta
    new_loser_rating = old_loser_rating - rating_delta

    [new_winner_rating.abs, new_loser_rating.abs]
  end

  private def game_and_participations_valid?
    game.valid? && winner_participation.valid? && loser_participation.valid?
  end

  private def save_game_and_participations
    game.save && winner_participation.save && loser_participation.save
  end

  private def game_and_participation_errors
    game.errors.full_messages + winner_participation.errors.full_messages + loser_participation.errors.full_messages
  end

  private def update_league_leaderboard
    current_leaderboard = redis.lrange(leaderboard_redis_key, 0, -1).map(&.as(String))
    new_leaderboard = current_leaderboard

    winner_pos = current_leaderboard.index(winner.id.to_s)
    loser_pos = current_leaderboard.index(loser.id.to_s)

    if !winner_pos && loser_pos
      new_leaderboard.push(winner.id.to_s)
      winner_pos = new_leaderboard.size - 1
    end

    if winner_pos && loser_pos && winner_pos > loser_pos
      new_leaderboard.delete_at(winner_pos)
      new_leaderboard.insert(loser_pos, winner.id.to_s)

      redis.del(leaderboard_redis_key)

      new_leaderboard.each do |player_id|
        redis.rpush(leaderboard_redis_key, player_id)
      end
    elsif !winner_pos && !loser_pos
      redis.rpush(leaderboard_redis_key, winner.id.to_s)
    end
  end

  private def redis
    @redis ||= Leaderboard::KingOfTheHill.redis
  end

  private def leaderboard_redis_key
    Leaderboard::KingOfTheHill.redis_lookup_key(league)
  end
end
