class Board < ApplicationRecord
  belongs_to :team, optional: true
  has_many :tasks, dependent: :destroy

  validate :name_presence_and_length
  validate :description_presence_and_length
  validate :team_presence

  private

  def name_presence_and_length
    if name.blank?
      errors.add(:name, "cannot be blank, it must be between 2 and 25 characters.")
    elsif name.length < 2 || name.length > 25
      errors.add(:name, "must be between 2 and 25 characters.")
    elsif new_record? || name_changed?
      if Board.where.not(id: id).exists?(name: name)
        errors.add(:name, "must be unique, this name is already taken.")
      end
    end
  end


  def description_presence_and_length
    if description.blank?
      errors.add(:description, "cannot be blank, it must be between 20 and 200 characters.")
    elsif description.length < 20 || description.length > 300
      errors.add(:description, "must be between 20 and 300 characters.")
    end
  end

  def team_presence
    errors.add(:team, "must be selected.") if team.nil?
  end
end
