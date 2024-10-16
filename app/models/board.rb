class Board < ApplicationRecord
  belongs_to :team
  has_many :tasks, dependent: :destroy

  validates :name, presence: true
end
