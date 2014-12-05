require 'spec_helper'

RSpec.describe Eligibility::Innovation, :type => :model do
  let(:user) { FactoryGirl.create(:user) }

  context 'answers storage' do
    it 'saves and reads answers' do
      eligibility = Eligibility::Innovation.new(user: user)
      eligibility.innovative_product = '1'

      expect { eligibility.save! }.to change {
        Eligibility::Innovation.count
      }.by(1)

      eligibility = Eligibility::Innovation.last

      expect(eligibility.user).to eq(user)
      expect(eligibility).to be_innovative_product
    end
  end

  describe '#eligible?' do
    let(:eligibility) { Eligibility::Innovation.new(user: user) }

    it 'is not eligible by default' do
      expect(eligibility).not_to be_eligible
    end

    it 'is eligible when all questions are answered correctly' do
      eligibility.innovative_product = true
      eligibility.was_on_market_for_two_years = true
      eligibility.continuous_innovation_for_five_years = true

      expect(eligibility).to be_eligible
    end

    it 'is not eligible when not all answers are correct' do
      eligibility.innovative_product = true
      eligibility.was_on_market_for_two_years = false
      eligibility.continuous_innovation_for_five_years = true

      expect(eligibility).not_to be_eligible
    end
  end
end
