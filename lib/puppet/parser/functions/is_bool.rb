# frozen_string_literal: true

#
# is_bool.rb
#
module Puppet::Parser::Functions
  newfunction(:is_bool, type: :rvalue, doc: <<-DOC
    @summary
      **Deprecated:** Returns true if the variable passed to this function is a boolean.

    @return [Boolean]
      Returns `true` or `false`

    > **Note:* **Deprecated** Will be removed in a future version of stdlib. See
    [`validate_legacy`](#validate_legacy).
    DOC
  ) do |arguments|
    function_deprecation([:is_bool, 'This method is deprecated, please use the stdlib validate_legacy function,
                          with Stdlib::Compat::Bool. There is further documentation for validate_legacy function in the README.'])

    raise(Puppet::ParseError, "is_bool(): Wrong number of arguments given (#{arguments.size} for 1)") if arguments.size != 1

    type = arguments[0]

    result = type.is_a?(TrueClass) || type.is_a?(FalseClass)

    return result
  end
end
