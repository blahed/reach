require 'etc'

require 'sshkit'
require 'colorize'
require 'airbrussh'

require 'reach/config'
require 'reach/dsl'
require 'reach/errors'
require 'reach/version'

require 'sshkit/formatters/reach'

module Reach
  class Host < ::SSHKit::Host; end

  def self.helpers(*extensions, &block)
    extensions.each { |m| SSHKit::Backend::Abstract.send(:include, m) }
    SSHKit::Backend::Abstract.class_eval(&block) if block_given?
  end
end

require 'reach/extensions/base'