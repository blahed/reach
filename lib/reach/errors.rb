module Reach
  module Errors
    class ReachError < StandardError; end
    class InvalidHosts < ReachError; end
    class InvalidGroup < ReachError; end
    class MissingSetting < ReachError; end
    class InvalidTask < ReachError; end
  end
end