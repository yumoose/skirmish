class Invitation::Accept
  getter :invitation, :player

  class AcceptError < Exception; end

  def initialize(invitation : Invitation, player : Player)
    @invitation = invitation
    @player = player
  end

  def call
    assert_invite_belongs_to_player!
    assert_invite_not_already_accepted!
    assert_player_not_already_in_league!

    Jennifer::Adapter.default_adapter.transaction do
      invitation.update!(accepted_at: Time.local)
      Membership.create!(league_id: invitation.league_id, player_id: invitation.player_id)
      read_invite_request_notification!
    end
  end

  private def assert_invite_belongs_to_player!
    if invitation.player_id != player.id
      raise AcceptError.new("Invite belongs to another player")
    end
  end

  private def assert_invite_not_already_accepted!
    if invitation.accepted?
      raise AcceptError.new("Invite has already been accepted")
    end
  end

  private def assert_player_not_already_in_league!
    league = invitation.league!

    if player.member_of?(league)
      raise AcceptError.new("#{player.tag} is already a member of #{league.name}")
    end
  end

  private def read_invite_request_notification!
    notifications = LeagueInviteNotification.unread.where { (_source_id == invitation.id) & (_player_id == player.id) }
    notifications.each(&.read!)
  end
end
