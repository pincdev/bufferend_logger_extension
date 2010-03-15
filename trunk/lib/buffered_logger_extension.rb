module ActiveSupport
  # Used for rails 2.0
  class BufferedLogger
    module Severity
      #@@levels = {0 => 'DEBUG', 1 => 'INFO', 2 => 'WARN', 3 => 'ERROR', 4 => 'FATAL', 5 => 'UNKNOWN'}
      def level_to_s(level)
        #@@levels[level]
        case level
        when 0 then 'DEBUG'
        when 1 then 'INFO'
        when 2 then 'WARN'
        when 3 then 'ERROR'
        when 4 then 'FATAL'
        when 5 then 'UNKNOWN'
        end
      end
    end
    
    GLOBAL_INFO_STRING = "'   Globals:\n' + global_variables.collect{|g| '       ' + g + ': ' + (eval g).inspect}.join('\n')"
    LOCAL_INFO_STRING = "'   Locals:\n' + local_variables.collect{|l|  '      ' + l + ': ' + (eval l).inspect}.join('\n')"
    FULL_INFO_STRING = GLOBAL_INFO_STRING + '\n' + LOCAL_INFO_STRING

    def debug_with_locals(msg, caller_binding)
      debug(msg + "\n" + eval(LOCAL_INFO_STRING, caller_binding))
    end

    def error_with_locals(msg, caller_binding)
      error(msg + "\n" + eval(LOCAL_INFO_STRING, caller_binding))
    end

    def format_message(severity, timestamp, progname, msg)
      pattern = /^#{Rails.root}\/[^v]/
      location = (Kernel.caller.detect{|c| c.match(pattern)} || '').split("/")[-1]
      stack = (severity > 1 && severity < 4) ? Kernel.caller(3).collect{|c| "   " + c}.join("\n") + "\n" : ''
      "[#{timestamp.strftime("%Y-%m-%d %H:%M:%S %Z")}] #{level_to_s(severity)} #{location} #{msg}#{stack}"
    end
    
    def add(severity, message = nil, progname = nil, &block)
      return if @level > severity
      message = (message || (block && block.call) || progname).to_s
      # If a newline is necessary then create a new message ending with a newline.
      # Ensures that the original message is not mutated.
      message = "#{message}\n" unless message[-1] == ?\n
      buffer << format_message(severity, Time.now, progname, message)
      auto_flush
      message
    end
  end
end

class Logger
  def format_message(severity, timestamp, progname, msg)
    "[#{timestamp.strftime("%Y-%m-%d %H:%M:%S %Z")}] #{severity}  #{msg}\n"  
  end
end
