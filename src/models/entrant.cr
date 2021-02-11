class Entrant < Jennifer::Model::Base
  with_timestamps

  mapping(
    id: Primary64,
    tournament_id: Int64,
    player_id: Int64,

    created_at: { type: Time, default: Time.local },
    updated_at: { type: Time, default: Time.local }
  )

  validates_presence :tournament_id
  validates_presence :player_id

  belongs_to :tournament, Tournament
  belongs_to :player, Player
end
