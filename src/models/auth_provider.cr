class AuthProvider < Jennifer::Model::Base
  GOOGLE_PROVIDER = "google"

  AVAILABLE_PROVIDERS = [
    GOOGLE_PROVIDER
  ]

  mapping(
    id: Primary64,

    user_id: Int64?,
    token: String,
    provider: String,

    created_at: { type: Time, default: Time.local },
    updated_at: { type: Time, default: Time.local }
  )

  scope :linked { where { _user_id != nil } }
  scope :unlinked { where { _user_id == nil } }
  scope :google { where { _provider == GOOGLE_PROVIDER } }

  with_timestamps

  belongs_to :user, User

  validates_presence :token
  validates_presence :provider

  validates_inclusion :provider, in: AVAILABLE_PROVIDERS
end
