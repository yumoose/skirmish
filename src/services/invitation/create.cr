class Invitation::Create
  getter :league, :player, :approver

  class InviteError < Exception; end

  def initialize(league : League, player : Player, approver : Player | Nil = nil)
    @league = league
    @player = player
    @approver = approver
  end

  def call
    assert_player_not_already_in_league!
    assert_invite_not_already_created!
    assert_approver_is_an_admin!

    Jennifer::Adapter.default_adapter.transaction do
      Invitation.create!(
        league_id: league.id,
        player_id: player.id,
        approver_id: approver.try(&.id),
        approved_at: player_request? ? nil : Time.local,
        accepted_at: player_request? ? Time.local : nil
      ).tap do |invite|
        notify_recipient!(invite)
      end
    end
  end

  private def player_request?
    !approver
  end

  private def assert_player_not_already_in_league!
    if player.member_of?(league)
      raise InviteError.new("#{player.tag} is already a member of #{league.name}")
    end
  end

  private def assert_invite_not_already_created!
    if invite = Invitation.where { (_league_id == league.id) & (_player_id == player.id) }.first
      if invite.approved?
        raise InviteError.new("#{player.tag} has already been invited to join #{league.name}")
      else
        raise InviteError.new("#{player.tag} has already requested to join #{league.name}")
      end
    end
  end

  private def assert_approver_is_an_admin!
    return unless approving_player = approver

    if !approving_player.admin_of?(league)
      raise InviteError.new("#{approving_player.tag} must be an admin of #{league.name} to approve invites")
    end
  end

  private def notify_recipient!(invite)
    if player_request?
      Player.where { _id.in(league.administrators_query.pluck(:player_id)) }.each do |admin_player|
        LeagueRequestNotification.create(
          player_id: admin_player.id,
          title: "Invite request for #{league.name}",
          content: "#{player.display_name} has requested to join #{league.name}",
          sent_at: Time.local,
          source_type: invite.class.to_s,
          source_id: invite.id
        )
      end
    else
      LeagueInviteNotification.create(
        player_id: player.id,
        title: "You've been invited to join #{league.name}",
        content: "#{approver.not_nil!.display_name} has invited you to join #{league.name}",
        sent_at: Time.local,
        source_type: invite.class.to_s,
        source_id: invite.id
      )
    end
  end
end
