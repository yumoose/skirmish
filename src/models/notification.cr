class Notification < Jennifer::Model::Base
  DEFAULT_NOTIFICATION_COLOR = "#fd971f"
  DEFAULT_NOTIFICATION_ICON_URL = "https://png.icons8.com/ios-glyphs/200/ffffff/star.png"

  with_timestamps

  mapping(
    id: Primary64,
    player_id: Int64?,

    title: String,
    content: String,
    type: String?,

    sent_at: { type: Time, default: Time.local },
    read_at: Time?,

    created_at: { type: Time, default: Time.local },
    updated_at: { type: Time, default: Time.local }
  )

  scope :read { where { _read_at != nil } }
  scope :unread { where { _read_at == nil } }
  scope :for_player { |player| where { _player_id == player.id } }

  belongs_to :player, Player

  validates_presence :player_id
  validates_presence :title
  validates_presence :content
  validates_presence :sent_at

  validates_with PlayerRelationValidator

  def action_url
    "/notifications"
  end

  def read?
    !!read_at
  end

  def read!
    return if read?

    self.read_at = Time.local
    save!
  end

  def color
    DEFAULT_NOTIFICATION_COLOR
  end

  def icon_url
    DEFAULT_NOTIFICATION_ICON_URL
  end

  def custom_icon?
    false
  end
end
