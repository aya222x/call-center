FactoryBot.define do
  factory :team do
    sequence(:name) { |n| "Team #{n}" }
    association :department
    association :supervisor, factory: :user, role: :supervisor
    deactivated_at { nil }

    trait :sales_team do
      association :department, factory: [:department, :sales]
      name { 'Sales Team Alpha' }
    end

    trait :bank_team do
      association :department, factory: [:department, :bank]
      name { 'Bank Support Team' }
    end

    trait :deactivated do
      deactivated_at { Time.current }
    end

    trait :without_supervisor do
      supervisor { nil }
    end
  end
end
