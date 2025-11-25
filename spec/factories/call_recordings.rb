FactoryBot.define do
  factory :call_recording do
    association :user, factory: :user, role: :operator
    association :call_script
    status { :uploaded }
    language { :russian }
    call_date { Date.current }
    duration_seconds { 180 }
    customer_name { 'Test Customer' }
    customer_phone { '+996555123456' }

    trait :uploaded do
      status { :uploaded }
    end

    trait :transcribing do
      status { :transcribing }
    end

    trait :analyzing do
      status { :analyzing }
      transcript { 'Sample transcript of the call...' }
    end

    trait :completed do
      status { :completed }
      transcript { 'Complete transcript of the call...' }
      after(:create) do |recording|
        create(:evaluation, call_recording: recording)
      end
    end

    trait :failed do
      status { :failed }
      error_message { 'Failed to process audio file' }
    end

    trait :kyrgyz do
      language { :kyrgyz }
    end

    trait :russian do
      language { :russian }
    end

    trait :english do
      language { :english }
    end

    trait :with_audio do
      after(:build) do |recording|
        recording.audio_file.attach(
          io: File.open(Rails.root.join('spec', 'fixtures', 'files', 'sample_audio.mp3')),
          filename: 'sample_audio.mp3',
          content_type: 'audio/mpeg'
        )
      end
    end
  end
end
