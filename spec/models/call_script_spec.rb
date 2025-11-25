require 'rails_helper'

RSpec.describe CallScript, type: :model do
  describe 'validations' do
    subject { build(:call_script) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:call_type) }
    it { is_expected.to validate_presence_of(:content) }
    it { is_expected.to validate_presence_of(:department_id) }
    it { is_expected.to validate_length_of(:name).is_at_least(3).is_at_most(200) }
    it { is_expected.to validate_length_of(:content).is_at_least(10) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:department) }
    it { is_expected.to have_many(:call_recordings).dependent(:nullify) }
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:call_type).with_values(sales: 0, support: 1, survey: 2, other: 3) }
  end

  describe 'auditing' do
    it 'is audited' do
      expect(CallScript.new).to respond_to(:audits)
    end
  end

  describe 'scopes' do
    describe '.active' do
      it 'returns only active scripts' do
        active_script = create(:call_script, active: true)
        inactive_script = create(:call_script, active: false)

        expect(CallScript.active).to include(active_script)
        expect(CallScript.active).not_to include(inactive_script)
      end
    end

    describe '.for_department' do
      it 'returns scripts for specific department' do
        dept1 = create(:department, name: 'Sales')
        dept2 = create(:department, name: 'Bank')
        script1 = create(:call_script, department: dept1)
        script2 = create(:call_script, department: dept2)

        expect(CallScript.for_department(dept1.id)).to include(script1)
        expect(CallScript.for_department(dept1.id)).not_to include(script2)
      end
    end

    describe '.by_call_type' do
      it 'returns scripts of specific call type' do
        sales_script = create(:call_script, call_type: :sales)
        support_script = create(:call_script, call_type: :support)

        expect(CallScript.by_call_type('sales')).to include(sales_script)
        expect(CallScript.by_call_type('sales')).not_to include(support_script)
      end
    end
  end

  describe '#deactivate!' do
    it 'sets active to false' do
      script = create(:call_script, active: true)
      expect {
        script.deactivate!
      }.to change { script.active }.from(true).to(false)
    end
  end

  describe '#activate!' do
    it 'sets active to true' do
      script = create(:call_script, active: false)
      expect {
        script.activate!
      }.to change { script.active }.from(false).to(true)
    end
  end
end
