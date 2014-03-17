# 主にtask系関数の依存関係(context)を吸収する関数を実装
class BaseService
  attr_reader :context

  # Fetch Var From Context
  def fetch(*args)
    context.fetch(*args)
  end

  # Execute from the Context
  def execute(*args)
    context.execute *args
  end

  # Execute from the Context
  def test(*args)
    context.test *args
  end

  # Capture from the Context
  def capture(*args)
    context.capture *args
  end

  def initialize(context)
    @context = context
  end

  def as(who, &block)
    context.as(who, &block)
  end

  def within(directory, &block)
    context.within(directory, &block)
  end

  def with(environment, &block)
    context.with(environment, &block)
  end

  # The release path accoriding to the context
  def release_path
    context.release_path
  end

  def info(msg)
    context.info msg
  end

  def debug(msg)
    context.debug msg
  end
end
