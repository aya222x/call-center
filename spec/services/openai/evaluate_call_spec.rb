require 'rails_helper'

RSpec.describe Openai::EvaluateCall, type: :service do
  let(:department) { create(:department, name: 'Sales') }
  let(:call_script) { create(:call_script, :sales_script, department: department) }
  let(:call_recording) do
    create(:call_recording, :analyzing,
      call_script: call_script,
      transcript: 'Добрый день! Меня зовут Айгуль. Я звоню из компании...'
    )
  end

  let(:mock_client) { instance_double(OpenAI::Client) }
  let(:mock_response) do
    {
      'choices' => [
        {
          'message' => {
            'content' => {
              script_adherence: 85,
              politeness: 90,
              resolution_speed: 75,
              terminology: 80,
              success: 70,
              recommendations: 'Good performance. Focus on improving closing techniques.'
            }.to_json
          }
        }
      ]
    }
  end

  before do
    allow(OpenAI::Client).to receive(:new).and_return(mock_client)
    allow(mock_client).to receive(:chat).and_return(mock_response)
  end

  describe '#execute' do
    context 'with valid call recording' do
      subject(:outcome) { described_class.run(call_recording: call_recording) }

      it 'is successful' do
        expect(outcome).to be_valid
      end

      it 'returns evaluation data' do
        result = outcome.result
        expect(result[:evaluation]).to be_a(Evaluation)
        expect(result[:evaluation]).to be_persisted
      end

      it 'creates evaluation with all scores' do
        result = outcome.result
        evaluation = result[:evaluation]

        expect(evaluation.script_adherence_score).to eq(85)
        expect(evaluation.politeness_score).to eq(90)
        expect(evaluation.resolution_speed_score).to eq(75)
        expect(evaluation.terminology_score).to eq(80)
        expect(evaluation.success_score).to eq(70)
        expect(evaluation.recommendations).to include('Good performance')
      end

      it 'calculates overall score' do
        result = outcome.result
        evaluation = result[:evaluation]
        expected_overall = (85 + 90 + 75 + 80 + 70) / 5.0

        expect(evaluation.overall_score).to eq(expected_overall)
      end

      it 'calls OpenAI API with correct parameters' do
        expect(mock_client).to receive(:chat).with(
          hash_including(
            parameters: hash_including(
              model: 'gpt-4',
              messages: array_including(
                hash_including(role: 'system'),
                hash_including(role: 'user')
              )
            )
          )
        )
        outcome
      end

      it 'includes script content in prompt' do
        expect(mock_client).to receive(:chat) do |args|
          user_message = args[:parameters][:messages].find { |m| m[:role] == 'user' }
          expect(user_message[:content]).to include(call_script.content)
        end.and_return(mock_response)

        outcome
      end

      it 'includes transcript in prompt' do
        expect(mock_client).to receive(:chat) do |args|
          user_message = args[:parameters][:messages].find { |m| m[:role] == 'user' }
          expect(user_message[:content]).to include(call_recording.transcript)
        end.and_return(mock_response)

        outcome
      end

      it 'updates call recording status to completed' do
        outcome
        expect(call_recording.reload.status).to eq('completed')
      end
    end

    context 'when OpenAI returns partial scores' do
      let(:mock_response) do
        {
          'choices' => [
            {
              'message' => {
                'content' => {
                  script_adherence: 85,
                  politeness: 90,
                  recommendations: 'Partial evaluation due to short call.'
                }.to_json
              }
            }
          ]
        }
      end

      it 'creates evaluation with available scores' do
        result = described_class.run(call_recording: call_recording).result
        evaluation = result[:evaluation]

        expect(evaluation.script_adherence_score).to eq(85)
        expect(evaluation.politeness_score).to eq(90)
        expect(evaluation.resolution_speed_score).to be_nil
        expect(evaluation.terminology_score).to be_nil
        expect(evaluation.success_score).to be_nil
      end

      it 'calculates overall score from available scores only' do
        result = described_class.run(call_recording: call_recording).result
        evaluation = result[:evaluation]
        expected_overall = (85 + 90) / 2.0

        expect(evaluation.overall_score).to eq(expected_overall)
      end
    end

    context 'when OpenAI API fails' do
      before do
        allow(mock_client).to receive(:chat).and_raise(StandardError.new('API Error'))
      end

      it 'is invalid' do
        outcome = described_class.run(call_recording: call_recording)
        expect(outcome).to be_invalid
      end

      it 'adds error message' do
        outcome = described_class.run(call_recording: call_recording)
        expect(outcome.errors[:base]).to include('Failed to evaluate call: API Error')
      end

      it 'updates recording status to failed' do
        described_class.run(call_recording: call_recording)
        expect(call_recording.reload.status).to eq('failed')
      end

      it 'stores error message in recording' do
        described_class.run(call_recording: call_recording)
        expect(call_recording.reload.error_message).to include('API Error')
      end
    end

    context 'with missing transcript' do
      let(:call_recording) { create(:call_recording, :uploaded, transcript: nil) }

      it 'is invalid' do
        outcome = described_class.run(call_recording: call_recording)
        expect(outcome).to be_invalid
      end

      it 'has validation error' do
        outcome = described_class.run(call_recording: call_recording)
        expect(outcome.errors[:base]).to include('Transcript not available')
      end
    end

    context 'with already evaluated recording' do
      let(:call_recording) { create(:call_recording, :completed) }

      # The :completed trait already creates an evaluation via after(:create) callback

      it 'is invalid' do
        outcome = described_class.run(call_recording: call_recording)
        expect(outcome).to be_invalid
      end

      it 'has validation error' do
        outcome = described_class.run(call_recording: call_recording)
        expect(outcome.errors[:base]).to include('Recording already evaluated')
      end
    end

    context 'when JSON parsing fails' do
      let(:mock_response) do
        {
          'choices' => [
            {
              'message' => {
                'content' => 'Invalid JSON response'
              }
            }
          ]
        }
      end

      it 'is invalid' do
        outcome = described_class.run(call_recording: call_recording)
        expect(outcome).to be_invalid
      end

      it 'adds error message' do
        outcome = described_class.run(call_recording: call_recording)
        expect(outcome.errors[:base].first).to match(/Failed to evaluate call:.*Failed to parse evaluation response/)
      end
    end

    context 'with missing call_recording parameter' do
      it 'requires call_recording' do
        outcome = described_class.run
        expect(outcome).to be_invalid
        expect(outcome.errors[:call_recording]).to be_present
      end
    end
  end
end
