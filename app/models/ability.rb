class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    if user.super_admin?
      can :manage, :all
      return
    end

    return unless user.forum_id.present?

    can :access, Forum, id: user.forum_id

    case user.role.to_sym
    when :forum_admin
      can :manage, Chapter, forum_id: user.forum_id
      can :manage, User, forum_id: user.forum_id
      can :manage, FeePayment, user: { forum_id: user.forum_id }
      can :manage, Attendance, user: { forum_id: user.forum_id }
      can :manage, Referral, giver: { forum_id: user.forum_id }
      can :manage, ThanksgivingSlip, given_by: { forum_id: user.forum_id }
      can :manage, BusinessCategory, forum_id: user.forum_id
      can :manage, Meeting, chapter: { forum_id: user.forum_id }
      can :manage, WeeklyPresentation, chapter: { forum_id: user.forum_id }
      can :manage, OneToOneMeeting, forum_id: user.forum_id
      can :manage, OfficeDarshan, forum_id: user.forum_id
    when :chapter_admin
      can [ :read, :update ], Chapter, id: user.chapter_id
      can :manage, User, chapter_id: user.chapter_id
      can :manage, FeePayment, user: { chapter_id: user.chapter_id }
      can :manage, Attendance, user: { chapter_id: user.chapter_id }
      can :manage, Referral, giver: { chapter_id: user.chapter_id }
      can :manage, ThanksgivingSlip, given_by: { chapter_id: user.chapter_id }
      can :read, BusinessCategory, forum_id: user.forum_id
      can :manage, Meeting, chapter_id: user.chapter_id
      can :manage, WeeklyPresentation, chapter_id: user.chapter_id
      can :manage, OneToOneMeeting, forum_id: user.forum_id
      can :manage, OfficeDarshan, forum_id: user.forum_id
    when :committee_member
      can :read, Chapter, id: user.chapter_id
      can :read, User, chapter_id: user.chapter_id
      can [ :read, :create ], Attendance, user: { chapter_id: user.chapter_id }
      can [ :read, :create ], Referral, giver_id: user.id
      can :read, Referral, giver: { chapter_id: user.chapter_id }
      can [ :read, :create ], ThanksgivingSlip, given_by_id: user.id
      can :read, BusinessCategory, forum_id: user.forum_id
      can [ :read, :create, :update ], Meeting, chapter_id: user.chapter_id
      can [ :read, :create, :update ], WeeklyPresentation, chapter_id: user.chapter_id
      can [ :read, :create ], OneToOneMeeting, requester_id: user.id
      can [ :read, :update ], OneToOneMeeting, requested_with_id: user.id
      can :read, OfficeDarshan, member_id: user.id
    when :member
      can :read, Chapter, id: user.chapter_id
      can :read, User, id: user.id
      can :update, User, id: user.id
      can [ :read, :create ], Referral, giver_id: user.id
      can :read, Referral, receiver_id: user.id
      can [ :read, :create ], ThanksgivingSlip, given_by_id: user.id
      can :read, Attendance, user_id: user.id
      can :read, FeePayment, user_id: user.id
      can :read, Meeting, chapter_id: user.chapter_id
      can :read, WeeklyPresentation, chapter_id: user.chapter_id
      can [ :read, :create ], OneToOneMeeting, requester_id: user.id
      can [ :read, :update ], OneToOneMeeting, requested_with_id: user.id
      can :read, OfficeDarshan, member_id: user.id
    when :guest
      can :read, Chapter, id: user.chapter_id
      can :read, User, id: user.id
      can :update, User, id: user.id
      can :read, Attendance, user_id: user.id
      can :read, Meeting, chapter_id: user.chapter_id
    end
  end
end
