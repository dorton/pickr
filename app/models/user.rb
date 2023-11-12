class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :rememberable, :validatable
  # has_many :group_managers, dependent: :destroy
  # has_many :groups, as: :manager, through: :group_managers
  has_many :user_groups, dependent: :destroy
  has_many :groups, through: :user_groups
  has_many :picks, dependent: :destroy
end
