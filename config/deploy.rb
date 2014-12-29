lock '3.3.5'

set :application, 'api_through'
set :repo_url, 'git@github.com:smsohan/api_through.git'

SSHKit.config.command_map[:build_and_run] = "#{current_path}/build_and_run.sh"

namespace :deploy do

  task :build_and_run do
    on roles(:app) do
      within current_path do
        execute :build_and_run
      end
    end
  end

  after :finished, :build_and_run
end
