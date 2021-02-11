class Invitation < Jennifer::Model::Base
  with_timestamps

  mapping(
    id: Primary64,

    league_id: Int64,
    player_id: Int64,
    approver_id: Int64?,

    accepted_at: Time?,
    approved_at: Time?,

    created_at: { type: Time, default: Time.local },
    updated_at: { type: Time, default: Time.local }
  )

  belongs_to :league, League
  belongs_to :player, Player
  belongs_to :approver, Player, nil, "approver_id"

  validates_presence :player_id
  validates_presence :league_id

  def accepted?
    !!accepted_at
  end

  def approved?
    !!approved_at
  end
end
