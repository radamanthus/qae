unless Rails.env.development? || Rails.env.test?
  Rails.application.configure do
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
      address: ENV["AWS_SES_SMTP_ADDRESS"],
      port: ENV["AWS_SES_SMTP_PORT"],
      domain: ENV["AWS_SES_DOMAIN_NAME"],
      authentication: ENV["AWS_SES_SMTP_AUTHENTICATION"],
      user_name: ENV["AWS_SES_USERNAME"],
      password: ENV["AWS_SES_PASSWORD"],
      enable_starttls_auto: true
    }
  end
end
