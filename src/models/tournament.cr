class Tournament < Jennifer::Model::Base
  with_timestamps

  mapping(
    id: { type: Int64, primary: true },
    league_id: Int64?,
    finished_at: Time?,

    created_at: { type: Time, default: Time.now },
    updated_at: { type: Time, default: Time.now }
  )

  validates_presence :league_id

  belongs_to :league, League
  has_many :matches, Match

  scope :unfinished { where { _finished_at == nil } }
  scope :for_league { |league| where { _league_id == league.id } }
end
