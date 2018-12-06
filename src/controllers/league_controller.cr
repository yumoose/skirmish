class LeagueController < ApplicationController
  include PlayerContextHelper

  before_action do
    only [:show, :new, :create, :edit, :update, :destroy] { redirect_signed_out_user }
    only [:show, :edit] { redirect_from_secret_league }
  end

  def index
    leagues = League.publicly_visible.left_join(Membership) { League._id == _league_id }
      .select("leagues.*, COUNT(memberships.league_id) as membership_count")
      .where { Membership._left_at == nil }
      .group("leagues.id")
      .order { { "membership_count" => :desc } }

    render("index.slang")
  end

  def show
    if league = League.find(params[:id])
      player = current_player.not_nil!

      membership = player.memberships_query.where { _league_id == league.id }.to_a.first? || Membership.build
      tournament = Tournament.for_league(league).order(created_at: :desc).first

      render("show.slang")
    else
      flash["warning"] = "Can't find league"
      redirect_to "/leagues"
    end
  end

  def management
    if league = League.find(params[:league_id])
      if current_player.not_nil!.admin_of?(league)
        _admin_players_query = Player.all.where {
          _id == any(league.administrators_query.select(:player_id))
        }

        admin_players = _admin_players_query.order(tag: :asc).to_a
        available_players_for_admin = league.players_query.where { sql("players.id not in (#{_admin_players_query.pluck(:id).join(", ")}) ") }.to_a

        render("management.slang")
      else
        flash[:danger] = "Must be an admin of #{league.name} to manage it"
        redirect_to "/leagues/#{league.id}"
      end
    else
      flash[:danger] = "Unable to find league"
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
        league.update_attributes({
          name: params[:name],
          description: params[:description],
          accent_color: params[:accent_color],
          visibility: params[:visibility],
          start_rating: params[:start_rating].to_i,
          k_factor: params[:k_factor].to_f,
        })

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
    Jennifer::Adapter.adapter.transaction do
      if league = League.find params["id"]
        league.administrators_query.destroy
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

    if player && league && league.secret? && !player.in_league?(league)
      flash["warning"] = "Can't find league"
      redirect_to "/leagues"
    end
  end
end
