class InvitationController < ApplicationController
  before_action do
    all { redirect_signed_out_user }
  end

  # sent an invite to join the league to another player
  def create
    if league = League.find(params[:league_id])
      if current_player.not_nil!.admin_of?(league)
        if player = Player.find(params[:player_id])
          Jennifer::Adapter.default_adapter.transaction do
            Invitation::Create.new(
              league: league,
              player: player,
              approver: current_player.not_nil!
            ).call

            flash["success"] = "Invited #{player.tag} to #{league.name}"
            redirect_to "/leagues/#{league.id}/invites"
          rescue ex : Invitation::Create::InviteError
            flash["danger"] = ex.message.to_s
            redirect_to "/leagues/#{league.id}"
          end
        else
          flash["danger"] = "Couldn't find player"
          redirect_to "/leagues/#{league.id}"
        end
      else
        flash["danger"] = "Must be an admin to manage invites"
        redirect_to "/leagues/#{league.id}"
      end
    else
      flash["danger"] = "Couldn't find league"
      redirect_to "/leagues"
    end
  end

  # player accepting an invitation
  def update
    if invite = Invitation.find(params[:id])
      player = current_player.not_nil!

      if invite.player_id == player.id
        Jennifer::Adapter.default_adapter.transaction do
          Invitation::Accept.new(
            invitation: invite,
            player: player
          ).call

          flash["success"] = "Invite accepted"
          redirect_to "/leagues/#{invite.league_id}"
        rescue ex : Invitation::Accept::AcceptError
          flash["danger"] = ex.message.to_s
          redirect_to "/leagues/#{invite.league_id}"
        end
      else
        flash["danger"] = "Invite belongs to someone else"
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

      if player.admin_of?(invite.league!)
        Jennifer::Adapter.default_adapter.transaction do
          invite.destroy

          flash["success"] = "Invite deleted"
          redirect_to "/leagues/#{invite.league_id}/invites"
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
