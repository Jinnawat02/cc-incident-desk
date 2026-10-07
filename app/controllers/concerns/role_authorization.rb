module RoleAuthorization
  extend ActiveSupport::Concern

  private
    def require_customer
      redirect_to root_path, alert: "Only customers can do that." unless Current.user.customer?
    end
end
