module Consul
  class Application < Rails::Application
    unless Rails.env.test?
      config.i18n.default_locale = "nl"
      config.i18n.available_locales = ["nl"]
      config.i18n.enforce_available_locales = false
      config.i18n.fallbacks = { "nl" => "en" }

      config.to_prepare do
        previous_secret = Rails.application.secrets.secret_key_base_old

        if previous_secret.present?
          ActiveStorage.verifier.rotate(previous_secret)
        end
      end
    end
  end
end
