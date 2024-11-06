class User < ApplicationRecord
  # Default devise modules.
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :api

  # Enum for user roles
  enum :role, { agent: 0, manager: 1, admin: 2 }

  # Associations
  has_and_belongs_to_many :teams, optional: true
  has_many :tasks, dependent: :nullify
  has_many :notifications, dependent: :destroy

  # Validations
  validates :email, presence: true, uniqueness: true
  validates :first_name, presence: true, length: { minimum: 2 }
  validates :last_name, presence: true, length: { minimum: 2 }
  validates :password, presence: true, length: { minimum: 6 }, if: :password_required?
  validates :password_confirmation, presence: true, if: :password_required?


  private

  # Only require password if creating a new user or changing the password
  def password_required?
    new_record? || password.present?
  end
end
