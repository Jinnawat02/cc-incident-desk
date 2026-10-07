class ApplicationController < ActionController::Base
  include Authentication
  include RoleAuthorization

  allow_browser versions: :modern
end
