class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable

  enum :role, { super_admin: 0, forum_admin: 1, chapter_admin: 2, committee_member: 3, member: 4, guest: 5 }

  belongs_to :forum, optional: true
  belongs_to :chapter, optional: true

  validates :forum, presence: true, unless: :super_admin?

  def display_name
    email.split("@").first
  end
end
