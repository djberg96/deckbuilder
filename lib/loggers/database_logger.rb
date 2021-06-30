module Loggers
  class DatabaseLogger < ActiveSupport::Logger
    # Set logdev to nil to prevent it from writing to a file.
    def initialize(logdev = nil, *args)
      super(logdev, *args)
    end

    # Redefine the add method from the core Logger class so that it
    # writes to the database.
    #
    def add(severity, message = nil, _progname = nil, &block)
      severity ||= UNKNOWN

      if message.nil? && block_given?
        message = yield
      end

      return unless message

      # Prevent the Log.create call from logging itself, which
      # otherwise causes an infinite loop.
      silence do
        ::Log.create(
          :message   => message.strip,
          :severity  => map(severity),
          :timestamp => Time.now,
        )
      end
    end

    def map(severity)
      case severity
        when DEBUG
          "DEBUG"
        when INFO
          "INFO"
        when WARN
          "WARN"
        when ERROR
          "ERROR"
        when FATAL
          "FATAL"
        else
          "UNKNOWN"
      end
    end
  end
end
