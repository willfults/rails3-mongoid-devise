class CoursesController < ApplicationController
  before_filter :authenticate_user!, :except => [:show]
  before_filter :getUnreadMessageCount, :only =>[:manage, :my_courses]
  #before_filter :is_course_creator?, :only => [:edit, :new, :create, :update, :destroy]
    
  def index
    @courses = Course.all
  end

  def explore
    @courses = Course.all
  end
  
  def edit
    @course = Course.find(params[:id])
  end
  
  def show
      @course = Course.find(params[:id])
      @questions = Question.ordered.where(:course_id => @course.id)
      respond_to do |format|
        format.html # new.html.erb
        format.xml  { render :xml => @course }
      end
  end
  
  def review
    @course = Course.find(params[:id])
    @course_history = current_user.course_histories.where(:course_id => @course.id).first
    if @course.user_id == current_user.id || @course_history.status != 'completed'
      flash[:error] = "You must complete this course and not be the course owner in order to review it."
      redirect_to "/courses/#{@course.id}"
    end
    @rate = Rate.where(:rater_id => current_user.id).where(:rateable_id => @course.id).first
  end
  
  def save_review
    # find rate by current_user.id course.id, update review field, save
    @course = Course.find(params[:id])
    @course_history = current_user.course_histories.where(:course_id => @course.id).first
    if @course.user_id == current_user.id || @course_history.status != 'completed'
      flash[:error] = "You must complete this course and not be the course owner in order to review it."
      redirect_to "/courses/#{@course.id}"
    end
    @rate = Rate.where(:rater_id => current_user.id).where(:rateable_id => @course.id).first
    if @rate.nil?
      flash[:error] = "Please select at least one star."
      redirect_to "/courses/#{@course.id}/review"
    end
    @rate.review = params[:review]
    if @rate.save
      flash[:success] = "Thank you for reviewing " + @course.name
    end
    redirect_to "/courses/#{@course.id}"
  end
   
  def start
      @course = Course.find(params[:id])
      @statistics = Statistic.where(:user_id => current_user.id).where(:course_id => @course.id).where(:status => "done")
      
      @course_history = current_user.course_histories.where(:course_id => @course.id).first
      
      if !@course_history
        @course_history = current_user.course_histories.build(:course_id => @course.id, :status => "in_progress")
        @course_history.save
      end
      @questions = Question.ordered.where(:course_id => @course.id)
      respond_to do |format|
        format.html # new.html.erb
        format.xml  { render :xml => @course }
      end
  end 
   
  def new
    @course = Course.new
  
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @question }
    end
  end
  
  def create
    @course = current_user.courses.build(params[:course])

    if @course.save
      puts 'save'
      flash[:success] = "Course created!"
      redirect_to course_course_modules_path(@course);
    else
      puts 'new'
      render 'new'
    end
  end
  
  def update
    @course = current_user.courses.where(:id => params[:id]).first
    if params[:delete_scorm]
      FileUtils.rm_rf("public/uploads/course/scorm_file/" + @course.id.to_s);
      @course[:scorm_file] = nil
      delete_scorm_modules(@course)
    end

    # Is there a better way of doing this?
    if params[:publish] 
      @course.published = true
    elsif params[:un_publish]
      @course.published = false
    end 
    
    if @course.update_attributes(params[:course])
       if params[:upload_scorm]
        begin
          unzip_file('public' + @course.scorm_file.to_s, "public/uploads/course/scorm_file/" + @course.id.to_s)
          @course = parse_manifest_file("public/uploads/course/scorm_file/" + @course.id.to_s + "/imsmanifest.xml", @course)
          @course.save
        rescue Exception => e
          flash[:error] = "Error parsing imsmanifest.xml"
          redirect_to edit_course_path(@course);
        end
       end
       flash[:success] = "Course saved!"
       redirect_to edit_course_path(@course);
    else
       render :action => 'edit'
    end
  end
  
  def publish
    @course = current_user.courses.where(:id => params[:id]).first
    if @course.present?
      @course.published = true;
      @course.save
      flash[:success] = "Course Published!" 
    end
    redirect_to course_course_modules_path(@course);
  end

  def destroy
    @course = current_user.courses.where(:id => params[:id]).first
    if @course.present?
      @course.course_modules.each do |course_module|
        course_module.course_histories.destroy
      end
      @course.destroy
      flash[:success] = "Course deleted!"
    end
    # in both cases, redirect to root_path
    redirect_to manage_courses_path
  end
  
  def manage
    set_admin_mode(true)
    @courses = current_user.courses
  end
  
  def my_courses
    set_admin_mode(false)
    @course_histories = current_user.course_histories.where("status != 'completed'")
    @bookmarks = current_user.bookmarks
  end
  
  def search
    if(params[:query].empty?)
      @courses = Course.where("published = 1 and privacy='Public'")
    else
      @facets = Course.facets(params)
      @courses = Course.search(params)
    end
  end
  
  def video
    @course = Course.find(params[:id])
  end
  
  def rate
    @course = Course.find(params[:id])
    @course.rate(params[:stars], current_user, params[:dimension])
    respond_to do |format|
      format.js
    end
  end
  
  def bookmark
    puts request.method
    if params[:remove]
      bookmark = current_user.bookmarks.where(:course_id => params[:id]).first
      bookmark.destroy
    else
      bookmark = current_user.bookmarks.build(:course_id => params[:id])
      bookmark.save
    end
    respond_to do |format|
      format.json { head :ok }
      format.html { redirect_to my_courses_path }
    end

  end
  
  private
    
    def parse_manifest_file(filename, course)
      file = File.open(filename)
      xml = File.read(file)
      manifest = Hash.from_xml(xml)
      course.name = manifest['manifest']['identifier']
      course.description = "Auto Generated SCORM Course via imported file " + course.scorm_file.filename
      resources = manifest['manifest']['resources']['resource']
      items = manifest['manifest']['organizations']['organization']['item']
      position = 1
      resources.each do |resource|
        resource_identifier = resource['identifier']
        item_identifier = "Auto Generated"
        items.each do |item|
          if item['identifierref'] == resource_identifier
            item_identifier = item['identifier']
            break
          end
        end
        course_module = CourseModule.new
        course_module.name = item_identifier
        course_module.summary = course_module.name
        course_module.class_type = "Scorm"
        course_module.course_id = course.id
        course_module.position = position 
        course_module.scorm_resource_path = resource['href']
        course_module.save
        position += 1
      end
      file.close
      course
    end
    
    def delete_scorm_modules(course)
      course_modules = CourseModule.find_all_by_course_id(course.id)
      if course_modules
        course_modules.each do |course_module|
          if course_module.class_type == "Scorm"
            course_module.delete
          end
        end
      end
    end

end
