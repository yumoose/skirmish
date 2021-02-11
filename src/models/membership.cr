class Membership < Jennifer::Model::Base
  with_timestamps

  mapping(
    id: Primary64,
    player_id: Int64?,
    league_id: Int64?,

    joined_at: { type: Time, default: Time.local },
    left_at: Time?,

    created_at: { type: Time, default: Time.local },
    updated_at: { type: Time, default: Time.local }
  )

  belongs_to :player, Player
  belongs_to :league, League

  validates_presence :player_id
  validates_presence :league_id

  scope :active { where { (_left_at == nil) & (_joined_at != nil) } }

  def active?
    !joined_at.nil? && left_at.nil?
  end
end
