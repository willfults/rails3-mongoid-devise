
class Course 
  include Mongoid::Document
  include Mongoid::Timestamps

  attr_accessible :description, :name, :privacy, :category_id, :published, :user_id, :rating_average#, :scorm_file 
  field :user_id, type: Integer # index this field, used for queries
  field :category_id, type: Integer
  field :privacy, type: String
  field :published, type: Boolean
  field :name, type: String
  field :description, type: String
  field :rating_average, type: String
  
  
  validates :name, presence: true
  validates :description, presence: true
  validates :category_id, presence: true
  validates :privacy, presence: true
  validates :user_id, presence: true
  validate :publish
  
  def publish
    if published == true && self.course_modules.size == 0
      errors[:base] << "Unable to publish courses that have no modules."
      self.published = false
    end
  end
  
  def to_param
    "#{id} #{name}".parameterize
  end

  belongs_to :user
  #has_many :course_modules, :order => "position", :dependent => :destroy
  #has_many :course_histories, :dependent => :destroy
  #has_many :bookmarks, :dependent => :destroy
  #accepts_nested_attributes_for :course_modules, :allow_destroy => true
  attr_accessible :course_modules_attributes
  
 
   
  def user_name 
    user.name
  end

  
end
# == Schema Information
#
# Table name: courses
#
#  id          :integer         not null, primary key
#  name        :string(255)
#  description :text
#  user_id     :integer
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#  category    :string(255)
#  privacy     :string(255)
#  published   :boolean
#

