namespace :s3 do

  def strategy
    @strategy ||= Capistrano::S3.new(self, fetch(:s3_strategy, Capistrano::S3::DefaultStrategy))
  end

  def get_tmp_dir
    "#{fetch(:tmp_dir)}/#{fetch(:application)}/"
  end

  desc 'Check If S3 is Available'
  task :check do
    run_locally do
      execute :mkdir, '-p', get_tmp_dir()
      within "#{fetch(:tmp_dir)}/#{fetch(:application)}/" do
        exit 1 unless strategy.check
      end
    end
  end

  desc 'Update Package From S3'
  task :update do
    next if ENV['SKIP_UPDATE']
    run_locally do
      execute :mkdir, '-p', get_tmp_dir()
      within "#{fetch(:tmp_dir)}/#{fetch(:application)}/" do
        strategy.update
      end
    end
  end

  desc 'Invoke Upload & Extract Tasks'
  task create_release: :'s3:update' do
    invoke 's3:upload'
    invoke 's3:extract'
  end

  desc 'Upload Package'
  task :upload do
    on release_roles :all do
      within get_tmp_dir() do
        execute :mkdir, '-p', release_path
        strategy.upload
      end
    end
  end

  desc 'Extract Package'
  task :extract do
    on release_roles :all do
      within get_tmp_dir() do
        strategy.extract
      end
    end
  end
end

