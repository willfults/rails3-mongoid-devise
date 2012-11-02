class AnswersController < ApplicationController
  before_filter :authenticate_user!, :is_creator

  def edit

  end

  def save
    @question.answer = Answer.new
    @question.answer.user_id = current_user.id
    @question.answer.course_id = @question.course_id
    @question.answer.answer = params[:answer]
    @question.save
    flash[:success] = "Answer saved"
    Activity.create(
        type: "answer",
        user_id: current_user.id,
        creator_id: @question.user_id,
        question_id: @question.id
      )
    if @question.notify
      UserMailer.answer_notification(@question).deliver
    end
    if @question.course_id.present?
      redirect_to course_path(@question.course)
    else
      redirect_to creator_landing_path(current_user)
    end
  end

  def is_creator
    @question = Question.find(params[:id])
    if current_user.id != @question.answerer_id && !@question.course_id.present?
      redirect_to root_path
    else if !@question.answerer_id.present? && current_user.id != @question.course.user_id
        #only allow course creator to answer question
      redirect_to course_path(@question.course)
      end
    end
  end

end