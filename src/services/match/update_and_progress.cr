class Match::UpdateAndProgress
  getter :match, :winner, :loser

  def initialize(match : Match, winner : Player, loser : Player)
    @match = match
    @winner = winner
    @loser = loser
  end

  def call
    match.update!(winner_id: winner.id)

    if next_match = Match.find(match.next_match_id)
      if next_match.player_a_id
        next_match.update!(player_b_id: winner.id)
      else
        next_match.update!(player_a_id: winner.id)
      end

      if next_match.player_a_id && next_match.player_b_id
        send_new_tournament_match_mailers(next_match)
      end
    end

    # also update the lower bracket for double-elim (should this be stored as next_loser_match_id?)

    tournament = match.tournament.not_nil!
    if tournament.finished?
      tournament.update!(finished_at: Time.local)
    end
  end

  private def send_new_tournament_match_mailers(match : Match)
    # move into service?
    [match.player_a.not_nil!, match.player_b.not_nil!].each do |player|
      TournamentMatchMailer.new(player, match).send if player.user!.receive_email_notifications?
    end
  end
end
