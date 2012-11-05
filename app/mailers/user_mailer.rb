class UserMailer < ActionMailer::Base
  default :from => "no-reply@socialu.com"

  def  question_notification(user, question)
    @user = user
    @question = question
    mail(:to => user.email, :subject => "You have received a question from #{user.name}")
  end
  
  def  update_question_notification(user, question)
    @user = user
    @question = question
    mail(:to => user.email, :subject => "#{user.name} has updated their question regarding course: #{question.course.name}")
  end
  
  def  answer_notification(question)
    @question = question
    if question.course_id.present?
      mail(:to => question.user.email, :subject => "You have received an answer to your question regarding course: #{question.course.name}")
    else
      mail(:to => question.user.email, :subject => "You have received an answer to your question")
    end
  end
end
