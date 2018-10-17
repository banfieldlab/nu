require 'logger'

module MgNu
  class Logger < ::Logger
    @@log = nil

    def self.get
      if not @@log
        @@log = self.new(STDOUT)
        @@log.level = MgNu::Logger::DEBUG
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
        @@log.level = MgNu::Logger::WARN
      when "INFO"
        @@log.level = MgNu::Logger::INFO
      when "DEBUG"
        @@log.level = MgNu::Logger::DEBUG
      when "ERROR"
        @@log.level = MgNu::Logger::ERROR
      when "FATAL"
        @@log.level = MgNu::Logger::FATAL
      when "UNKNOWN"
        @@log.level = MgNu::Logger::UNKNOWN
      end
    end

  end # end MgNu::Logger class

  # mixin to add logging to any class
  module Loggable
    def debug(msg)
      MgNu::Logger.get.debug(msg)
    end

    def info(msg)
      MgNu::Logger.get.info(msg)
    end
    def warn(msg)
      MgNu::Logger.get.warn(msg)
    end
    def error(msg)
      MgNu::Logger.get.error(msg)
    end
    def fatal(msg)
      MgNu::Logger.get.fatal(msg)
    end
    def unknown(msg)
      MgNu::Logger.get.unknown(msg)
    end
  end # end MgNu::Logger::Loggable module
end # end MgNu module
