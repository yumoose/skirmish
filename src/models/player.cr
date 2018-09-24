class Player < Jennifer::Model::Base
  RECENT_GAMES_LIMIT = 3

  with_timestamps

  mapping(
    id: { type: Int64, primary: true },
    user_id: Int64?,

    tag: String,

    created_at: { type: Time, default: Time.now },
    updated_at: { type: Time, default: Time.now }
  )

  belongs_to :user, User

  has_many :memberships, Membership
  has_many :participations, Participation
  has_many :administrators, Administrator

  has_and_belongs_to_many :leagues, League, nil, nil, nil, "memberships", "league_id"
  has_and_belongs_to_many :games, Game, nil, nil, nil, "participations", "game_id"

  validates_uniqueness :tag

  def ==(other)
    !other.nil? && self.class == other.class && self.id == other.id
  end

  def admin_of?(league : League)
    administrators_query.where { _league_id == league.id }.exists?
  end

  def in_league?(league : League)
    memberships_query.where { _league_id == league.id }.where { _left_at == nil }.exists?
  end

  def rating_for(league : League)
    latest_participation = participations_query.
      join(Game) { Participation._game_id == _id }.
      where { Game._league_id == league.id }.
      where { Participation._rating != nil }.
      order(created_at: :desc).
      limit(1).
      to_a.first?

    latest_participation.try(&.rating) || league.start_rating || League::DEFAULT_START_RATING
  end

  def recent_games
    games_query.order(confirmed_at: :desc, created_at: :desc).limit(RECENT_GAMES_LIMIT).to_a
  end
end
