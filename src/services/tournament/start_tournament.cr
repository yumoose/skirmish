class Tournament::StartTournament
  getter :tournament

  class TournamentStartError < Exception; end

  def initialize(tournament : Tournament)
    @tournament = tournament
  end

  def call
    if tournament_already_started?
      raise TournamentStartError.new("The tournament is already in progress")
    end

    if no_players_entered?
      raise TournamentStartError.new("Nobody has joined the tournament")
    end

    Jennifer::Adapter.adapter.transaction do
      players_query = tournament.players_query
      player_ids = players_query.pluck(:id)

      player_count = players_query.count

      filled_tournament_count = (2 ** Math.sqrt(player_count).ceil).to_i32

      # sprinkle the byes into the player ids
      num_byes = filled_tournament_count - player_count
      num_byes.times do |bye_i|
        player_ids.insert(bye_i * 2 + 1, nil)
      end

      # each player will lose two matches expect for the winner
      # the winner will either lose only one game, or no games at all
      # this means we can create 2 losing games for everyone, with the exception
      # of the winner, who may only lose, at most, one game.
      # matches_to_create = 2 * filled_tournament_count - 1

      initial_matches = [] of Match
      (filled_tournament_count / 2).times do |match_i|
        initial_matches << Match.create!(
          level: 0,
          tournament_id: tournament.id,
          # []? - in the case of byes, there may not be players to fill the match
          player_a_id: player_ids[match_i * 2]?,
          player_b_id: player_ids[match_i * 2 + 1]?
        )
      end

      # TODO break out prepping players, creating matches and processing byes into sub-services?
      create_subsequent_matches(initial_matches)
      process_byes(initial_matches)

      Match.all.each do |match|
        debug_output(match)
      end

      raise "ok stawp"
    end
  end

  private def debug_output(match)
    puts "Match ##{match.id} (lv #{match.level})"
    puts "Player #{match.player_a_id} vs,"
    puts "Player #{match.player_b_id}"
    puts "Winner #{match.winner_id}"
    puts "Next match #{match.next_match_id}"
    puts
  end

  private def tournament_already_started?
    tournament.in_progress?
  end

  private def no_players_entered?
    tournament.players.none?
  end

  private def create_subsequent_matches(matches, level = 0)
    return unless matches.any?

    new_matches = [] of Match

    (matches.size / 2).times do |i|
      new_match = Match.create!(
        level: level + 1,
        tournament_id: tournament.id,
        player_a_id: nil,
        player_b_id: nil
      )

      matches[i * 2].update!(next_match_id: new_match.id)
      matches[i * 2 + 1].update!(next_match_id: new_match.id)

      new_matches << new_match
    end

    create_subsequent_matches(new_matches, level + 1)
  end

  private def process_byes(initial_matches : Array(Match))
    matches_with_byes = initial_matches.select { |match| !match.player_a_id || !match.player_b_id }

    matches_with_byes.each { |match| process_byes(match) }
  end

  private def process_byes(match : Match)
    return if match.player_a_id && match.player_b_id

    default_winner_id = match.player_a_id || match.player_b_id
    match.update!(winner_id: default_winner_id)

    if next_match = Match.find(match.next_match_id)
      if !next_match.player_a_id
        next_match.update!(player_a_id: default_winner_id)
      elsif !next_match.player_b_id
        next_match.update!(player_b_id: default_winner_id)
      else
        raise "trying to process bye up to next match, but no spaces available"
      end
    end
  end
end
