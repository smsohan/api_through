role :app, "#{ENV['SSH_USER']}@#{ENV['HOST']}"
set :use_docker, false