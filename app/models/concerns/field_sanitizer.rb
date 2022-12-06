module FieldSanitizer
  extend ActiveSupport::Concern

  ALPHANUM_REGEX = /\A[[:alnum:]\s]+\S\z/

  class_methods do
    # Strip all whitespace, and convert multiple consecutive whitespaces into
    # a single space.
    #
    def autostrip(method_name)
      define_method("#{method_name}=") do |value|
        super(value&.strip&.gsub(/[[:space:]]+/, " "))
      end
    end

    # Validate that only alphanumeric characters (and whitespace) are used in
    # the field, and that there is no trailing whitespace.
    #
    def validate_alphanum(method_name)
      validates method_name,
        :format     => {
          :with    => ALPHANUM_REGEX,
          :message => "only alphanumeric characters and spaces allowed"
      }
    end

    # Strip whitespace and then validate the value.
    #
    def autostrip_and_validate(method_name)
      autostrip(method_name)
      validate_alphanum(method_name)
    end
  end
end
