load Rails.root.join("app", "models", "setting.rb")

class Setting
  # alias_method :consul_type, :type

  # def type
  #   if prefix == "show_navbar"
  #     current_type = "show_navbar"
  #   end
  #
  #   current_type || consul_type
  # end

  class << self
    alias_method :consul_defaults, :defaults

    # Change this code when you'd like to add settings that aren't
    # already present in the database. These settings will be added when
    # first installing CONSUL, when deploying code with Capistrano, or
    # when manually executing the `settings:add_new_settings` task.
    #
    # If a setting already exists in the database, changing its value in
    # this file will have no effect unless the task `rake db:seed` is
    # invoked or the method `Setting.reset_defaults` is executed. Doing
    # so will overwrite the values of all existing settings in the
    # database, so use with care.
    #
    # The tests in the spec/ folder rely on CONSUL's default settings, so
    # it's recommended not to change the default settings in the test
    # environment.
    def defaults
      if Rails.env.test?
        consul_defaults
      else
        consul_defaults.merge({
          # Overwrite default CONSUL settings or add new settings here
          "feature.raad": false,
          "show_navbar.debates": true,
          "show_navbar.proposals": true,
          "show_navbar.polls": true,
          "show_navbar.budgets": true,
          "show_navbar.legislation": true,
          "show_navbar.raad": true,
          "show_navbar.sdg": true,
          "show_navbar.help": true
        })
      end
    end
  end
end
