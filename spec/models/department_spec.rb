require 'rails_helper'

RSpec.describe Department, type: :model do
  describe 'validations' do
    subject { build(:department) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
    it { is_expected.to validate_length_of(:name).is_at_least(2).is_at_most(100) }
  end

  describe 'associations' do
    it { is_expected.to have_many(:teams).dependent(:destroy) }
    it { is_expected.to have_many(:call_scripts).dependent(:destroy) }
    it { is_expected.to have_many(:users).through(:teams) }
  end

  describe 'auditing' do
    it 'is audited' do
      expect(Department.new).to respond_to(:audits)
    end
  end

  describe '#active?' do
    it 'returns true when not deactivated' do
      department = build(:department, deactivated_at: nil)
      expect(department).to be_active
    end

    it 'returns false when deactivated' do
      department = build(:department, deactivated_at: Time.current)
      expect(department).not_to be_active
    end
  end

  describe '#deactivate!' do
    it 'sets deactivated_at timestamp' do
      department = create(:department)
      expect {
        department.deactivate!
      }.to change { department.deactivated_at }.from(nil)
    end

    it 'persists the change' do
      department = create(:department)
      department.deactivate!
      expect(department.reload).not_to be_active
    end
  end

  describe '#activate!' do
    it 'clears deactivated_at timestamp' do
      department = create(:department, deactivated_at: Time.current)
      expect {
        department.activate!
      }.to change { department.deactivated_at }.to(nil)
    end
  end
end
