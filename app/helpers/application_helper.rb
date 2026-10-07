module ApplicationHelper
  def back_to_dashboard_link
    link_to "← #{Current.user.agent? ? "All tickets" : "My tickets"}", root_path, class: "back"
  end
end
