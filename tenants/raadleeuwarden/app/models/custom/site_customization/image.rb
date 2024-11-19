load Rails.root.join("app", "models", "site_customization", "image.rb")

class SiteCustomization::Image
  VALID_IMAGES = {
    "logo_header" => [520, 80],
    "social_media_icon" => [470, 246],
    "social_media_icon_twitter" => [246, 246],
    "apple-touch-icon-200" => [200, 200],
    "auth_bg" => [934, 1398],
    "budget_execution_no_image" => [800, 600],
    "budget_investment_no_image" => [800, 600],
    "favicon" => [16, 16],
    "map" => [420, 500],
    "logo_email" => [400, 80],
    "welcome_process" => [370, 185]
  }.freeze
end

