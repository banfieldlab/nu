require 'logger'

module Nu
  class Logger < ::Logger
    @@log = nil

    def self.get
      if not @@log
        @@log = self.new(STDOUT)
        @@log.level = Nu::Logger::DEBUG
      end
      @@log
    end # end Logger.get

    def self.log=(log)
      @@log = log
    end # end Logger set

    def level(new_level)
      get if not @@log
      case new_level
      when "WARN"
        @@log.level = Nu::Logger::WARN
      when "INFO"
        @@log.level = Nu::Logger::INFO
      when "DEBUG"
        @@log.level = Nu::Logger::DEBUG
      when "ERROR"
        @@log.level = Nu::Logger::ERROR
      when "FATAL"
        @@log.level = Nu::Logger::FATAL
      when "UNKNOWN"
        @@log.level = Nu::Logger::UNKNOWN
      end
    end

  end # end Nu::Logger class

  # mixin to add logging to any class
  module Loggable
    def debug(msg)
      Nu::Logger.get.debug(msg)
    end

    def info(msg)
      Nu::Logger.get.info(msg)
    end
    def warn(msg)
      Nu::Logger.get.warn(msg)
    end
    def error(msg)
      Nu::Logger.get.error(msg)
    end
    def fatal(msg)
      Nu::Logger.get.fatal(msg)
    end
    def unknown(msg)
      Nu::Logger.get.unknown(msg)
    end
  end # end Nu::Logger::Loggable module
end # end Nu module
