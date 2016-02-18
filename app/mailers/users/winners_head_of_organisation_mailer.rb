# To 'Head of Organisation' of the Successful Business categories winners

class Users::WinnersHeadOfOrganisationMailer < ApplicationMailer
  def notify(form_answer_id)
    @form_answer = FormAnswer.find(form_answer_id).decorate

    @urn = @form_answer.urn
    @head_email = form_answer.head_email
    @award_year = @form_answer.award_year.year
    @award_category_title = @form_answer.award_type_full_name
    @head_of_business_full_name = form_answer.head_of_business_full_name

    @subject = "[Queen's Awards for Enterprise] Important information about your Queen's Award!"

    mail to: @head_email, subject: @subject
  end
end