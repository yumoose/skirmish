class Tournament::Open
  getter :league, :description

  class OpenError < Exception; end

  def initialize(@league : League, @description : String? = nil)
  end

  def call
    if tournament_in_progress?
      raise OpenError.new("A tournament for this league is already in progress")
    end

    Jennifer::Adapter.default_adapter.transaction do
      Tournament.create!(
        league_id: league.id,
        description: description
      ).tap do |tournament|
        notify_players(tournament)
      end
    end
  end

  private def tournament_in_progress?
    Tournament.unfinished.for_league(league).exists?
  end

  private def notify_players(tournament)
    league.active_players.each do |player|
      OpenTournamentMailer.new(player, tournament, description).send
    end
  end
end
