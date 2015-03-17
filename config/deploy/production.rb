set :default_env, { 'RAILS_ENV' => 'production' }
set :rails_env, 'production'
set :branch, ENV["BRANCH"] || 'production'

# HARDCODED FOR NOW
server '52.17.4.150', user: 'qae', roles: %w{web app}
server '52.17.3.45', user: 'qae', roles: %w{web app}
