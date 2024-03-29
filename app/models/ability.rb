# frozen_string_literal: true
class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:
    #
    # user ||= User.new # guest user (not logged in)
    if user.has_role? :admin
      can :manage, :all
    elsif user.has_role? :gym
      can :manage, GymsSubItem
      %i(create destroy).each do |role|
        cannot role, GymsSubItem
      end
      can :manage, Purchase
      %i(update destroy show).each do |role|
        cannot role, Purchase
      end
      can :manage, SubItem
      %i(update destroy show create).each do |role|
        cannot role, SubItem
      end
    elsif user.has_role? :report
      can :manage, Report
    end
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities
  end
end
