class Game < Jennifer::Model::Base
  with_timestamps

  mapping(
    id: Primary64,
    league_id: Int64?,

    logged_by_id: Int64?,
    confirmed_by_id: Int64?,
    confirmed_at: Time?,
    rating_delta: Int32?,

    created_at: { type: Time, default: Time.local },
    updated_at: { type: Time, default: Time.local }
  )

  belongs_to :league, League
  belongs_to :logger, Player, nil, "logged_by_id"
  belongs_to :confirmed_by, Player, nil, "confirmed_by_id"

  has_one :match, Match
  has_many :participations, Participation
  has_and_belongs_to_many :players, Player, nil, nil, nil, "participations", "player_id"

  scope :confirmed { where { _confirmed_at != nil } }
  scope :unconfirmed { where { _confirmed_at == nil } }

  def winner
    players_query.where { Participation._won == true }.to_a.first
  end

  def loser
    players_query.where { Participation._won == false }.to_a.first
  end

  def confirmed?
    !!confirmed_at
  end

  def unconfirmed?
    !confirmed?
  end
end
