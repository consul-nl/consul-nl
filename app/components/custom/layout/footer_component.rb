load Rails.root.join("app", "components", "layout", "footer_component.rb")

class Layout::FooterComponent
  delegate :image_path_for, to: :helpers
end
