require "./notification"

class LeagueRequestNotification < Notification
  mapping(
    source_type: String,
    source_id: Int64
  )

  def title
    "Invite request for #{league.name}"
  end

  def content
    "#{requester.tag} has requested to join #{league.name}"
  end

  def action_url
    "/leagues/#{league.id}/management"
  end

  def invitation
    Invitation.find(source_id).not_nil!
  end

  def league
    invitation.league!
  end

  def requester
    invitation.player!
  end
end
