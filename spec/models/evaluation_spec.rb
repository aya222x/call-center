require 'rails_helper'

RSpec.describe Evaluation, type: :model do
  describe 'validations' do
    subject { build(:evaluation) }

    it { is_expected.to validate_presence_of(:call_recording_id) }
    it { is_expected.to validate_presence_of(:overall_score) }
    it { is_expected.to validate_numericality_of(:overall_score).is_greater_than_or_equal_to(0).is_less_than_or_equal_to(100) }
    it { is_expected.to validate_numericality_of(:script_adherence_score).is_greater_than_or_equal_to(0).is_less_than_or_equal_to(100).allow_nil }
    it { is_expected.to validate_numericality_of(:politeness_score).is_greater_than_or_equal_to(0).is_less_than_or_equal_to(100).allow_nil }
    it { is_expected.to validate_numericality_of(:resolution_speed_score).is_greater_than_or_equal_to(0).is_less_than_or_equal_to(100).allow_nil }
    it { is_expected.to validate_numericality_of(:terminology_score).is_greater_than_or_equal_to(0).is_less_than_or_equal_to(100).allow_nil }
    it { is_expected.to validate_numericality_of(:success_score).is_greater_than_or_equal_to(0).is_less_than_or_equal_to(100).allow_nil }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:call_recording) }
  end

  describe 'auditing' do
    it 'is audited' do
      expect(Evaluation.new).to respond_to(:audits)
    end
  end

  describe '#score_color' do
    it 'returns green for scores >= 80' do
      evaluation = build(:evaluation, overall_score: 85)
      expect(evaluation.score_color).to eq('green')
    end

    it 'returns yellow for scores between 60 and 79' do
      evaluation = build(:evaluation, overall_score: 70)
      expect(evaluation.score_color).to eq('yellow')
    end

    it 'returns orange for scores between 40 and 59' do
      evaluation = build(:evaluation, overall_score: 50)
      expect(evaluation.score_color).to eq('orange')
    end

    it 'returns red for scores < 40' do
      evaluation = build(:evaluation, overall_score: 30)
      expect(evaluation.score_color).to eq('red')
    end
  end

  describe '#score_label' do
    it 'returns Excellent for scores >= 90' do
      evaluation = build(:evaluation, overall_score: 95)
      expect(evaluation.score_label).to eq('Excellent')
    end

    it 'returns Good for scores between 80 and 89' do
      evaluation = build(:evaluation, overall_score: 85)
      expect(evaluation.score_label).to eq('Good')
    end

    it 'returns Satisfactory for scores between 70 and 79' do
      evaluation = build(:evaluation, overall_score: 75)
      expect(evaluation.score_label).to eq('Satisfactory')
    end

    it 'returns Needs Improvement for scores between 60 and 69' do
      evaluation = build(:evaluation, overall_score: 65)
      expect(evaluation.score_label).to eq('Needs Improvement')
    end

    it 'returns Poor for scores < 60' do
      evaluation = build(:evaluation, overall_score: 55)
      expect(evaluation.score_label).to eq('Poor')
    end
  end

  describe '#all_scores_present?' do
    it 'returns true when all scores are present' do
      evaluation = build(:evaluation,
        script_adherence_score: 80,
        politeness_score: 85,
        resolution_speed_score: 75,
        terminology_score: 90,
        success_score: 70
      )
      expect(evaluation.all_scores_present?).to be true
    end

    it 'returns false when any score is missing' do
      evaluation = build(:evaluation,
        script_adherence_score: 80,
        politeness_score: nil,
        resolution_speed_score: 75,
        terminology_score: 90,
        success_score: 70
      )
      expect(evaluation.all_scores_present?).to be false
    end
  end

  describe '#calculate_overall_score' do
    it 'calculates average of all present scores' do
      evaluation = build(:evaluation,
        script_adherence_score: 80,
        politeness_score: 90,
        resolution_speed_score: 70,
        terminology_score: 85,
        success_score: 75
      )
      expect(evaluation.calculate_overall_score).to eq(80.0)
    end

    it 'handles missing scores' do
      evaluation = build(:evaluation,
        script_adherence_score: 80,
        politeness_score: 90,
        resolution_speed_score: nil,
        terminology_score: 85,
        success_score: nil
      )
      expect(evaluation.calculate_overall_score).to eq(85.0)
    end
  end
end
