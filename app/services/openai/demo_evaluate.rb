module Openai
  class DemoEvaluate < ActiveInteraction::Base
    object :call_recording, class: CallRecording

    validate :validate_transcript

    def execute
      # Simulate processing delay
      sleep(rand(2..4))

      evaluation_data = generate_demo_evaluation
      evaluation = create_evaluation(evaluation_data)

      { evaluation: evaluation }
    end

    private

    def generate_demo_evaluation
      # Generate realistic scores between 70-95
      base_quality = rand(70..95)
      variation = 10

      {
        script_adherence: generate_score(base_quality, variation),
        politeness: generate_score(base_quality, variation),
        resolution_speed: generate_score(base_quality, variation),
        terminology: generate_score(base_quality, variation),
        success: generate_score(base_quality, variation),
        recommendations: generate_recommendations(base_quality)
      }
    end

    def generate_score(base, variation)
      score = base + rand(-variation..variation)
      [[score, 100].min, 0].max
    end

    def generate_recommendations(quality_level)
      if quality_level >= 90
        excellent_recommendations
      elsif quality_level >= 80
        good_recommendations
      elsif quality_level >= 70
        satisfactory_recommendations
      else
        needs_improvement_recommendations
      end
    end

    def excellent_recommendations
      recommendations = [
        "Отличная работа! Оператор продемонстрировал высокий профессионализм.",
        "Excellent performance! The operator demonstrated outstanding professionalism.",
        "Мыкты иш! Оператор жогорку профессионализмди көрсөттү.",
        "Продолжайте в том же духе. Ваше общение с клиентом было безупречным.",
        "Keep up the great work. Your customer interaction was flawless.",
        "Все аспекты звонка выполнены на высшем уровне.",
        "All aspects of the call were executed at the highest level."
      ]
      recommendations.sample(2).join(' ')
    end

    def good_recommendations
      recommendations = [
        "Хорошая работа! Рекомендуем обратить внимание на более активное использование профессиональной терминологии.",
        "Good job! Consider using more professional terminology during calls.",
        "Оператор хорошо следовал скрипту, но можно улучшить скорость обработки запросов.",
        "The operator followed the script well, but response time could be improved.",
        "Отличная вежливость и тон, продолжайте развивать навыки активного слушания.",
        "Excellent politeness and tone, continue developing active listening skills.",
        "Рекомендуется практиковать более краткие и четкие формулировки.",
        "Practice more concise and clear communication."
      ]
      recommendations.sample(2).join(' ')
    end

    def satisfactory_recommendations
      recommendations = [
        "Удовлетворительная работа. Рекомендуем уделить больше внимания следованию скрипту.",
        "Satisfactory performance. Focus more on following the call script.",
        "Необходимо улучшить скорость реакции на запросы клиента.",
        "Need to improve response time to customer requests.",
        "Рекомендуем дополнительное обучение по работе с возражениями.",
        "Additional training on handling objections is recommended.",
        "Обратите внимание на использование правильной терминологии.",
        "Pay attention to using correct terminology.",
        "Практикуйте более дружелюбный тон общения.",
        "Practice a more friendly communication tone."
      ]
      recommendations.sample(2).join(' ')
    end

    def needs_improvement_recommendations
      recommendations = [
        "Требуется значительное улучшение. Необходимо строго следовать скрипту звонка.",
        "Significant improvement needed. Must strictly follow the call script.",
        "Рекомендуется пройти дополнительное обучение по всем аспектам обслуживания клиентов.",
        "Additional training in all aspects of customer service is recommended.",
        "Обратите особое внимание на вежливость и профессионализм в общении.",
        "Pay special attention to politeness and professionalism in communication.",
        "Необходимо улучшить знание продуктов и услуг компании.",
        "Need to improve knowledge of company products and services.",
        "Практикуйте активное слушание и работу с возражениями.",
        "Practice active listening and objection handling."
      ]
      recommendations.sample(3).join(' ')
    end

    def create_evaluation(data)
      scores = [
        data[:script_adherence],
        data[:politeness],
        data[:resolution_speed],
        data[:terminology],
        data[:success]
      ].compact

      overall_score = scores.empty? ? 0.0 : (scores.sum / scores.size.to_f).round(2)

      Evaluation.create!(
        call_recording: call_recording,
        overall_score: overall_score,
        script_adherence_score: data[:script_adherence],
        politeness_score: data[:politeness],
        resolution_speed_score: data[:resolution_speed],
        terminology_score: data[:terminology],
        success_score: data[:success],
        recommendations: data[:recommendations]
      )
    end

    def validate_transcript
      if call_recording.transcript.blank?
        errors.add(:base, 'Transcript not available')
      end
    end
  end
end
