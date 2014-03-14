require File.expand_path(File.dirname(__FILE__) + '/base_service.rb')
class Adserver < BaseService
  # Prepare Shell Script
  def prepare_shell!
    as 'root' do
      execute :chmod, 'u+x', "#{release_path}/tool/warming_up/*"
      execute :cp, "#{release_path}/{bin/env_*,deliver/bin/}"
    end
  end

  # Wait Until Request Stop
  def maintenance_enable!
    as 'root' do
      # 結果は取得しないが終了ステータスを無視するためにtestを利用
      test :touch, fetch(:maintenance_path)
    end

    # リクエストの確認
    last_modified_before = _get_last_modified
    sleep(1)
    while (last_modified_after = _get_last_modified) != last_modified_before do
      info 'adserver_log Seems to Be Updated. Retry in a Sec...'
      last_modified_before = last_modified_after
      sleep(1)
    end
  end

  # Kick Build Script
  def build!
    with classpath: fetch(:classpath) do
      within "#{release_path}/deliver" do
        execute :ant, "-Denv=#{fetch(:stage)}"
      end
    end
  end

  # Wait Until Tomcat Stop
  def stop_webserver!
    # Kick Stop Command
    as 'root' do
      execute '/etc/init.d/httpd', 'stop'
      execute '/etc/init.d/tomcat6', 'stop'
    end

    # stopしても、contextDestroyに失敗しているケースがあるため、
    # 監視し必要に応じてkill
    if _is_tomcat_survive?()
      debug 'Tomcat is Active'
      _wait_context_destroyed()

      p _is_tomcat_survive?()
      if _is_tomcat_survive?() > 0
        info "Current Tomcat Process ID is ##{_get_tomcat_process_id()}"
        info "Killing Process..."
        _kill_tomcat!()
        sleep(2)
        info "Current Tomcat Process ID is ##{_get_tomcat_process_id()}"
      end
    else
      debug 'Tomcat is Not Active'
    end
  end

  def remove_server_cache_files!
    #@todo 汎用的にすべきだが, パラメータの切り分けをどうするか...
    as 'root' do
      execute :rm, '-f',  '/usr/share/tomcat6/conf/Catalina/localhost/ROOT.xml'
      execute :rm, '-rf', '/usr/share/tomcat6/webapps/ROOT'
      execute :rm, '-rf', '/usr/share/tomcat6/webapps/ROOT2'
    end
  end

  def service_start!
    sleep 5
    as 'root' do
      execute :svc, '-d', '/services/kumo-gateway'
      execute :svc, '-u', '/services/kumo-gateway'
      execute '/etc/init.d/tomcat6', 'start'
    end
    sleep 5
  end

  def check_if_service_available?
    test :wget, 'http://localhost:8080/sm/?cmd=rev', '-T 90', '-O -'
  end

  private

  # Get Last Modified Time
  def _get_last_modified
    # (日/月/年またぎを想定して*で取得)
    get_last_modified_cmd = [
        :ls, '-lt', '--time-style=+%s', '/spacyz/var/log/adserver_log.*', '|',
        :head, '-n', 1, '|',
        :awk, "'{print $6}'"
    ]
    capture(*get_last_modified_cmd)
  end

  def _kill_tomcat!
    as 'root' do
      # 実行タイミングにより失敗を防ぐため、test実行
      test :kill, 'pgrep -f org.apache.catalina.startup.Bootstrap'
    end
  end

  def _get_tomcat_process_id
    capture_ignore_status(:pgrep, '-fl', 'org.apache.catalina.startup.Bootstrap')
  end

  # tomcatの停止をできるだけ待ってみる
  #
  #
  def _wait_context_destroyed
    loop = 0
    loop_limit = fetch(:wait_tomcat)
    while loop < loop_limit do
      if _is_context_destroyed?() then
        break
      end
      loop += 1
      info 'Waiting To Stop Tomcat. Retrying ...'
      sleep(3)
    end
  end

  def _is_context_destroyed?
    tail_cmd = [
        :tail, '-n', '100', fetch(:tomcat_log_path), '|',
        :grep, "'<---- contextDestroyed'", '|',
        :wc, '-l'
    ]

    capture(*tail_cmd).to_i >= 1
  end

  def _is_tomcat_survive?
    # pgrep自身のhitを避けるため[o]
    cmd_get_tomcat_cnt = [
        :pgrep, '-lf', "'[o]rg.apache.catalina.startup.Bootstrap'", '|',
        :wc, '-l'
    ]
    capture(*cmd_get_tomcat_cnt).to_i > 0
  end

end
