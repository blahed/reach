require 'reach/extensions/bundler'
require 'reach/extensions/git'

module Reach
  module Extension
    module Rails
      def precompile_assets(force = false)
        requires_setting :deploy_to

        if force || assets_changed?
          with rails_env: fetch(:rails_env, :production) do
            within fetch(:deploy_to) do
              execute :'bin/rake', 'assets:precompile'
            end
          end

          true
        else
          false
        end
      end

      def migrate
        with rails_env: fetch(:rails_env, :production) do
          within fetch(:deploy_to) do
            execute :'bin/rake', 'db:migrate'
          end
        end

        true
      end

      def precompile_assets!
        precompile_assets(force = true)
      end

      def clean_assets
        requires_setting :deploy_to

        with rails_env: fetch(:rails_env, :production) do
          within fetch(:deploy_to) do
            execute :'bin/rake', 'assets:clean'
          end
        end

        true
      end

      def assets_changed?
        @assets_changed ||= begin
          watched_paths = %w[app/assets lib/assets Gemfile Gemfile.lock]
          watched_paths += fetch(:watched_asset_paths, [])

          files_have_changes?(watched_paths)
        end
      end

    end
  end

  helpers Extension::Rails
end
