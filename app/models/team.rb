class Team < ApplicationRecord
    has_many :users, dependent: :nullify
    has_many :boards, dependent: :destroy

    validates :name, presence: true, length: { minimum: 5 }
    validates :description, presence: true, length: { minimum: 10 }
end
