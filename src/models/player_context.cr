class PlayerContext < Jennifer::Model::Base
  with_timestamps

  mapping(
    id: Primary64,

    player_id: Int64,
    league_id: Int64?,

    created_at: { type: Time, default: Time.local },
    updated_at: { type: Time, default: Time.local }
  )

  validates_presence :player_id

  belongs_to :player, Player
  belongs_to :league, League
end
