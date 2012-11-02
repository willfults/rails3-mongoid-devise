class Question 
  include Mongoid::Document
  include Mongoid::Timestamps

  field :course_id, type: Integer # index this field, used for queries
  field :notify, type: Boolean
  field :user_id, type: Integer
  field :question, type: String 
  field :answerer_id, type: Integer # this is the user_id for creators, used when a question is asked but not associated with a course
  
  embeds_one :answer
  
  validates_presence_of :question
  validates_presence_of :user_id
  
  scope :ordered, order_by(:created_at => :desc)
  attr_accessor :user, :course
  after_create :create_activity
  before_destroy :delete_activity
  
  def create_activity
      # create activity
      if self.course_id.present?
        activity = Activity.create(
          type: "course_question",
          user_id: self.user_id,
          course_id: self.course_id,
          question_id: self.id
        )
      else
        activity = Activity.create(
          type: "creator_question",
          user_id: self.user_id,
          creator_id: self.answerer_id,
          question_id: self.id
        )
      end
  end
  
  def delete_activity
    if self.course_id.present?
        Activity.where(
          type: "course_question",
          user_id: self.user_id,
          course_id: self.course_id,
          question_id: self.id
        ).delete
     else
        Activity.where(
          type: "course_question",
          user_id: self.user_id,
          creator_id: self.answerer_id,
          question_id: self.id
        ).delete
     end
  end
  
  # Mock a belongs_to relationship with User model
  def user
    user ||= User.find(self.user_id)
  end

  def course
    course ||= Course.find(self.course_id)
  end
  
end