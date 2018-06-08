module Reach
  module Extension
    module Base
      include Reach::Config::Accessors

      def local_user
        Etc.getlogin
      end

      def comment(message, color = :light_black)
        puts "# #{message}".colorize(color)
      end

      def ensure_directories(paths)
        paths = [paths] unless paths.is_a?(Array)

        execute :mkdir, "-p #{paths.join(' ')}" unless paths.empty?
      end

      def ensure_files(paths)
        paths = [paths] unless paths.is_a?(Array)

        execute :touch, "#{paths.join(' ')}" unless paths.empty?
      end

      def sym_link(links)
        links.each do |current_path, new_path|
          run "ln -sf #{current_path} #{new_path}"
        end
      end

      def exited_clean?(command)
        exit_code(command) == 0
      end

      def exit_code(command)
        capture("#{command} > /dev/null 2>&1; echo $?").to_i
      end

      private

      def requires_setting(*settings)
        missing = settings.select { |s| fetch(s.to_sym).nil? }
        command = caller[0][/`([^']*)'/, 1]

        raise ::Reach::Errors::MissingSetting, "`#{command}' requires #{missing.join(',')} to be set" unless missing.empty?
      end
    end
  end

  helpers Extension::Base
end