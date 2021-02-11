class League::RetrievePlayerStats
  getter :league, :player, :membership, :time_formatter

  @membership : Membership | Nil
  @time_formatter = Time::Format.new("%F %T")

  def initialize(@league : League, @player : Player)
    @membership = player.membership_for(league)
  end

  def call
    {
      league_name: league.name,
      league_color: league.accent_color,
      ratings: ratings
    }
  end

  @ratings : Hash(String, Int32) | Nil
  private def ratings
    @ratings ||= begin
      # add an initial rating for league join
      ratings = {} of String => Int32

      if membership = @membership
        ratings[time_formatter.format(membership.joined_at)] = league.start_rating

        # add ratings for each game played
        participations.each do |participation|
          game_confirmed_at = participation.game!.confirmed_at.not_nil!
          ratings[time_formatter.format(game_confirmed_at)] = participation.rating.not_nil!
        end

        # add a rating as at today
        ratings[time_formatter.format(Time.local)] = participations.last?.try(&.rating) || league.start_rating
      end

      ratings
    end
  end

  @participations : Array(Participation) | Nil
  private def participations
    @participations ||= begin
      game_ids_for_player = player.games_query.confirmed.where { _league_id == league.id }.pluck(:id)

      if game_ids_for_player.any?
        Participation.where { _player_id == player.id }.
          where { sql("participations.game_id in (#{game_ids_for_player.join(", ")})") }.
          where { _rating != nil }.
          join(Game) { Participation._game_id == _id }.
          order(Game._confirmed_at.asc).to_a
      else
        [] of Participation
      end
    end
  end

  @latest_rating : Int32 | Nil
  private def latest_rating
    @latest_rating ||= if participations.empty?
      league.start_rating
    else
      participations.max_by { |p| p.created_at }.rating.not_nil!
    end
  end
end
