class ProcessCallRecordingJob < ApplicationJob
  queue_as :default

  def perform(call_recording_id)
    recording = CallRecording.find(call_recording_id)

    # Step 1: Transcribe audio
    recording.update!(status: :transcribing)

    transcription_outcome = Openai::TranscribeAudio.run(
      call_recording: recording
    )

    if transcription_outcome.valid?
      recording.update!(
        transcript: transcription_outcome.result,
        status: :analyzing
      )

      # Step 2: Evaluate call
      evaluation_outcome = Openai::EvaluateCall.run(
        call_recording: recording,
        call_script: recording.call_script
      )

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
