module FieldSanitizer
  extend ActiveSupport::Concern

  ALPHANUM_REGEX = /\A[[:alnum:]\s]+\S\z/

  class_methods do
    # Strip all whitespace, and convert multiple consecutive whitespaces into
    # a single space.
    #
    def sanitize_method(method_name)
      define_method("#{method_name}=") do |value|
        super(value.strip.gsub(/[[:space:]]+/, " "))
      end
    end
  end
end
