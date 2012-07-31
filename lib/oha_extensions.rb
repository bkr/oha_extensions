require "oha_extensions/version"
require "oha_extensions/hash_extension"
require "oha_extensions/object_extension"
require "oha_extensions/array_extension"

class Array
  include ArrayExtension
end

class Hash
  include HashExtension
end

class Object
  include ObjectExtension
end

