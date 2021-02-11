class Tournament::Start
  getter :tournament, :double_elimination

  class StartError < Exception; end

  def initialize(tournament : Tournament, double_elimination = false)
    @tournament = tournament
    # TODO: Determine double elim or other type of tournament from the tournament itself
    @double_elimination = double_elimination
  end

  def call
    if tournament_already_started?
      raise StartError.new("The tournament has already been started")
    end

    if not_enough_players?
      raise StartError.new("Not enough players entered to start the tournament")
    end

    Jennifer::Adapter.default_adapter.transaction do
      players = PreparePlayers.new(tournament: tournament).call
      initial_matches = CreateMatches.new(tournament: tournament, players: players).call
      ProcessByes.new(matches: initial_matches).call
    end
  end

  private def tournament_already_started?
    !tournament.open?
  end

  private def not_enough_players?
    tournament.players_query.count < 2
  end
end
