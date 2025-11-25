require 'rails_helper'

RSpec.describe CallRecording, type: :model do
  describe 'validations' do
    subject { build(:call_recording) }

    it { is_expected.to validate_presence_of(:user_id) }
    it { is_expected.to validate_presence_of(:call_script_id) }
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_length_of(:customer_name).is_at_most(200).allow_nil }
    it { is_expected.to validate_length_of(:customer_phone).is_at_most(50).allow_nil }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:call_script) }
    it { is_expected.to have_one(:evaluation).dependent(:destroy) }
    it { is_expected.to have_one_attached(:audio_file) }
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:status).with_values(
      uploaded: 0,
      transcribing: 1,
      analyzing: 2,
      completed: 3,
      failed: 4
    ) }

    it { is_expected.to define_enum_for(:language).with_values(
      kyrgyz: 0,
      russian: 1,
      english: 2
    ) }
  end

  describe 'auditing' do
    it 'is audited' do
      expect(CallRecording.new).to respond_to(:audits)
    end
  end

  describe 'scopes' do
    describe '.for_user' do
      it 'returns recordings for specific user' do
        user1 = create(:user)
        user2 = create(:user)
        recording1 = create(:call_recording, user: user1)
        recording2 = create(:call_recording, user: user2)

        expect(CallRecording.for_user(user1.id)).to include(recording1)
        expect(CallRecording.for_user(user1.id)).not_to include(recording2)
      end
    end

    describe '.for_team' do
      it 'returns recordings for users in specific team' do
        team1 = create(:team)
        team2 = create(:team)
        user1 = create(:user, team: team1, role: :operator)
        user2 = create(:user, team: team2, role: :operator)
        recording1 = create(:call_recording, user: user1)
        recording2 = create(:call_recording, user: user2)

        expect(CallRecording.for_team(team1.id)).to include(recording1)
        expect(CallRecording.for_team(team1.id)).not_to include(recording2)
      end
    end

    describe '.for_department' do
      it 'returns recordings for users in specific department' do
        dept1 = create(:department, name: 'Sales')
        dept2 = create(:department, name: 'Bank')
        team1 = create(:team, department: dept1)
        team2 = create(:team, department: dept2)
        user1 = create(:user, team: team1, role: :operator)
        user2 = create(:user, team: team2, role: :operator)
        recording1 = create(:call_recording, user: user1)
        recording2 = create(:call_recording, user: user2)

        expect(CallRecording.for_department(dept1.id)).to include(recording1)
        expect(CallRecording.for_department(dept1.id)).not_to include(recording2)
      end
    end

    describe '.recent' do
      it 'returns recordings ordered by created_at desc' do
        old_recording = create(:call_recording, created_at: 2.days.ago)
        new_recording = create(:call_recording, created_at: 1.day.ago)

        expect(CallRecording.recent.first).to eq(new_recording)
        expect(CallRecording.recent.last).to eq(old_recording)
      end
    end

    describe '.by_status' do
      it 'returns recordings with specific status' do
        completed = create(:call_recording, status: :completed)
        uploaded = create(:call_recording, status: :uploaded)

        expect(CallRecording.by_status('completed')).to include(completed)
        expect(CallRecording.by_status('completed')).not_to include(uploaded)
      end
    end

    describe '.by_language' do
      it 'returns recordings in specific language' do
        kyrgyz = create(:call_recording, language: :kyrgyz)
        russian = create(:call_recording, language: :russian)

        expect(CallRecording.by_language('kyrgyz')).to include(kyrgyz)
        expect(CallRecording.by_language('kyrgyz')).not_to include(russian)
      end
    end

    describe '.date_range' do
      it 'returns recordings within date range' do
        recording1 = create(:call_recording, call_date: '2025-01-01')
        recording2 = create(:call_recording, call_date: '2025-01-15')
        recording3 = create(:call_recording, call_date: '2025-02-01')

        results = CallRecording.date_range('2025-01-01', '2025-01-31')
        expect(results).to include(recording1, recording2)
        expect(results).not_to include(recording3)
      end
    end
  end

  describe '#duration_formatted' do
    it 'formats duration in minutes and seconds' do
      recording = build(:call_recording, duration_seconds: 125)
      expect(recording.duration_formatted).to eq('2:05')
    end

    it 'handles nil duration' do
      recording = build(:call_recording, duration_seconds: nil)
      expect(recording.duration_formatted).to eq('0:00')
    end
  end

  describe '#can_be_processed?' do
    it 'returns true for uploaded status' do
      recording = build(:call_recording, status: :uploaded)
      expect(recording.can_be_processed?).to be true
    end

    it 'returns false for other statuses' do
      recording = build(:call_recording, status: :completed)
      expect(recording.can_be_processed?).to be false
    end
  end
end
