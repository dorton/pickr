class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :rememberable, :validatable
  has_many :group_managers, dependent: :destroy
  has_many :managed_groups, through: :group_managers, source: :group
  has_many :user_group_defaults, dependent: :destroy
  has_many :group_defaults, through: :user_group_defaults, source: :group
  has_many :user_groups, dependent: :destroy
  has_many :groups, through: :user_groups
  has_many :picks, dependent: :destroy
end
