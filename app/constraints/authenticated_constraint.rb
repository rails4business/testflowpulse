# app/constraints/authenticated_constraint.rb
class AuthenticatedConstraint
  def matches?(req)
    req.session[:current_user_id].present?
  end
end
