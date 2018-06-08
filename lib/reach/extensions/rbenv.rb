module Reach
  module Extension
    module Rbenv
      def rbenv_init
        requires_setting :rbenv_path

        execute 'eval "$(rbenv init -)"'
      end
    end
  end

  helpers Extension::Rbenv
end
