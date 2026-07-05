class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    if user.super_admin?
      can :manage, :all
    elsif user.forum_id.present?
      can :access, Forum, id: user.forum_id
    end
  end
end
