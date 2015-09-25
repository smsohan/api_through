lock '3.3.5'

set :application, 'api_through'
set :repo_url, 'https://github.com/smsohan/api_through.git'

set :linked_dirs, ['secrets', 'node_modules']
SSHKit.config.command_map[:build_and_run] = "#{current_path}/build_and_run.sh"
set :use_docker, fetch(:use_docker, true)
set :pty, true

set :application_user, 'root'
SSHKit.config.command_map.prefix[:chmod].push('sudo')

Rake::Task['deploy:log_revision'].clear_actions

module SSHKit
  class Command
    def user(&block)
      "sudo -E -u #{fetch(:application_user)} #{environment_string + " " unless environment_string.empty?}-- sh -c '%s'" % %Q{#{yield}}
    end
  end
end

namespace :deploy do

  task :log_revision do
  end

  task :docker do
    on roles(:app) do

      last_packages = nil
      last_release_dir = nil

      within releases_path do
        last_release = capture('ls', '-al | tail -2 | head -1')
        if last_release
          last_release_dir = last_release.strip.split.last
          last_packages = begin; capture('sha256sum', last_release_dir + '/package.json').strip.split.first; rescue; ''; end
        end
      end

      within current_path do
        if last_packages
          current_packages = capture('sha256sum', 'package.json').strip.split.first
          if current_packages == last_packages
            puts "Copying the old Gemfile* since the contents are same"
            execute :cp, "--preserve=timestamps #{releases_path}/#{last_release_dir}/package.json", "."
          else
            puts "Skipping the packages.json copy since the shas are different"
          end
        else
          puts "Last release packages.json is not found"
        end

        spyrest_ca_pass = capture('cat', 'secrets/SPYREST_CA_PASS').strip
        with spyrest_ca_pass: spyrest_ca_pass do
          execute :build_and_run
        end
      end
    end
  end

  task :standalone do
    on roles(:app) do
      within current_path do
        execute :npm, "install"
        as :root do
          with path: "/bin:/usr/bin:/usr/local/bin" do
            execute :svc, '-t /service/api_through'
            # execute :svc -u /service/api_through'
          end
        end
      end
    end
  end

  task :restart do
    if fetch(:use_docker)
      invoke 'deploy:docker'
    else
      invoke 'deploy:standalone'
    end
  end

  after :finished, 'deploy:restart'

end