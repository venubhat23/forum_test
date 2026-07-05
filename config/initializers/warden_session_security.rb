Warden::Manager.after_set_user do |user, warden, opts|
  next unless user.is_a?(User)

  scope = opts[:scope]
  session_key = "#{scope}_auth_token"

  # :authentication fires on explicit sign_in (real login, or a super_admin
  # switching the session during impersonation) - always trust it and stamp
  # the current token. Any other event (:fetch/:set_user) is a session being
  # recalled from a stored cookie, so compare against the live token to
  # detect force-logout/password-reset invalidation.
  if opts[:event] == :authentication
    warden.session(scope)[session_key] = user.session_token
  elsif warden.session(scope)[session_key].present? && warden.session(scope)[session_key] != user.session_token
    warden.logout(scope)
    throw :warden, scope: scope, message: :session_expired
  else
    warden.session(scope)[session_key] = user.session_token
  end
end
