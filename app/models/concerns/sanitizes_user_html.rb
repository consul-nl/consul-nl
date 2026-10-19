# Schoont door inwoners ingevoerde HTML op bij het opslaan, met dezelfde lijst
# toegestane opmaak als bij het tonen (WYSIWYGSanitizer). Zo komt er nooit ruwe
# HTML van een inwoner in de CKEditor van een beheerder terecht.
#
# Velden die beheerders invullen vallen hier bewust buiten; die gebruiken
# AdminWYSIWYGSanitizer.
#
# Standaard met WYSIWYGSanitizer. Een veld dat bij het tonen al met
# AdminWYSIWYGSanitizer wordt gefilterd (zoals Poll#description), geef je
# dezelfde sanitizer mee: sanitizes_user_html :description, sanitizer: AdminWYSIWYGSanitizer
#
# Let op: dit draait in before_validation en before_save. Routes die callbacks
# overslaan (update_column, update_all, insert_all, Globalize set_translations)
# worden NIET opgeschoond; gebruik die niet voor inwonersinhoud.
module SanitizesUserHtml
  extend ActiveSupport::Concern

  included do
    class_attribute :user_html_fields, instance_writer: false, default: []
    class_attribute :user_html_sanitizer, instance_writer: false, default: WYSIWYGSanitizer
    # Twee keer: voor validatie (zodat validaties de opgeschoonde tekst zien) en voor het
    # opslaan (zodat ook save(validate: false) wordt afgedekt). Opschonen is idempotent.
    before_validation :sanitize_user_html
    before_save :sanitize_user_html
  end

  class_methods do
    def sanitizes_user_html(*fields, sanitizer: WYSIWYGSanitizer)
      self.user_html_fields = fields.map(&:to_s)
      self.user_html_sanitizer = sanitizer
    end
  end

  def sanitize_user_html
    user_html_fields.each do |field|
      if translated_user_html_field?(field)
        sanitize_translated_user_html(field)
      else
        value = self[field]
        clean = clean_user_html(value)
        self[field] = clean unless clean == value
      end
    end
  end

  private

    def translated_user_html_field?(field)
      self.class.respond_to?(:translated_attribute_names) &&
        self.class.translated_attribute_names.map(&:to_s).include?(field)
    end

    def sanitize_translated_user_html(field)
      translations.each do |translation|
        value = translation[field]
        clean = clean_user_html(value)
        translation[field] = clean unless clean == value
      end

      globalize.stash.each do |locale, attributes|
        next unless attributes.key?(field.to_sym) || attributes.key?(field)

        value = globalize.stash.read(locale, field.to_sym)
        clean = clean_user_html(value)
        globalize.stash.write(locale, field.to_sym, clean) unless clean == value
      end
    end

    def clean_user_html(value)
      return value if value.blank?

      user_html_sanitizer.new.sanitize(value)
    end
end
