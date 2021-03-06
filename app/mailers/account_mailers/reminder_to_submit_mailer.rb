class AccountMailers::ReminderToSubmitMailer < AccountMailers::BaseMailer
  def notify(form_answer_id, collaborator_id)
    @form_answer = FormAnswer.find(form_answer_id)
    @user = @form_answer.user
    @deadline = Settings.current_submission_deadline.strftime("%A %d %B %Y")
    collaborator = User.find(collaborator_id)

    subject = "Queen's Awards for Enterprise: Reminder to submit"

    mail to: collaborator.email, subject: subject
  end
end
