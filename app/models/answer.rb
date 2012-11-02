class Answer
  include Mongoid::Document
  include Mongoid::Timestamps

  field :course_id, type: Integer 
  field :user_id, type: Integer
  field :answer, type: String 
  
  validates_presence_of :answer
  validates_presence_of :user_id
  
  belongs_to :question
  before_destroy :delete_activity
  
  scope :ordered, order_by(:created_at => :desc)
  attr_accessor :user, :course
  
  # Mock a belongs_to relationship with User model
  def user
    user ||= User.find(self.user_id)
  end

  def course
    course ||= Course.find(self.course_id)
  end
  
  def delete_activity
        Activity.where(
          type: "answer",
          user_id: self.user_id,
          creator_id: question.user_id,
          question_id: question.id
        ).delete
  end
  
end