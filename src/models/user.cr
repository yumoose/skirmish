require "crypto/bcrypt/password"

class User < Jennifer::Model::Base
  include Crypto

  with_timestamps

  mapping(
    id: Primary64,
    email: String,
    name: String,
    password_digest: String?,
    receive_email_notifications: { type: Bool, default: true },

    verification_code: String,
    activated_at: Time?,

    reset_digest: String?,
    reset_sent_at: Time?,

    created_at: { type: Time, default: Time.local },
    updated_at: { type: Time, default: Time.local }
  )

  scope :unverified { where { _activated_at == nil } }

  has_one :player, Player
  has_many :auth_providers, AuthProvider

  validates_presence :name
  validates_presence :email
  validates_uniqueness :email
  validates_format :email, /^[a-zA-Z0-9.!#$%&’*+\/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$/

  validates_presence :verification_code
  validates_format :verification_code, /^[0-9a-z]{16}$/

  def activate!
    update!(activated_at: Time.local) unless activated?
  end

  def activated?
    !!activated_at
  end

  {% for method in %i(reset) %}
    {% method = method.id %}
    def {{method}}_valid?(token : String)
      return false if {{method}}_digest.nil?
      Crypto::Bcrypt::Password.new({{method}}_digest.not_nil!) == token
    end
  {% end %}

  def password_reset_expired?
    reset_sent_at.nil? || reset_sent_at! < 2.hours.ago
  end

  def unverified?
    !activated?
  end

  def receive_email_notifications?
    receive_email_notifications
  end

  def password=(password)
    @new_password = password
    @password_digest = Bcrypt::Password.create(password, cost: 10).to_s
  end

  def password
    (hash = password_digest) ? Bcrypt::Password.new(hash) : nil
  end

  def password_changed?
    new_password ? true : false
  end

  def valid_password_size?
    (pass = new_password) ? pass.size >= 8 : false
  end

  def authenticate(password : String)
    (bcrypt_pass = self.password) ? bcrypt_pass.verify(password) : false
  end

  private getter new_password : String?
end
