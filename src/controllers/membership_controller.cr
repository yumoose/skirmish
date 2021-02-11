class MembershipController < ApplicationController
  before_action do
    all { redirect_signed_out_user }
  end

  def index
  end

  def create
    player = current_player.not_nil!
    league = League.find(params[:league_id])

    if !league
      flash["danger"] = "Can't find league"
      redirect_to "/leagues"; return
    end

    if league && player.member_of?(league)
      flash["danger"] = "Already a member of #{league.name}"
      redirect_to "/leagues/#{params[:league_id]}"; return
    end

    membership = Membership.build(
      league_id: league.id,
      player_id: player.id,
      joined_at: Time.local
    )

    if membership.valid? && membership.save
      flash["success"] = "Joined #{league.name}"
      redirect_to "/leagues/#{membership.league_id}"
    else
      flash["danger"] = "Could not join #{league.name}! #{membership.errors.full_messages}"
      redirect_to "/leagues/#{membership.league_id}"
    end
  end

  def update
    player = current_player.not_nil!
    league = League.find(params[:league_id])

    if league
      if membership = player.memberships_query.where { _league_id == league.id }.to_a.first
        if membership.update(left_at: leaving? ? Time.local : nil)
          if leaving?
            flash["success"] = "Left #{league.name}"
          else
            flash["success"] = "Re-joined #{league.name}"
          end
        else
          flash["danger"] = "Couldn't update your membership for #{league.name}! #{membership.errors.full_messages}"
        end

        redirect_to "/leagues/#{league.id}"
      else
        flash["danger"] = "Couldn't find your membership #{league.name}"
        redirect_to "leagues/#{league.id}"
      end
    else
      flash["danger"] = "Couldn't find league"
      redirect_to "leagues"
    end
  end

  ##
  # Admin action
    def rejoin
    league = League.find(params[:league_id])
    if league
      if current_player.not_nil!.admin_of?(league)
        if membership = league.memberships_query.where { _league_id == league.id && _id == params[:id] }.to_a.first
          membership.update(left_at: nil)
          player = membership.player!
          flash["success"] = "#{player.tag} added back to #{league.name}"
          redirect_to "/leagues/#{league.id}/players"
        else
          flash["danger"] = "Couldn't find your membership #{league.name}"
          redirect_to "leagues/#{league.id}"
        end
      else
        flash[:danger] = "Must be an admin of #{league.name} to manage it"
        redirect_to "/leagues/#{league.id}"
      end
    else
      flash["danger"] = "Couldn't find league"
      redirect_to "leagues"
    end
  end

  ##
  # Admin action
  def leave
    league = League.find(params[:league_id])
    if league
      if current_player.not_nil!.admin_of?(league)
        if membership = league.memberships_query.where { _league_id == league.id && _id == params[:id] }.to_a.first
          membership.update(left_at: Time.local)
          player = membership.player!
          flash["success"] = "#{player.tag} removed from #{league.name}"
          redirect_to "/leagues/#{league.id}/players"
        else
          flash["danger"] = "Couldn't find your membership #{league.name}"
          redirect_to "leagues/#{league.id}"
        end
      else
        flash[:danger] = "Must be an admin of #{league.name} to manage it"
        redirect_to "/leagues/#{league.id}"
      end
    else
      flash["danger"] = "Couldn't find league"
      redirect_to "leagues"
    end
  end

  private def membership_params
    params.validation do
      required(:league_id) { |f| !f.nil? }
    end
  end

  private def leaving?
    params[:leave_or_join] == "leave"
  end

  private def rejoining?
    params[:leave_or_join] == "join"
  end
end
