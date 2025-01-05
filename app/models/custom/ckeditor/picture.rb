load Rails.root.join("app", "models", "ckeditor", "picture.rb")

class Ckeditor::Picture
  validates :storage_data, file_content_type: { allow: /^image\/.*/ }, file_size: { less_than: 50.megabytes }
end
