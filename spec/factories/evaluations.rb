FactoryBot.define do
  factory :evaluation do
    association :call_recording
    overall_score { 75 }
    script_adherence_score { 80 }
    politeness_score { 85 }
    resolution_speed_score { 70 }
    terminology_score { 75 }
    success_score { 65 }
    recommendations { 'Good performance overall. Focus on improving call resolution speed.' }

    trait :excellent do
      overall_score { 95 }
      script_adherence_score { 95 }
      politeness_score { 98 }
      resolution_speed_score { 92 }
      terminology_score { 97 }
      success_score { 93 }
      recommendations { 'Excellent performance! Keep up the great work.' }
    end

    trait :poor do
      overall_score { 45 }
      script_adherence_score { 40 }
      politeness_score { 50 }
      resolution_speed_score { 35 }
      terminology_score { 55 }
      success_score { 45 }
      recommendations { 'Needs significant improvement. Consider additional training on script adherence and customer service skills.' }
    end

    trait :incomplete_scores do
      script_adherence_score { 80 }
      politeness_score { nil }
      resolution_speed_score { 70 }
      terminology_score { nil }
      success_score { 75 }
    end
  end
end
