module Reach
  module Extension
    module Git
      GIT_TIMESTAMP_FORMAT = "%Y%m%d%H%M%S".freeze
      GIT_MESSAGE_FORMAT   = "%a, %b %d %-l:%M %p".freeze
      GIT_TAG_REGEX        = /\A[0-9]{14}-[0-9a-z]{7}/.freeze

      def clone
        requires_setting :deploy_to, :repo_url

        if test("[ -d #{fetch(:deploy_to)} ]")
          comment "Something is already deployed to #{fetch(:deploy_to)}", :yellow

          false
        else
          execute :mkdir, '-p', fetch(:deploy_to)

          within fetch(:deploy_to) do
            execute :git, 'clone', fetch(:repo_url), '.'
            execute :git, 'reset', '--hard', "origin/#{fetch(:branch, :master)}"
          end

          true
        end
      end

      def deploy
        requires_setting :deploy_to

        head = local_head

        within fetch(:deploy_to) do
          execute :git, 'fetch'
        end

        _origin_head = origin_head

        if head == _origin_head
          comment "#{_origin_head} has already been deployed", :yellow

          false
        else
          within fetch(:deploy_to) do
            execute :git, 'reset', '--hard', "origin/#{fetch(:branch, :master)}"
          end

          create_tag
          comment "HEAD is now at #{_origin_head}"

          true
        end
      end

      def rollback
        requires_setting :deploy_to

        _current_tag = current_tag

        if _current_tag.nil?
          comment "No previous tags to rollback to", :yellow

          false
        else
          within fetch(:deploy_to) do
            execute :git, 'tag', '-d', _current_tag
            # current is now previous
            execute :git, 'reset', '--hard', current_tag
          end

          comment "HEAD is now at #{git_head}"

          true
        end
      end

      def git_log
        requires_setting :deploy_to

        within fetch(:deploy_to) do
          puts capture(:git, 'log')
        end
      end

      def deploy_history
        requires_setting :deploy_to

        within fetch(:deploy_to) do
          puts capture(:git, 'tag', '-l', '-n1').strip.split("\n").select { |t| t =~ GIT_TAG_REGEX }
        end
      end

      def file_has_changes?(path)
        requires_setting :deploy_to

        exit_code("cd #{fetch(:deploy_to)} && git diff --exit-code #{current_tag} origin/#{fetch(:branch, :master)} #{path}") == 1
      end

      def files_have_changes?(paths)
        requires_setting :deploy_to

        paths.map { |p| file_has_changes?(p) }.any?
      end

      def create_tag
        within fetch(:deploy_to) do
          current_head = capture(:git, 'rev-parse', '--short', 'HEAD').strip
          now          = Time.now
          tag          = "#{now.strftime(GIT_TIMESTAMP_FORMAT)}-#{current_head}"
          message      = "\"#{local_user} deployed #{current_head} at #{now.strftime(GIT_MESSAGE_FORMAT)}\""

          execute :git, 'tag', tag, '-m', message
        end
      end

      def local_head
        within fetch(:deploy_to) do
          capture(:git, 'rev-parse', '--short', 'HEAD').strip
        end
      end

      def origin_head
        within fetch(:deploy_to) do
          capture(:git, 'ls-remote', 'origin', '-h', "\"refs/heads/#{fetch(:branch, :master)}\"").strip[0..6]
        end
      end

      def current_tag
        within fetch(:deploy_to) do
          capture(:git, 'tag').strip.split.select { |t| t =~ GIT_TAG_REGEX }.first
        end
      end
    end
  end

  helpers Extension::Git
end
