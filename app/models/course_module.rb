class CourseModule 
  include Mongoid::Document
  include Mongoid::Timestamps
  attr_accessible :file_cache, :file, :name, :summary, :class_type, :course_id, :position, :video_url, :scorm_resource_path
  #video url contains a youtube video url - supported formats - http://www.longtailvideo.com/support/jw-player/jw-player-for-flash-v5/12539/supported-video-and-audio-formats

  attr_accessible :completed_date, :completed, :quiz_attributes

  mount_uploader :file, MediaUploader

  belongs_to :course
  field :name, type: String
  field :summary, type: String
  field :class_type, type: String
  field :file, type: String
  field :course_id, type: String # this is now a string because of mongo
  field :position, type: Integer
  field :video_url, type: String
  field :scorm_resource_path, type: String

  validates :name, presence: true
  validates :class_type, presence: true
  validates :file, presence: true, :if => :validate_file?
  validates :video_url, presence: true, :format => URI::regexp(%w(http https)), :if => :validate_youtube?
  validate :is_from_youtube, :if => :validate_youtube?

  #has_many :course_histories

  def validate_youtube?
    class_type == "Youtube"
  end

  def is_from_youtube
     if !video_url.include?('youtube') && !video_url.include?('youtu.be')
      errors.add(:video_url, " must be a valid youtube url" )
     end
  end

  def validate_file?
    class_type !="Quiz" && class_type != "Youtube" && class_type != "Scorm"
  end

  def total_views
    statistics = Statistic.where(:course_id => self.course_id).where(:class_id => self.id).where(:status => "play").count
  end

  validates_format_of :file, :with => %r{\.(gif|png|jpg|jpeg)$}i, :if => :validate_image?, :message =>"Invalid image was entered. You can use either png or jpg/jpeg."
  def validate_image?
    class_type =="Image"
  end

  validates_format_of :file, :with => %r{\.(mp3)$}i, :if => :validate_audio?, :message =>"Invalid audio file was entered. You can use an mp3 file."
  def validate_audio?
    class_type =="Audio"
  end

  validates_format_of :file, :with => %r{\.(mp4)$}i, :if => :validate_video?, :message =>"Invalid video file was entered. You can use an mp4 file."
  def validate_video?
    puts class_type
    class_type =="Video"
  end

  #has_one :quiz
  #accepts_nested_attributes_for :quiz, :allow_destroy => true

end

