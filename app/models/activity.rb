#
# this class contains Activity data for the news feed
#

class Activity
  include Mongoid::Document
  include Mongoid::Timestamps

  field :type, type: String # activity types currently course
  field :user_id, type: Integer
  field :course_id, type: Integer #  used for course related activities
  field :creator_id, type: Integer # used for creator questions
  field :question_id, type: String
  attr_accessor :user, :course, :avatar, :creator
  
  validates_presence_of :type
  validates_presence_of :user_id
  
  scope :ordered, order_by(:created_at => :desc)
  
  # Mock a belongs_to relationship with User model
  def user
    user ||= User.find(self.user_id)
  end
  
  def avatar
    avatar ||= Avatar.find(user.avatar)
  end

  def course
    course ||= Course.find(self.course_id)
  end
  
  def creator
    creator ||= User.find(self.creator_id)
  end
  
end
