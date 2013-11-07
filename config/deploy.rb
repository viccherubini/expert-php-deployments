# Deployment options
set :application, "Expert PHP Deployments"
set :repository, "git@github.com:leftnode/expert-php-deployments.git"
set :deploy_to, "/srv/http/apps/expertphpdeployments.com"
set :scm, :git

# Server roles
role :web, "expertphpdeployments.brightmarch.com"
role :db, "expertphpdeployments.brightmarch.com", :primary => true

# Github options
default_run_options[:pty] = true
ssh_options[:forward_agent] = true

# Environment options
set :branch, "master"
set :use_sudo, false
set :user, "deploy"
set :keep_releases, 5

before 'deploy:build', 'deploy:install_composer'
before 'deploy:build', 'deploy:install_phing'
before 'deploy:build', 'deploy:install_migrator'
before 'deploy:create_symlink', 'deploy:build'
after 'deploy:build', 'deploy:migrate'
after 'deploy:restart', 'deploy:cleanup'

namespace :deploy do
  phing_cmd = "php %s/phing.phar -f %s/build.xml -Dbuild_settings_file=%s/system/build.settings %s"

  task :install_composer, :roles => :web do
    run "curl -s https://getcomposer.org/installer | php -- --install-dir=#{latest_release}"
  end

  task :install_phing, :roles => :web do
    run "wget -qO #{latest_release}/phing.phar http://www.phing.info/get/phing-2.6.1.phar"
  end

  task :install_migrator, :roles => :web do
    run "wget -qO #{latest_release}/doctrine-migrations.phar " +
      "https://github.com/downloads/ericclemmons/migrations/doctrine-migrations.phar"
  end

  task :build, :roles => :web do
    run sprintf phing_cmd, latest_release, latest_release, shared_path, 'deploy'
  end

  task :migrate, :roles => :db do
    run sprintf phing_cmd, latest_release, latest_release, shared_path, 'run-database-migrations'
  end
end
