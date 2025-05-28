load Rails.root.join("app", "components", "budgets", "investments", "new_component.rb")

class Budgets::Investments::NewComponent
  def title
    subtitle
  end
end
