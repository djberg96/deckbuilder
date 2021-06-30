module Loggers
  class DatabaseLogger < ActiveSupport::Logger
    # Set logdev to nil to prevent it from writing to a file.
    def initialize(logdev = nil, *args)
      super(logdev, *args)
      @regex = /(.*?)(\(.*?\))/
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
      parts = parse_message(message)

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

    def parse_message(msg)
      match = @regex.match(msg)
      captures = match.captures
      main_message = captures.first.strip
      message_info = m.captures.last.split("|").map{ |e| e.tr("()", "").strip.split(":").map(&:strip) }.to_h
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
