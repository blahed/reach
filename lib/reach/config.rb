module Reach
  module Config
    extend self

    attr_accessor :group, :task

    def settings
      @settings ||= {
        pty: false,
        default_env: {},
        format: :reach,
        log_level: :info,
        sshkit_backend: SSHKit::Backend::Netssh,
        sshkit_output: SSHKit.config.output = Airbrussh::Formatter.new($stdout)
      }
    end

    def grouped_settings
      @grouped_settings ||= {}
    end

    def tasks
      @tasks ||= {}
    end

    def args
      @args ||= ARGV.dup
    end

    def callbacks
      @callbacks ||= {}
    end

    def setup
      grouped_settings[group].call if group

      SSHKit.configure do |sshkit|
        sshkit.output           = fetch(:sshkit_output)
        sshkit.output_verbosity = fetch(:log_level)
        sshkit.default_env      = fetch(:default_env)
        sshkit.backend          = fetch(:sshkit_backend)
        sshkit.backend.configure do |backend|
          backend.pty                = fetch(:pty)
          backend.connection_timeout = fetch(:connection_timeout)
          backend.ssh_options        = fetch(:ssh_options) if fetch(:ssh_options)
        end
      end
    end

    def set(name, value)
      settings[name.to_sym] = value
    end

    def fetch(name, default=nil)
      settings.fetch(name.to_sym, default)
    end

    module Accessors
      def args
        ::Reach::Config.args
      end

      def set(*args)
        ::Reach::Config.set(*args)
      end

      def fetch(*args)
        ::Reach::Config.fetch(*args)
      end
    end
  end
end