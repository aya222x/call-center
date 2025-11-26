module Openai
  class EvaluateCall < ActiveInteraction::Base
    include RetryHandler

    object :call_recording, class: CallRecording

    validate :validate_transcript
    validate :validate_not_already_evaluated

    def execute
      call_recording.update!(status: :analyzing)

      evaluation_data = evaluate_with_ai
      evaluation = create_evaluation(evaluation_data)

      call_recording.update!(status: :completed)

      { evaluation: evaluation }
    rescue StandardError => e
      call_recording.update!(
        status: :failed,
        error_message: "Evaluation failed: #{e.message}"
      )
      errors.add(:base, "Failed to evaluate call: #{e.message}")
      nil
    end

    private

    def evaluate_with_ai
      client = OpenAI::Client.new(access_token: ENV.fetch('OPENAI_API_KEY', 'test_key'))

      with_retry do
        response = client.chat(
          parameters: {
            model: 'gpt-4',
            messages: [
              { role: 'system', content: system_prompt },
              { role: 'user', content: user_prompt }
            ],
            temperature: 0.3
          }
        )

        content = response.dig('choices', 0, 'message', 'content')
        parse_evaluation_response(content)
      end
    rescue JSON::ParserError => e
      raise StandardError, "Failed to parse evaluation response: #{e.message}"
    end

    def system_prompt
      <<~PROMPT
        You are an expert call center quality evaluator. Your task is to evaluate call recordings based on the following 5 criteria:

        1. Script Adherence (script_adherence): How well did the operator follow the provided call script?
        2. Politeness and Tone (politeness): Was the operator polite, friendly, and professional?
        3. Resolution Speed (resolution_speed): How quickly and efficiently was the customer's issue addressed?
        4. Terminology Usage (terminology): Did the operator use correct and appropriate terminology?
        5. Call Success (success): Was the call successful in achieving its goal (sale, resolution, etc.)?

        For each criterion, provide a score from 0 to 100.
        Also provide recommendations for improvement in English or Russian.

        Respond ONLY with valid JSON in this exact format:
        {
          "script_adherence": 85,
          "politeness": 90,
          "resolution_speed": 75,
          "terminology": 80,
          "success": 70,
          "recommendations": "Your detailed recommendations here"
        }

        If you cannot evaluate a particular criterion due to lack of information, omit it from the response.
      PROMPT
    end

    def user_prompt
      <<~PROMPT
        Please evaluate the following call recording:

        **Call Script:**
        #{call_recording.call_script.content}

        **Call Transcript:**
        #{call_recording.transcript}

        **Call Type:** #{call_recording.call_script.call_type}
        **Language:** #{call_recording.language}

        Provide your evaluation as JSON.
      PROMPT
    end

    def parse_evaluation_response(content)
      # Extract JSON from response (in case there's additional text)
      json_match = content.match(/\{[^}]+\}/)
      json_string = json_match ? json_match[0] : content

      JSON.parse(json_string, symbolize_names: true)
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

    def validate_not_already_evaluated
      if call_recording.evaluation.present?
        errors.add(:base, 'Recording already evaluated')
      end
    end
  end
end
