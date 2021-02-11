class RequestController < ApplicationController
  before_action do
    all { redirect_signed_out_user }
  end

  # request an invite to the league
  def create
    if league = League.find(params[:league_id])
      Jennifer::Adapter.default_adapter.transaction do
        Invitation::Create.new(
          league: league,
          player: current_player.not_nil!
        ).call

        flash["success"] = "Invite requested"
        redirect_to "/leagues/#{league.id}"
      rescue ex : Invitation::Create::InviteError
        flash["danger"] = ex.message.to_s
        redirect_to "/leagues/#{league.id}"
      end
    else
      flash["danger"] = "Couldn't find league"
      redirect_to "/leagues"
    end
  end

  # admin approving a request
  def update
    if invite = Invitation.find(params[:id])
      if current_player.not_nil!.admin_of?(invite.league!)
        Jennifer::Adapter.default_adapter.transaction do
          Invitation::Approve.new(invitation: invite, approver: current_player.not_nil!).call

          flash["success"] = "Invite approved"
          redirect_to "/leagues/#{invite.league_id}/requests"
        rescue ex : Invitation::Approve::ApproveError
          flash["danger"] = ex.message.to_s
          redirect_to "/leagues/#{invite.league_id}"
        end
      else
        flash["danger"] = "Must be an admin to manage invites"
        redirect_to "/leagues/#{invite.league_id}"
      end
    else
      flash["danger"] = "Couldn't find league"
      redirect_to "/leagues"
    end
  end

  def destroy
    if invite = Invitation.find(params[:id])
      player = current_player.not_nil!

      if player.id == invite.player_id || player.admin_of?(invite.league!)
        Jennifer::Adapter.default_adapter.transaction do
          invite.destroy

          flash["success"] = "Invite deleted"
          redirect_to "/leagues/#{invite.league_id}/requests"
        end
      else
        flash["danger"] = "Must be an admin to manage invites"
        redirect_to "/leagues/#{invite.league_id}"
      end
    else
      flash["danger"] = "Couldn't find league"
      redirect_to "/leagues"
    end
  end
end
