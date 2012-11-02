class CourseModulesController < ApplicationController
  before_filter :get_class
  before_filter :authenticate_user!, :only => [:show, :previous, :next, :quiz_answers]
  #before_filter :is_course_creator?, :only => [:reorder, :reorder_save, :new, :create, :edit, :update, :destroy]

  def reorder
    @course = Course.find(params[:course_id])
    @course_modules = @course.course_modules
  end

  def reorder_save
    module_order = params[:module_order].split(",")
    module_order.each_with_index do |module_id,index|
      row = CourseModule.find(module_id)
      row.position = index + 1
      row.save
    end
    @course = Course.find(params[:course_id])
    respond_to do |format|
      format.html {   # this is hardly used, for browsers that don't support xhr
        redirect_to course_course_modules_path(@course);
      }
      format.json {  
        render :json => { :result => 'success'}, :content_type => 'text/html'   
      }
    end
    
  end
 
  def get_class
      @course = Course.find(params[:course_id])
  end
  
  def index
    @course_modules = @course.course_modules
  end
  
  def new
    course_modules = Course.find(params[:course_id]).course_modules
    @course_module = CourseModule.new
    @course_module.class_type = params[:type]
    if course_modules.empty?
      @course_module.name = "Course Module 1"
    else 
      @course_module.name = "Course Module " + (course_modules.last.position + 1).to_s
    end
    
    if @course_module.class_type == "Quiz" 
      quiz = @course_module.build_quiz
      quiz.passing_score = 70
      question = quiz.quiz_questions.build
      4.times { question.quiz_answers.build }
    end
  
    @course_modules = @course.course_modules
    puts @course_modules
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @question }
    end
  end

  def create
    @course = current_user.courses.where(:id => params[:course_id]).first
    @lastModule = @course.course_modules.last
    
    @course_module = @course.course_modules.build(params[:course_module])
    
    if params[:add_question]
      # add empty ingredient associated with @recipe
      question = @course_module.quiz.quiz_questions.build
      4.times { question.quiz_answers.build }
      render 'new'
    else 
      if @lastModule 
        @course_module.position = @lastModule.position + 1 
      else
        @course_module.position = 1
      end
      if @course_module.class_type == 'Youtube' || @course_module.class_type == "Quiz"
        if @course_module.save
          flash[:success] = "Course Module created!"
          redirect_to course_course_modules_path(@course)
        else
          render 'new'
        end
      else       
        if @course_module.save
          flash[:success] = "Course Module created!"
          respond_to do |format|
            format.html {   # this is hardly used, for browsers that don't support xhr
              render :json => { :result => 'good'},
              :content_type => 'text/html',
              :layout => false
            }
            format.json {  
              render :json => { :result => 'success'}, :content_type => 'text/html'   
            }
          end
        else
          flash[:success] = "Failed to create module"
          render :json => [{:error => "custom_failure"}], :status => 304
        end
      end
    end
    
  end
  
  def edit
    get_class
    @course_module = @course.course_modules.where(:id => params[:id]).first
    @course_modules = @course.course_modules
    
    render 'edit'
  end
  
  def update
      @course = current_user.courses.where(:id => params[:course_id]).first
      @course_module = @course.course_modules.where(:id => params[:id]).first
      @course_modules = @course.course_modules
      
      if params[:add_question]
        # add empty ingredient associated with @recipe
        question = @course_module.quiz.quiz_questions.build
        4.times { question.quiz_answers.build }
        render 'edit'
      else 
        if @course_module.update_attributes(params[:course_module])
           redirect_to course_course_modules_path(@course);
        else
           render :action => 'edit'
        end
      end
   end

  def show
      get_class
      @course_module = @course.course_modules.where(:id => params[:id]).first
      #@course_history = current_user.course_histories.where(:course_id => @course.id).first
      
      #if !@course_history
      #  @course_history = current_user.course_histories.build(:course_id => @course.id, :status => "in_progress")
      #  @course_history.save
      #end
      
      #@course_module_history = @course_history.course_module_histories.where(:course_module_id => @course_module.id).first
      
      #if !@course_module_history
      #  @course_module_history = @course_history.course_module_histories.build(:course_module_id => @course_module.id, :status => "in_progress")
      #  @course_module_history.save
      #end
    
      
      if @course_module.class_type == "Video" || @course_module.class_type == "Audio" || @course_module.class_type == 'Youtube'
        render 'show'
      elsif @course_module.class_type == "Quiz"
        render 'quiz'
      elsif @course_module.class_type == "Image" || @course_module.class_type = "Scorm"
        update_module_as_complete @course_module_history
        Statistic.create(
          class_id: @course_module.id,
          course_id: @course.id,
          user_id: current_user.id,
          action: "done"
        )
        if @course_module.class_type == "Image"
          render 'image'
        elsif @course_module.class_type == "Scorm"
          render 'scorm'
        end
      end
   end

  def destroy
    @course = current_user.courses.where(:id => params[:course_id]).first
    @courseModule = @course.course_modules.where(:id => params[:id]).first
    if @courseModule.present?
      @courseModule.course_histories.destroy
      @courseModule.destroy
      flash[:success] = "Course deleted!"
    end
    # in both cases, redirect to root_path
    redirect_to course_course_modules_path(@course)
  end
  
  def quiz_answers
    get_class()
    @course_module = @course.course_modules.where(:id => params[:id]).first
    quiz = @course_module.quiz
    quiz_questions = quiz.quiz_questions
    
    correctAnswers = 0
    quiz_questions.each do |question|
      correctAnswer = question.quiz_answers.where(:correct_answer => true).first
      answer = params["question_" + question.id.to_s]
      if correctAnswer.id.to_s == answer
        correctAnswers += 1
      end
    end
    puts "Correct Answers = " + correctAnswers.to_s
    puts "Correct Answers = " + quiz_questions.size.to_s
    puts "Correct Answers2 = " +  ((correctAnswers / quiz_questions.size)).to_s
    puts "Correct Answers3 = " +  ((correctAnswers / quiz_questions.size) * 100).to_s
    @score = ((correctAnswers.to_f / quiz_questions.size) * 100).to_i 
    
    if quiz.passing_score <= @score
      course_history = get_course_history @course.id
      course_module_history = get_course_module_history course_history, @course_module.id
      update_module_as_complete(course_module_history)
    end
    
    render 'quiz_results'
  end
  
  # AJAX POST - courses/:course_id/course_modules/:id/:status/
  def update_stat
    class_id = params[:id]
    course_id = params[:course_id]
    action = params[:status]
    if action == 'done'
      
      course_history = get_course_history course_id
      course_module_history = get_course_module_history course_history, class_id
      update_module_as_complete(course_module_history)
      
      Statistic.create(
        class_id: class_id.to_i,
        course_id: course_id.to_i,
        user_id: current_user.id,
        action: action.to_str
      )
    else
      Resque.enqueue(StatCollector, class_id.to_i, course_id.to_i, current_user.id, action)
    end
    render :nothing => true
  end
  
  def update_module_as_complete(course_module_history)
    course_module_history.status = "completed"
    course_module_history.save
    
    course_history = course_module_history.course_history
    
    course_modules_size = course_history.course_module_histories.size
    course_modules_completed_size = course_history.course_module_histories.where(:status => "completed").size
    
    if course_modules_size == course_modules_completed_size 
      course_history.status = "completed"
      Activity.create(
        type: "course_completion",
        user_id: current_user.id,
        course_id: course_module_history.course_module.course_id
      )
      course_history.save
    end
  end
    
  def get_course_history(course_id)
      current_user.course_histories.where(:course_id => course_id).first
  end
  
  def get_course_module_history(course_history, module_id)
      course_history.course_module_histories.where(:course_module_id => module_id).first
  end

  def next
    get_class
    @course_module = @course.course_modules.where(:id => params[:id]).first   
    course_history = get_course_history(@course.id)
    course_module_history = get_course_module_history(course_history, @course_module)
    
    # THIS CODE COULD BE SIMPLER IF WE GUARENTEE MODULE POSITIONS ARE SEQUENTIAL. 
    position_in_modules = 0
    if course_module_history.status != "completed"
      redirect_to course_course_module_path(@course, @course_module), :flash => { :error => "You have not completed this module." }
    else
      @course.course_modules.each_with_index do |course_module, index|
        if @course_module.position == course_module.position
          position_in_modules = index
          break
        end
      end
      
      if @course.course_modules.size == position_in_modules+1
        render "complete"
      else
        redirect_to course_course_module_path(@course, @course.course_modules[position_in_modules+1])
      end
    end
      
  end
  
  def previous
    get_class
    @course_module = @course.course_modules.where(:id => params[:id]).first   
    course_history = get_course_history(@course.id)
    course_module_history = get_course_module_history(course_history, @course_module)
    
    # THIS CODE COULD BE SIMPLER IF WE GUARENTEE MODULE POSITIONS ARE SEQUENTIAL. 
    position_in_modules = 0
    @course.course_modules.each_with_index do |course_module, index|
      if @course_module.position == course_module.position
        position_in_modules = index
        break
      end
    end
    
    if position_in_modules == 0
      redirect_to course_path(@course) + "/start"
    else
      redirect_to course_course_module_path(@course, @course.course_modules[position_in_modules-1])
    end
  end

end
