module FieldSanitizer
  extend ActiveSupport::Concern

  # Only POSIX alphanumeric characters, with no leading or trailing spaces.
  # I'll also allow hyphens, parens, spaces and pound signs.
  ALPHANUM_REGEX = /\A[[:alnum:]\s\-\(\)\#]+\S\z/

  included do
    # Strip string and squish to remove excess inline whitespace.
    string_columns = self.columns_hash.select { |_k, v| v.type == :string }.keys
    auto_strip_attributes(*string_columns, squish: true)

    # Strip text without squishing to allow multiple newlines in-between lines.
    text_columns = self.columns_hash.select { |_k, v| v.type == :text }.keys
    auto_strip_attributes(*text_columns, squish: false)

    validates *string_columns,
      :format => {
        :with    => ALPHANUM_REGEX,
        :message => "only alphanumeric characters and spaces allowed"
      }
  end
end
