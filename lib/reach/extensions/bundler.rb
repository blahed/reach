require 'reach/extensions/git'

module Reach
  module Extension
    module Bundler

      def bundle_install(force = false)
        requires_setting :deploy_to

        bundle_without = fetch(:bundle_without, 'development:test')
        bundle_args    = ['--deployment', '--without', bundle_without]
        bundle_args   += ['--path', fetch(:bundle_path)] if fetch(:bundle_path)

        if force || files_have_changes?(%w[Gemfile Gemfile.lock])
          within fetch(:deploy_to) do
            execute :bundle, 'install', *bundle_args
          end

          true
        else
          false
        end
      end

      def bundle_install!
        bundle_install(force = true)
      end

    end
  end

  helpers Extension::Bundler
end
