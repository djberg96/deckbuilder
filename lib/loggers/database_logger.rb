module Loggers
  class DatabaseLogger < ActiveSupport::Logger
    # Set logdev to nil to prevent it from writing to a file.
    def initialize(logdev = nil, *args)
      super(logdev, *args)
    end

    # Redefine the add method from the core Logger class so that it
    # writes to the database.
    #
    def add(severity, message = nil, _progname = nil)
      severity ||= UNKNOWN
      return true if severity < @level

      ::Log.create(
        :message   => message,
        :severity  => severity,
        :timestamp => Time.now,
      )
    end
  end
end