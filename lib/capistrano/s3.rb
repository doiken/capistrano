load File.expand_path('../tasks/s3.rake', __FILE__)

require 'capistrano/scm'

class Capistrano::S3 < Capistrano::SCM

  # execute s3 with argument in the context
  def s3(*args)
    context.execute *args
  end

  def get_tmp_dir()
    "#{fetch(:tmp_dir)}/#{fetch(:application)}/"
  end

  def get_cache_path()
    File.basename(fetch(:bucket_path), '.*') + '.cache'
  end

  def get_s3url
    "s3://#{fetch(:bucket_path)}"
  end

  # The Capistrano default strategy for s3.
  module DefaultStrategy
    def check
      # 都度s3cmd lsするのは高コストのため割愛
      true

      #s3cmd = sprintf('"`s3cmd ls %s`"', get_s3url)
      #test! "test -n #{s3cmd}"
    end

    def update
      s3 :s3cmd, 'get', '--force', get_s3url()
    end

    def upload
      tmp_dir     = get_tmp_dir()
      upload_from = "#{tmp_dir}#{File.basename(fetch(:bucket_path))}"
      context.upload! upload_from, tmp_dir, recursive: true
    end

    def extract
      case fetch(:archive_type)
        when :tar then extract_tar!(File.basename(fetch(:bucket_path)), release_path)
        when :zip then extract_zip!(File.basename(fetch(:bucket_path)), release_path)
        when :raw then extract_raw!(File.basename(fetch(:bucket_path)), release_path)
        else
          raise RuntimeError.new("Set Invalid :archive_type #{fetch(:archive_type)}")
      end
    end

    def extract_tar!(from, to)
      s3 :tar, 'xzf', from, '-C', to, "--strip-components=#{fetch(:tar_strip, 0)}"
    end

    def extract_zip!(from, to)
      #@Todo
    end

    def extract_raw!(from, to)
      s3 :mv, from, to
    end
  end
end
