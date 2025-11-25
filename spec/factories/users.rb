# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  admin                  :boolean          default(FALSE), not null
#  email                  :string           not null
#  invitation_accepted_at :datetime
#  invitation_sent_at     :datetime
#  invitation_token       :string
#  name                   :string           not null
#  password_digest        :string
#  reset_password_digest  :string
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email             (email) UNIQUE
#  index_users_on_invitation_token  (invitation_token) UNIQUE
#
FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password123" }
    password_confirmation { "password123" }
    admin { false }
    role { :operator }
    team { nil }

    trait :admin do
      admin { true }
      role { :admin }
    end

    trait :operator do
      role { :operator }
      association :team
    end

    trait :supervisor do
      role { :supervisor }
      association :team
    end

    trait :manager do
      role { :manager }
    end

    trait :invited do
      password { nil }
      password_confirmation { nil }
      invitation_token { SecureRandom.urlsafe_base64 }
      invitation_sent_at { Time.current }
      invitation_accepted_at { nil }
    end

    trait :invitation_accepted do
      invitation_token { nil }
      invitation_sent_at { 1.day.ago }
      invitation_accepted_at { Time.current }
    end
  end
end
