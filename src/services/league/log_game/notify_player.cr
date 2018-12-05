class League::LogGame::NotifyPlayer
  getter player, won, game, logger

  def initialize(@player : Player, @won : Bool, @game : Game, @logger : Player)
  end

  def call!
    Jennifer::Adapter.adapter.transaction do
      Notification.create!({
        player_id: player.id.not_nil!,
        type: Notification::GAME_LOGGED,
        title: title,
        content: content,
        source_type: game.class.to_s,
        source_id: game.id,
        sent_at: Time.now
      })

      GameLoggedMailer.new(player, game).send if player.user!.receive_email_notifications?
    end
  end

  private def title
    I18n.translate("game.notifications.game_logged.title")
  end

  private def content
    I18n.translate("game.notifications.game_logged.content")
  end
end
