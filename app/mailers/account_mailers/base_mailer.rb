class AccountMailers::BaseMailer < ApplicationMailer
  default from: ENV["MAILER_FROM"] || "no-reply@queens-awards-enterprise.service.gov.uk",
          reply_to: "queensawards@bis.gsi.gov.uk"

  layout "mailer"

  attr_reader :form_answer
end
