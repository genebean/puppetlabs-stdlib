# frozen_string_literal: true

#  Please note: This function is an implementation of a Ruby class and as such may not be entirely UTF8 compatible.
#  To ensure compatibility please use this function with Ruby 2.4.0 or greater - https://bugs.ruby-lang.org/issues/10085.
#
Puppet::Parser::Functions.newfunction(
  :pw_hash,
  type: :rvalue,
  arity: 3,
  doc: <<-DOC,
  @summary
    Hashes a password using the crypt function. Provides a hash usable
    on most POSIX systems.

  The first argument to this function is the password to hash. If it is
  undef or an empty string, this function returns undef.

  The second argument to this function is which type of hash to use. It
  will be converted into the appropriate crypt(3) hash specifier. Valid
  hash types are:

  |Hash type            |Specifier|
  |---------------------|---------|
  |MD5                  |1        |
  |SHA-256              |5        |
  |SHA-512 (recommended)|6        |

  The third argument to this function is the salt to use.

  @return [Hash]
    Provides a hash usable on most POSIX systems.

  > *Note:*: this uses the Puppet Server's implementation of crypt(3). If your
    environment contains several different operating systems, ensure that they
    are compatible before using this function.
  DOC
) do |args|
  raise ArgumentError, "pw_hash(): wrong number of arguments (#{args.size} for 3)" if args.size != 3
  args.map! do |arg|
    if (defined? Puppet::Pops::Types::PSensitiveType::Sensitive) && (arg.is_a? Puppet::Pops::Types::PSensitiveType::Sensitive)
      arg.unwrap
    else
      arg
    end
  end
  raise ArgumentError, 'pw_hash(): first argument must be a string' unless args[0].is_a?(String) || args[0].nil?
  raise ArgumentError, 'pw_hash(): second argument must be a string' unless args[1].is_a? String
  hashes = { 'md5'     => '1',
             'sha-256' => '5',
             'sha-512' => '6' }
  hash_type = hashes[args[1].downcase]
  raise ArgumentError, "pw_hash(): #{args[1]} is not a valid hash type" if hash_type.nil?
  raise ArgumentError, 'pw_hash(): third argument must be a string' unless args[2].is_a? String
  raise ArgumentError, 'pw_hash(): third argument must not be empty' if args[2].empty?
  raise ArgumentError, 'pw_hash(): characters in salt must be in the set [a-zA-Z0-9./]' unless %r{\A[a-zA-Z0-9./]+\z}.match?(args[2])

  password = args[0]
  return nil if password.nil? || password.empty?

  salt = "$#{hash_type}$#{args[2]}"

  # handle weak implementations of String#crypt
  # dup the string to get rid of frozen status for testing
  if ('test'.dup).crypt('$1$1') != '$1$1$Bp8CU9Oujr9SSEw53WV6G.'
    # JRuby < 1.7.17
    # MS Windows and other systems that don't support enhanced salts
    raise Puppet::ParseError, 'system does not support enhanced salts' unless RUBY_PLATFORM == 'java'
    # puppetserver bundles Apache Commons Codec
    org.apache.commons.codec.digest.Crypt.crypt(password.to_java_bytes, salt)
  else
    password.crypt(salt)
  end
end
