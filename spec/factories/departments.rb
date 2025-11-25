FactoryBot.define do
  factory :department do
    sequence(:name) { |n| "Department #{n}" }
    deactivated_at { nil }

    trait :sales do
      name { 'Sales Department' }
    end

    trait :bank do
      name { 'Bank Department' }
    end

    trait :deactivated do
      deactivated_at { Time.current }
    end
  end
end
