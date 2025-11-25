require 'rails_helper'

RSpec.describe Team, type: :model do
  describe 'validations' do
    subject { build(:team) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:department_id) }
    it { is_expected.to validate_uniqueness_of(:name).scoped_to(:department_id).case_insensitive }
    it { is_expected.to validate_length_of(:name).is_at_least(2).is_at_most(100) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:department) }
    it { is_expected.to belong_to(:supervisor).class_name('User').optional }
    it { is_expected.to have_many(:users).dependent(:nullify) }
    it { is_expected.to have_many(:call_recordings).through(:users) }
  end

  describe 'auditing' do
    it 'is audited' do
      expect(Team.new).to respond_to(:audits)
    end
  end

  describe 'scopes' do
    describe '.active' do
      it 'returns only active teams' do
        active_team = create(:team, deactivated_at: nil)
        inactive_team = create(:team, deactivated_at: Time.current)

        expect(Team.active).to include(active_team)
        expect(Team.active).not_to include(inactive_team)
      end
    end

    describe '.for_department' do
      it 'returns teams for specific department' do
        dept1 = create(:department, name: 'Sales')
        dept2 = create(:department, name: 'Bank')
        team1 = create(:team, department: dept1)
        team2 = create(:team, department: dept2)

        expect(Team.for_department(dept1.id)).to include(team1)
        expect(Team.for_department(dept1.id)).not_to include(team2)
      end
    end
  end

  describe '#active?' do
    it 'returns true when not deactivated' do
      team = build(:team, deactivated_at: nil)
      expect(team).to be_active
    end

    it 'returns false when deactivated' do
      team = build(:team, deactivated_at: Time.current)
      expect(team).not_to be_active
    end
  end

  describe '#deactivate!' do
    it 'sets deactivated_at timestamp' do
      team = create(:team)
      expect {
        team.deactivate!
      }.to change { team.deactivated_at }.from(nil)
    end
  end

  describe '#activate!' do
    it 'clears deactivated_at timestamp' do
      team = create(:team, deactivated_at: Time.current)
      expect {
        team.activate!
      }.to change { team.deactivated_at }.to(nil)
    end
  end
end
