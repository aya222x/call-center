# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           not null
#  name                   :string           not null
#  owner                  :boolean          default(FALSE), not null
#  password_digest        :string           not null
#  reset_password_digest  :string
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
#
FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password123" }
    password_confirmation { "password123" }
    owner { false }

    trait :owner do
      owner { true }
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
