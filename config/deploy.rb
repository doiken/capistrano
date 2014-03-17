set :application, 'AMoAd'

##
## Deploy
##
set :scm, :s3
set :deploy_to, '/spacyz/adserver/'
set :branch, 'HEAD'
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }
set :repo_url, 'file:///vagrant/genius/'

##
## Deploy for s3 strategy
##
set :scm, :s3
set :deploy_to, '/spacyz/adserver/'
bucket_dir = ENV['BUCKET'] || 'ultima-package/adserver/'
build_id = ENV['BUILD_ID']
object_name = ENV['OBJECT'] || 'genius-src.tgz'
set :bucket_path, "#{bucket_dir}#{build_id}/#{object_name}"
set :archive_type, ENV['ARC_TYPE'] ? ENV['ARC_TYPE'].to_sym : :tar # [:raw(mvのみ)|:zip|:tar]
set :tar_strip, 1 # 0: Do Nothing, 1: Strip Root Directory
# set :linked_files, %w{config/database.yml}
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

##
## Adserver
##
set :maintenance_path, '/usr/java/tomcat/webapps/ROOT/maintenance.txt' # For Tomcat Maintenance
set :classpath, '/usr/java/tomcat/lib/servlet-api.jar' # For Ant Build
set :tomcat_log_path, '/spacyz/var/log/deliver/tomcat.log'
set :wait_tomcat, 20 # tomcat終了停止待機retry回数

##
## Logging
##
# set :format, :pretty
# set :log_level, :debug
set :log_level, :info
# set :pty, true

##
## Other
##
# set :default_env, { path: "/opt/ruby/bin:$PATH" }
# set :keep_releases, 5
set :keep_releases, 3

namespace :deploy do
  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      # execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end
  after :finishing, 'deploy:cleanup'
end
