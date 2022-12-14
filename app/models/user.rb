class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: %i[facebook]

  has_one_attached :avatar

  has_many :articles, foreign_key: :author_id, dependent: :destroy, class_name: 'Article'
  has_many :likes, foreign_key: :liker_id, dependent: :destroy
  has_many :liked_articles, through: :likes
  has_many :comments, foreign_key: 'commenter_id', class_name: 'Comment', dependent: :destroy

  # to remove assocation just call delete
  # if you add dependent: :destroy to has_many (no need for belongs_to)
  # this will destroy the user entirely from the db
  # either delete or destroy, delete_all or destroy_all
  has_many :friendships, dependent: :destroy
  has_many :friends, through: :friendships, dependent: :destroy

  has_many :sent_requests, foreign_key: 'requester_id', class_name: 'FriendRequest', dependent: :destroy
  has_many :received_requests, foreign_key: 'receiver_id', class_name: 'FriendRequest', dependent: :destroy

  # we sure to add case insensitivity to your validations on :username
  validates :username, presence: true, uniqueness: { case_sensitive: false }
  # only allow letter, number, underscore and punctuation.
  validates_format_of :username, with: /^[a-zA-Z0-9_.]*$/, multiline: true
  # check if the same email as the username already exists in the database:
  validate :validate_username

  # Create a login virtual attribute in the User model
  # Add login as an User
  attr_writer :login

  def displayed_avatar
    avatar.attached? ? avatar : Faker::Avatar.image # 'default_avatar.jpg'
  end

  def pendings
    received_requests.pending.or(sent_requests.pending)
  end

  def pending_ids(arr = [])
    pendings.find_each do |pending_request|
      arr << pending_request.requester_id unless pending_request.requester == self
      arr << pending_request.receiver_id unless pending_request.receiver == self
    end
    arr
  end

  def validate_username
    errors.add(:username, :invalid) if User.where(email: username).exists?
  end

  def login
    @login || username || email
  end

  # Because we want to change the behavior of the login action,
  # we have to overwrite the find_for_database_authentication method.
  # The method's stack works like this: find_for_database_authentication
  # calls find_for_authentication which
  # calls find_first_by_auth_conditions.
  # Overriding the find_for_database_authentication method
  # allows you to edit database authentication;
  # overriding find_for_authentication
  # allows you to redefine authentication at a specific point
  # (such as token, LDAP or database).
  # Finally, if you override the find_first_by_auth_conditions method,
  # you can customize finder methods
  # (such as authentication, account unlocking or password recovery).

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if (login = conditions.delete(:login))
      where(conditions.to_h).where(['lower(username) = :value OR lower(email) = :value',
                                    { value: login.downcase }]).first
    elsif conditions.has_key?(:username) || conditions.has_key?(:email)
      where(conditions.to_h).first
    end
  end

  def self.from_omniauth(auth)
    find_or_create_by!(provider: auth.provider, uid: auth.uid) do |user|
      # replace all the spaces with _, to pass validation
      user.username = auth.info.name.gsub!(' ', '_') # assuming the user model has a name
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      # user.avatar = auth.info.image # assuming the user model has an image
      # If you are using confirmable and the provider(s) you use validate emails,
      # uncomment the line below to skip the confirmation emails.
      # user.skip_confirmation!
    end
  end

  # def self.new_with_session(params, session)
  #   super.tap do |user|
  #     if (data = session['devise.facebook_data'] && session['devise.facebook_data']['extra']['raw_info']) && user.email.blank?
  #       user.email = data['email']
  #     end
  #   end
  # end
end
