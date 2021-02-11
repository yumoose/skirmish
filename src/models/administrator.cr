class Administrator < Jennifer::Model::Base
  with_timestamps

  mapping(
    id: Primary64,
    player_id: Int64?,
    league_id: Int64?,

    created_at: { type: Time, default: Time.local },
    updated_at: { type: Time, default: Time.local }
  )

  belongs_to :player, Player
  belongs_to :league, League

  validates_presence :player_id
  validates_presence :league_id

  validates_with PlayerRelationValidator
  validates_with LeagueRelationValidator
end
