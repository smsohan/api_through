lock '3.3.5'

set :application, 'api_through'
set :repo_url, 'git@github.com:smsohan/api_through.git'

set :linked_dirs, fetch(:linked_dirs, []).push('secrets')
SSHKit.config.command_map[:build_and_run] = "#{current_path}/build_and_run.sh"

namespace :deploy do

  task :build_and_run do
    on roles(:app) do
      within current_path do
        spyrest_ca_pass = capture('cat', 'secrets/SPYREST_CA_PASS').strip
        with spyrest_ca_pass: spyrest_ca_pass do
          execute :build_and_run
        end
      end
    end
  end

  after :finished, :build_and_run
end
