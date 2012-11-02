class QuestionsController < ApplicationController
  before_filter :authenticate_user!
  
  def show
    @question = Question.find(params[:id])
  end

  def save
    question = Question.create(
          notify: params[:notify],
          course_id: params[:id],
          user_id: current_user.id,
          question: params[:question]
    )
    flash[:success] = "Question Submitted"
    course = Course.find(params[:id])
    UserMailer.question_notification(course.user, question).deliver
    redirect_to "/courses/" + params[:course_id]
  end
  
  def create
    question = Question.create(
          notify: params[:notify],
          answerer_id: params[:id],
          user_id: current_user.id,
          question: params[:question]
    )
    flash[:success] = "Question Submitted"
    user = User.find(params[:id])
    UserMailer.question_notification(user, question).deliver
    redirect_to "/creator/" + params[:id]
  end

end
