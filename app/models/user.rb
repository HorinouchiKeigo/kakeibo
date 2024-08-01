class User < ApplicationRecord
  has_many :journal_entries

  validates :auth0_id, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true
  validates :name, presence: true

  def self.find_or_create_from_auth_info(auth_info)
    user = User.find_or_create_by(auth0_id: auth_info["uid"])
    user.update(
      email: auth_info["info"]["email"],
      name: auth_info["info"]["name"]
    )
    user
  end
end
