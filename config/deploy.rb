lock '3.3.5'

set :application, 'api_through'
set :repo_url, 'git@github.com:smsohan/api_through.git'

set :linked_dirs, ['secrets', 'node_modules']
SSHKit.config.command_map[:build_and_run] = "#{current_path}/build_and_run.sh"

set :use_docker, fetch(:use_docker, true)

namespace :deploy do

  task :build_and_run do

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

  task :npm_install do
    within current_path do
      execute :npm, "install"
    end
  end

  task :restart do
    execute 'svc -t /service/api_through'
    execute 'svc -u /service/api_through'
  end

  if fetch(:use_docker)
    after :finished, :build_and_run
  else
    after :finished, :npm_install
    after :npm_install, :restart
  end
end