module SSHKit
  module Formatter
    class Reach < SSHKit::Formatter::Pretty

      def write_command(command)
        unless command.started?
          if SSHKit.config.output_verbosity == Logger::DEBUG
            original_output << level(command.verbosity) + uuid(command) + "Running #{c.yellow(c.bold(String(command)))} on #{c.blue(command.host.to_s)}\n"
            original_output << level(Logger::DEBUG) + uuid(command) + "Command: #{c.blue(command.to_command)}\n"
          else
            original_output << "#{c.yellow('>')} #{String(command)} "
          end
        end

        if SSHKit.config.output_verbosity == Logger::DEBUG
          unless command.stdout.empty?
            command.stdout.lines.each do |line|
              original_output << level(Logger::DEBUG) + uuid(command) + c.green("\t" + line)
              original_output << "\n" unless line[-1] == "\n"
            end
          end

          unless command.stderr.empty?
            command.stderr.lines.each do |line|
              original_output << level(Logger::DEBUG) + uuid(command) + c.red("\t" + line)
              original_output << "\n" unless line[-1] == "\n"
            end
          end
        end

        if command.finished?
          if SSHKit.config.output_verbosity == Logger::DEBUG
            original_output << level(command.verbosity) + uuid(command) + "Finished in #{sprintf('%5.3f seconds', command.runtime)} with exit status #{command.exit_status} (#{c.bold { command.failure? ? c.red('failed') : c.green('successful') }}).\n"
          else
            original_output << "#{c.yellow(sprintf('%5.3fs', command.runtime))} "
            original_output << c.red("failed (#{command.exit_status})") if command.failure?
            original_output << "\n"
          end
        end
      end

    end
  end
end