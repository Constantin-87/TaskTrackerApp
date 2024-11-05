class Team < ApplicationRecord
    has_and_belongs_to_many :users, dependent: :nullify
    has_many :boards, dependent: :nullify

    validates :name, presence: true, length: { minimum: 2, maximum: 20 }, uniqueness: true
    validates :description, presence: true, length: { minimum: 20, maximum: 500 }

    def users_count
        users.size
    end

    def boards_count
        boards.size
    end
end
