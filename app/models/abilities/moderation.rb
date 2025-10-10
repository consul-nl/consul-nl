module Abilities
  class Moderation
    include CanCan::Ability

    def initialize(user)
      merge Abilities::Common.new(user)

      can :read, Organization
      can(:verify, Organization) { |o| !o.verified? }
      can(:reject, Organization) { |o| !o.rejected? }

      can :read, Comment

      can :hide, Comment, hidden_at: nil

      can :ignore_flag, Comment, ignored_flag_at: nil, hidden_at: nil

      can :moderate, Comment

      can :hide, Debate, hidden_at: nil

      can :ignore_flag, Debate, ignored_flag_at: nil, hidden_at: nil

      can :moderate, Debate

      can :hide, Proposal, hidden_at: nil

      can :ignore_flag, Proposal, ignored_flag_at: nil, hidden_at: nil

      can :moderate, Proposal

      can :hide, Legislation::Proposal, hidden_at: nil

      can :ignore_flag, Legislation::Proposal, ignored_flag_at: nil, hidden_at: nil

      can :moderate, Legislation::Proposal

      can :hide, User
      cannot :hide, User, id: user.id

      can :block, User
      cannot :block, User, id: user.id

      can :hide, ProposalNotification, hidden_at: nil

      can :ignore_flag, ProposalNotification, ignored_at: nil, hidden_at: nil

      can :moderate, ProposalNotification

      can :index, ProposalNotification

      can :hide, Budget::Investment, hidden_at: nil

      can :ignore_flag, Budget::Investment, ignored_flag_at: nil, hidden_at: nil

      can :moderate, Budget::Investment
    end
  end
end
