require 'rails_helper'

RSpec.describe Openai::TranscribeAudio, type: :service do
  let(:call_recording) { create(:call_recording, :uploaded, :with_audio, language: :russian) }
  let(:mock_client) { instance_double(OpenAI::Client) }
  let(:mock_audio_api) { double('audio_api') }
  let(:mock_response) do
    {
      'text' => 'Добрый день! Спасибо за звонок. Чем могу помочь?'
    }
  end

  before do
    allow(OpenAI::Client).to receive(:new).and_return(mock_client)
    allow(mock_client).to receive(:audio).and_return(mock_audio_api)
    allow(mock_audio_api).to receive(:transcribe).and_return(mock_response)
  end

  describe '#execute' do
    context 'with valid call recording' do
      subject(:outcome) { described_class.run(call_recording: call_recording) }

      it 'is successful' do
        expect(outcome).to be_valid
      end

      it 'returns transcript text' do
        result = outcome.result
        expect(result[:transcript]).to eq('Добрый день! Спасибо за звонок. Чем могу помочь?')
      end

      it 'calls OpenAI API with correct parameters' do
        expect(mock_audio_api).to receive(:transcribe).with(
          hash_including(
            parameters: hash_including(
              model: 'whisper-1',
              language: 'ru'
            )
          )
        )
        outcome
      end

      it 'updates call recording status to transcribing' do
        outcome
        expect(call_recording.reload.status).to eq('transcribing')
      end
    end

    context 'with kyrgyz language' do
      let(:call_recording) { create(:call_recording, :uploaded, :with_audio, language: :kyrgyz) }

      it 'uses correct language code' do
        expect(mock_audio_api).to receive(:transcribe).with(
          hash_including(
            parameters: hash_including(
              language: 'ky'
            )
          )
        )
        described_class.run(call_recording: call_recording)
      end
    end

    context 'with english language' do
      let(:call_recording) { create(:call_recording, :uploaded, :with_audio, language: :english) }

      it 'uses correct language code' do
        expect(mock_audio_api).to receive(:transcribe).with(
          hash_including(
            parameters: hash_including(
              language: 'en'
            )
          )
        )
        described_class.run(call_recording: call_recording)
      end
    end

    context 'when OpenAI API fails' do
      before do
        allow(mock_audio_api).to receive(:transcribe).and_raise(StandardError.new('API Error'))
      end

      it 'is invalid' do
        outcome = described_class.run(call_recording: call_recording)
        expect(outcome).to be_invalid
      end

      it 'adds error message' do
        outcome = described_class.run(call_recording: call_recording)
        expect(outcome.errors[:base]).to include('Failed to transcribe audio: API Error')
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

    context 'with missing audio file' do
      let(:call_recording) { create(:call_recording, :uploaded) }

      it 'is invalid' do
        outcome = described_class.run(call_recording: call_recording)
        expect(outcome).to be_invalid
      end

      it 'has validation error' do
        outcome = described_class.run(call_recording: call_recording)
        expect(outcome.errors[:base]).to include('Audio file not attached')
      end
    end

    context 'with already transcribed recording' do
      let(:call_recording) { create(:call_recording, :completed) }

      it 'is invalid' do
        outcome = described_class.run(call_recording: call_recording)
        expect(outcome).to be_invalid
      end

      it 'has validation error' do
        outcome = described_class.run(call_recording: call_recording)
        expect(outcome.errors[:base]).to include('Recording cannot be processed')
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
