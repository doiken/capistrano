namespace :s3 do

  def strategy
    @strategy ||= Capistrano::S3.new(self, fetch(:s3_strategy, Capistrano::S3::DefaultStrategy))
  end

  def get_tmp_dir
    "#{fetch(:tmp_dir)}/#{fetch(:application)}/"
  end

  desc 'Check that the repository is reachable'
  task :check do
    run_locally do
      execute :mkdir, '-p', get_tmp_dir()
      within "#{fetch(:tmp_dir)}/#{fetch(:application)}/" do
        exit 1 unless strategy.check
      end
    end
  end

  desc 'Clone the repo to the cache'
  task :clone do
    run_locally do
      execute :mkdir, '-p', get_tmp_dir()
      within "#{fetch(:tmp_dir)}/#{fetch(:application)}/" do
        strategy.clone
      end
    end
  end

  desc 'Update the repo mirror to reflect the origin state'
  task update: :'s3:clone' do
    run_locally do
      execute :mkdir, '-p', get_tmp_dir()
      within "#{fetch(:tmp_dir)}/#{fetch(:application)}/" do
        strategy.update
      end
    end
  end

  desc 'Copy repo to releases'
  task create_release: :'s3:update' do
    invoke 's3:upload'
    invoke 's3:extract'
  end

  task :upload do
    on release_roles :all do
      within get_tmp_dir() do
        execute :mkdir, '-p', release_path
        strategy.upload
      end
    end
  end

  task :extract do
    on release_roles :all do
      within get_tmp_dir() do
        strategy.extract
      end
    end
  end
end

