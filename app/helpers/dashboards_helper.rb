module DashboardsHelper
  def dashboard_heading
    Current.user.agent? ? "All tickets" : "My tickets"
  end
end
