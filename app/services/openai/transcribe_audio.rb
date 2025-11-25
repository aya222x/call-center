module Openai
  class TranscribeAudio < ActiveInteraction::Base
    object :call_recording, class: CallRecording

    validate :validate_audio_file

    def execute
      transcript = transcribe_audio
      call_recording.update!(transcript: transcript)

      { transcript: transcript }
    rescue StandardError => e
      call_recording.update!(
        status: :failed,
        error_message: "Transcription failed: #{e.message}"
      )
      errors.add(:base, "Failed to transcribe audio: #{e.message}")
      nil
    end

    private

    def transcribe_audio
      client = OpenAI::Client.new(access_token: ENV.fetch('OPENAI_API_KEY', 'test_key'))

      response = client.audio.transcribe(
        parameters: {
          model: 'whisper-1',
          file: audio_file_io,
          language: language_code
        }
      )

      response['text']
    end

    def audio_file_io
      # Download audio file to temp location for OpenAI API
      temp_file = Tempfile.new(['audio', File.extname(call_recording.audio_file.filename.to_s)])
      temp_file.binmode
      call_recording.audio_file.download { |chunk| temp_file.write(chunk) }
      temp_file.rewind
      temp_file
    end

    def language_code
      case call_recording.language
      when 'kyrgyz' then 'ky'
      when 'russian' then 'ru'
      when 'english' then 'en'
      else 'ru' # default to Russian
      end
    end

    def validate_audio_file
      unless call_recording.audio_file.attached?
        errors.add(:base, 'Audio file not attached')
      end
    end

  end
end
