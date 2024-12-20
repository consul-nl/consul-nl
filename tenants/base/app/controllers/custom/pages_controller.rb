load Rails.root.join("app", "controllers", "pages_controller.rb")

class PagesController
  feature_flag :raad, if: lambda { params[:id] == "raad/index" }
end
