require 'reach/extensions/git'

module Reach
  module Extension
    module Yarn

      def yarn_install(force = false)
        requires_setting :deploy_to

        if force || files_have_changes?(%w[package.json yarn.lock])
          within fetch(:deploy_to) do
            execute :yarn, 'install', '--production'
          end

          true
        else
          false
        end
      end

      def yarn_install!
        yarn_install(force = true)
      end

    end
  end

  helpers Extension::Yarn
end
