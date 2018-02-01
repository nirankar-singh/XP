class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
   #before_save :ensure_authentication_token
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :token_authenticatable
  
  acts_as_mappable :default_units => :miles,
                   :default_formula => :sphere,
                   :distance_field_name => :distance,
                   :lat_column_name => :latitute,
                   :lng_column_name => :longitute

  validate :password_complexity
  has_one :channel, dependent: :destroy
  has_many :current_events, dependent: :destroy
  has_one :intro_video, dependent: :destroy
  has_many :stories, as: :storyable, dependent: :destroy
  has_many :notifications, dependent: :destroy

  has_many :seens, dependent: :destroy


  #begin: follow unfollow associations
  has_many :follower_relationships, foreign_key: :following_id, class_name: 'Follow'
  has_many :followers, through: :follower_relationships, source: :follower

  has_many :following_relationships, foreign_key: :follower_id, class_name: 'Follow'
  has_many :following, through: :following_relationships, source: :following
  #end: follow unfollow associations

  #blocked users
  has_many :blocks, dependent: :destroy

  #blocked posts
  has_many :post_blocks, dependent: :destroy

  #follow stories
  has_many :follow_stories

  #claim event
  has_many :claims, dependent: :destroy

  #invitation notis
  has_many :invitation_notis, dependent: :destroy

  #surveys
  has_many :surveys, dependent: :destroy

  #begin: follow & unfollow
  def follow(user_id, follow_status)
    following_relationships.create(following_id: user_id, follow_status: follow_status)
  end

  def unfollow(user_id)
    fs =  following_relationships.find_by(following_id: user_id)
    p "#{fs}============================================unfollow"
    fs.destroy
  end

  def confirm_request(user_id)
    follower_relationships.find_by(follower_id: user_id).update(follow_status: 2)
  end
  #end: follow & unfollow

  
  def password_complexity
    if password.present? and not password.match('^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[$@$!%*?&#]).{8,}')
      errors.add :password, "must include at least one lowercase letter, one uppercase letter,one Special Character and one digit"
    end
  end
  # validates :authentication_token, uniqueness: true
  def self.save_img(upload)
      uploader = ImageUploader.new
      uploader.store!(upload)
      filepath = Rails.application.secrets.image_link
      return filepath + uploader.url
	end

  def self.genrate_access_token
    return SecureRandom.hex(3)
  end
end
