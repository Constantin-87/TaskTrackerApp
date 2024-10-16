class Team < ApplicationRecord
    has_many :users, dependent: :nullify
    has_many :boards, dependent: :destroy
  
    validates :name, presence: true
  end
  