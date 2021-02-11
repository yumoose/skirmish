class LeagueController < ApplicationController
  include PlayerContextHelper

  before_action do
    only [:show, :new, :create, :edit, :update, :destroy] { redirect_signed_out_user }
    only [:show, :edit] { redirect_from_secret_league }
  end

  def index
    current_player_id = current_player.try(&.id)

    leagues = League.all
      .left_join(Membership) { League._id == _league_id }
      .left_join(Invitation) { League._id == _league_id }
      .select("leagues.*, COUNT(memberships.league_id) as membership_count")
      .where { (Membership._left_at == nil) }
      .where { (_visibility != League::SECRET) | (Invitation._player_id == current_player_id) | (Membership._player_id == current_player_id) }
      .group("leagues.id")
      .order { { "membership_count" => :desc } }

    render("index.slang")
  end

  def players
    if league = League.find(params[:league_id])
      if current_player.not_nil!.admin_of?(league)
        active_memberships = league.memberships_query.where { Membership._joined_at != nil  && Membership._left_at == nil  }.includes(:player).to_a
        render("league_management/players.slang")
      else
        flash[:danger] = "Must be an admin of #{league.name} to manage it"
        redirect_to "/leagues/#{league.id}"
      end
    else
      flash[:danger] = "Unable to find league"
      redirect_to "/leagues"
    end
  end

  def inactive_players
    if league = League.find(params[:league_id])
      if current_player.not_nil!.admin_of?(league)
        inactive_memberships = league.memberships_query.where { Membership._left_at != nil }.includes(:player).to_a
        render("league_management/inactive_players.slang")
      else
        flash[:danger] = "Must be an admin of #{league.name} to manage it"
        redirect_to "/leagues/#{league.id}"
      end
    else
      flash[:danger] = "Unable to find league"
      redirect_to "/leagues"
    end
  end

  def requests
    if league = League.find(params[:league_id])
      if current_player.not_nil!.admin_of?(league)
        requests = league.invites_query.where { (_accepted_at != nil) & (_approved_at == nil) }.to_a
        render("league_management/requests.slang")
      else
        flash[:danger] = "Must be an admin of #{league.name} to manage it"
        redirect_to "/leagues/#{league.id}"
      end
    else
      flash[:danger] = "Unable to find league"
      redirect_to "/leagues"
    end
  end

  def invites
    if league = League.find(params[:league_id])
      if current_player.not_nil!.admin_of?(league)
        active_and_invited_player_ids = league.active_players_query.pluck(:id) + league.invites_query.pluck(:player_id)
        available_players = Player.where { sql("players.id not in (#{active_and_invited_player_ids.join(", ")}) ") }
        invites_sent = league.invites_query.where { (_accepted_at == nil) & (_approved_at != nil) }.to_a
        render("league_management/invites.slang")
      else
        flash[:danger] = "Must be an admin of #{league.name} to manage it"
        redirect_to "/leagues/#{league.id}"
      end
    else
      flash[:danger] = "Unable to find league"
      redirect_to "/leagues"
    end
  end

  def stats
    if league = League.find(params[:league_id])
      if player = Player.where { _tag == params[:player_tag] }.try(&.first)
        if league.secret? && !Membership.where { _league_id == league.id && _player_id == current_player.try(&.id) }.exists?
          # a logged in player should only be able to see graphs for leagues they can also see
          flash[:danger] = "Unable to find league"
          redirect_to "/leagues"
        else
          stats = League::RetrievePlayerStats.new(league: league, player: player).call

          respond_with do
            json stats.to_h.to_json
          end
        end
      else
        flash[:danger] = "Unable to find player"
        redirect_to "/"
      end
    else
      flash[:danger] = "Unable to find league"
      redirect_to "/leagues"
    end
  end

  def show
    if league = League.find(params[:id])
      player = current_player.not_nil!

      membership = player.memberships_query.where { _league_id == league.id }.to_a.last? || Membership.build
      tournament = Tournament.for_league(league).order(created_at: :desc).first

      if tournament
        current_entrant = tournament.entrants_query.where { _player_id == player.id }.first
        upcoming_match = Tournament::DetermineUpcomingMatch.new(player, tournament).call
        upcoming_opponent = if upcoming_match
          upcoming_match.opponent(player)
        end
      end

      unaccepted_invite = league.invites_query.where { (_player_id == player.id) & (_accepted_at == nil) & (_approved_at != nil) }.first

      render("show.slang")
    else
      flash["warning"] = "Can't find league"
      redirect_to "/leagues"
    end
  end

  def new
    league = League.build({
      name: ""
    })

    render("new.slang")
  end

  def create
    league = League.new({
      name: params[:name],
      description: params[:description],
      accent_color: params[:accent_color],
      custom_icon_url: params[:custom_icon_url].present? ? params[:custom_icon_url] : nil,
      visibility: params[:visibility],
      start_rating: params[:start_rating].to_i,
      k_factor: params[:k_factor].to_f,
    })

    if league.valid? && league.save
      Administrator.create!(
        player_id: current_player.not_nil!.id,
        league_id: league.id
      )
      Membership.create!(
        player_id: current_player.not_nil!.id,
        league_id: league.id
      )

      flash["success"] = "Created League successfully"
      redirect_to "/leagues/#{league.id}"
    else
      flash["danger"] = "Could not create League!"
      render("new.slang")
    end
  end

  def edit
    player = current_player

    if league = League.find params["id"]
      if player && player.admin_of?(league)
        render("edit.slang")
      else
        flash["warning"] = "Must be an admin of #{league.name} to edit it"
        redirect_to "/leagues/#{league.id}"
      end
    else
      flash["warning"] = "Can't find league"
      redirect_to "/leagues"
    end
  end

  def update
    player = current_player

    if league = League.find(params["id"])
      if player && player.admin_of?(league)
        league.update(
          name: params[:name],
          description: params[:description],
          accent_color: params[:accent_color],
          custom_icon_url: params[:custom_icon_url].present? ? params[:custom_icon_url] : nil,
          visibility: params[:visibility],
          start_rating: params[:start_rating].to_i,
          k_factor: params[:k_factor].to_f,
        )

        if league.valid? && league.save
          flash["success"] = "Updated League successfully"
          redirect_to "/leagues/#{league.id}"
        else
          flash["danger"] = "Could not update League!"
          render("edit.slang")
        end
      else
        flash["warning"] = "Must be an admin of #{league.name} to edit it"
        redirect_to "/leagues/#{league.id}"
      end
    else
      flash["warning"] = "Can't find league"
      redirect_to "/leagues"
    end
  end

  def destroy
    Jennifer::Adapter.default_adapter.transaction do
      if league = League.find params["id"]
        league.administrators_query.destroy
        league.memberships_query.destroy
        league.invites_query.destroy

        league.tournaments_query.each do |tournament|
          tournament.matches_query.destroy
        end
        league.tournaments_query.destroy

        league.games_query.each do |game|
          game.participations_query.destroy
        end
        league.games_query.destroy

        league.destroy
      else
        flash["warning"] = "Can't find league"
      end
    end

    redirect_to "/leagues"
  end

  private def redirect_from_secret_league
    player = current_player
    league = League.find(params[:id])

    if player && league && league.secret? && !player.member_of?(league) && !league.invites_query.where { _player_id == player.try(&.id) }.exists?
      flash["warning"] = "Can't find league"
      redirect_to "/leagues"
    end
  end
end
