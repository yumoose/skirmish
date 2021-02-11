class Participation < Jennifer::Model::Base
  with_timestamps

  mapping(
    id: Primary64,
    game_id: Int64,
    player_id: Int64,

    won: Bool,
    rating: Int32?,
    confirmation_code: String,

    created_at: { type: Time, default: Time.local },
    updated_at: { type: Time, default: Time.local }
  )

  belongs_to :game, Game
  belongs_to :player, Player

  validates_presence :game_id
  validates_presence :player_id
  validates_presence :won

  def won?
    !!won
  end

  def lost?
    !won
  end
end
