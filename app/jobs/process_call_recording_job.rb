class ProcessCallRecordingJob < ApplicationJob
  queue_as :default

  def perform(call_recording_id)
    recording = CallRecording.find(call_recording_id)

    # Check if demo mode is enabled
    use_demo_mode = ENV['USE_DEMO_MODE'] == 'true'

    # Step 1: Transcribe audio
    recording.update!(status: :transcribing)

    transcription_outcome = if use_demo_mode
      Openai::DemoTranscribe.run(call_recording: recording)
    else
      Openai::TranscribeAudio.run(call_recording: recording)
    end

    if transcription_outcome.valid?
      recording.update!(
        transcript: transcription_outcome.result[:transcript],
        status: :analyzing
      )

      # Step 2: Evaluate call
      evaluation_outcome = if use_demo_mode
        Openai::DemoEvaluate.run(call_recording: recording)
      else
        Openai::EvaluateCall.run(
          call_recording: recording,
          call_script: recording.call_script
        )
      end

      if evaluation_outcome.valid?
        recording.update!(status: :completed)
      else
        recording.update!(
          status: :failed,
          error_message: "Evaluation failed: #{evaluation_outcome.errors.full_messages.join(', ')}"
        )
      end
    else
      recording.update!(
        status: :failed,
        error_message: "Transcription failed: #{transcription_outcome.errors.full_messages.join(', ')}"
      )
    end
  rescue StandardError => e
    recording.update!(
      status: :failed,
      error_message: "Processing error: #{e.message}"
    ) if recording

    raise e
  end
end
