class AccountMailers::NotifyNonShortlistedMailer < AccountMailers::BaseMailer
  def notify(form_answer_id, collaborator_id)
    @form_answer = FormAnswer.find(form_answer_id).decorate
    @user = form_answer.user.decorate
    collaborator = User.find(collaborator_id)

    @current_year = @form_answer.award_year.year
    @subject = "Queen's Awards for Enterprise: Thank you for applying"

    mail to: collaborator.email, subject: @subject
  end

  # ep_notify is disabled for now
  def ep_notify(form_answer_id, collaborator_id)
    @form_answer = FormAnswer.find(form_answer_id).decorate
    @user = @form_answer.user.decorate
    collaborator = User.find(collaborator_id)

    @current_year = @form_answer.award_year.year
    @subject = "Queen's Awards for Enterprise Promotion: Thank you for your nomination"

    mail to: collaborator.email, subject: @subject
  end
end
