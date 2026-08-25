# Compatibility shim for Liquid 4.0.x on newer Ruby runtimes.
# Ruby 4 removed the old tainted? behavior, but Liquid still expects it.
# This keeps the site buildable without changing the theme code.
unless Object.method_defined?(:tainted?)
  class Object
    def tainted?
      false
    end
  end
end
