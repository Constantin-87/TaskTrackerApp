class Team < ApplicationRecord
    has_and_belongs_to_many :users, dependent: :nullify
    has_many :boards, dependent: :nullify

    validates :name, presence: true, length: { minimum: 5 }, uniqueness: true
    validates :description, presence: true, length: { minimum: 10 }
end
