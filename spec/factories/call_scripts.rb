FactoryBot.define do
  factory :call_script do
    sequence(:name) { |n| "Call Script #{n}" }
    call_type { :sales }
    content { "Hello, thank you for calling. How may I assist you today?" }
    association :department
    active { true }

    trait :sales_script do
      call_type { :sales }
      name { 'Outbound Sales Script' }
      content { <<~SCRIPT
        1. Greet the customer warmly
        2. Introduce yourself and the company
        3. Ask about their needs
        4. Present the product/service
        5. Handle objections
        6. Close the sale
        7. Thank the customer
      SCRIPT
      }
    end

    trait :support_script do
      call_type { :support }
      name { 'Customer Support Script' }
      content { <<~SCRIPT
        1. Greet the customer professionally
        2. Ask for their account information
        3. Listen to their issue carefully
        4. Acknowledge their concern
        5. Provide solution
        6. Confirm resolution
        7. Thank them for their patience
      SCRIPT
      }
    end

    trait :survey_script do
      call_type { :survey }
      name { 'Customer Satisfaction Survey' }
    end

    trait :inactive do
      active { false }
    end
  end
end
