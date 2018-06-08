module Reach
  class DSL
    extend Config::Accessors

    def self.helpers(*extensions, &block)
      Reach.helpers(*extensions, &block)
    end

    def self.before(&callback)
      Config.callbacks[:before] = callback
    end

    def self.after(&callback)
      Config.callbacks[:after] = callback
    end

    def self.hosts
      Array(fetch(:host) || fetch(:hosts)).map { |host|
        host.is_a?(Host) ? host : host.to_s
      }
    end

    def self.configure(group, &block)
      Config.grouped_settings[group.to_sym] = block
    end
    self.singleton_class.send(:alias_method, :config, :configure)

    def self.reach(task, options = {}, &block)
      default_options      = { in: :sequence }
      Config.tasks[task] ||= {}
      Config.tasks[task][:block]   = block
      Config.tasks[task][:options] = default_options.merge(options)
    end

    def self.start
      pre
      SSHKit::Coordinator.new(hosts).each(Config.tasks[task][:options]) do |host|
        # instance_eval(&::Reach::DSL.before) unless ::Reach::DSL.before.nil?
        instance_eval(&::Reach::Config.tasks[::Reach::DSL.task][:block])
        # instance_eval(&::Reach::DSL.after) unless ::Reach::DSL.after.nil?
      end
      post
    rescue Errors::ReachError => e
      exit_with_message!(e.message)
    rescue SSHKit::Runner::ExecuteError => e
      if e.cause.class < Errors::ReachError
        exit_with_message!(e.cause.message)
      else
        raise e
      end
    end

    def self.group
      Config.group
    end

    def self.task
      Config.task
    end

    private

    def self.exit_with_message!(message = nil)
      puts "\e[031m#{message}\e[0m" if message
      exit 1
    end

    def self.task_exists?
      Config.tasks.has_key?(task)
    end

    def self.pre
      parse_arguments
      Config.setup
      @start_time = Time.now
      puts "Reaching out to \e[32m#{hosts.join(',')}\033[0m\n"
      puts "Using #{group} configuration" if group
    end

    def self.parse_arguments
      Config.group = args.shift.to_sym if Config.grouped_settings.keys.include?(args.first.to_sym)
      Config.task  = args.shift.to_sym
      set(:sshkit_backend, ::SSHKit::Backend::Printer) if args.delete('--dry-run') || args.delete('-n')

      validate_arguments
    end

    def self.validate_arguments
      raise Errors::InvalidTask, "The task `#{task}' hasn't been configured" unless task_exists?
      raise Errors::InvalidHosts, "You must set at least one host using `set :host, HOSTNAME'" if hosts.nil?
    end

    def self.post
      elapsed = Time.now - @start_time
      minutes = ((elapsed % 3600) / 60).to_i
      seconds = ((elapsed % 3600) % 60).to_i

      puts "\n\e[32mCompleted in #{minutes} min #{seconds} sec\e[0m"
    end

  end
end
