class User < ApplicationRecord
  # Include default devise modules.
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtBlacklist

  # Enum for user roles
  enum :role, { agent: 0, manager: 1, admin: 2 }

  # Associations
  has_and_belongs_to_many :teams, optional: true
  has_many :tasks
  has_many :notifications, dependent: :destroy

  # Validations
  validates :email, presence: true, uniqueness: true
  validates :first_name, presence: true, length: { minimum: 2 }
  validates :last_name, presence: true, length: { minimum: 2 }
  validates :password, presence: true, length: { minimum: 6 }, if: :password_required?
  validates :password_confirmation, presence: true, if: :password_required?


  private

  # Method to add custom claims to the JWT payload
  def jwt_payload
    payload = {
      "sub" => id,                          # Subject: unique user ID
      "role" => role                        # Custom role claim
    }
    Rails.logger.info "JWT payload generated for user #{email}: #{payload}"  # Log payload generation
    payload
  end

  # Only require password if creating a new user or changing the password
  def password_required?
    new_record? || password.present?
  end
end
