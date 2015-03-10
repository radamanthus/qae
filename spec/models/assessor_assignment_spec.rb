require "rails_helper"

describe AssessorAssignment do
  let(:form) { AppraisalForm }

  context "Trade award" do
    context "with Innovation fields present" do
      let(:attributes) do
        [:level_of_innovation, :extent_of_value_added, :impact_of_innovation]
      end

      it "is invalid" do
        attributes.each do |meth|
          obj = build_assignment_with(:trade, meth)
          expect(obj).to_not be_valid
          expect(obj.errors.keys).to include(form.desc(meth).to_sym)
        end
      end
    end

    context "only with Trade fields present" do
      let(:attributes) do
        [
          :overseas_earnings_growth,
          :commercial_success,
          :strategy,
          :verdict
        ]
      end

      it "is valid" do
        attributes.each do |meth|
          obj = build_assignment_with(:trade, meth)
          expect(obj).to be_valid
        end
      end
    end
  end

  context "Development award" do
    context "with Enterprise fields present" do
      let(:attributes) do
        [:nature_of_activities, :impact_achievement, :level_of_support]
      end

      it "is invalid" do
        attributes.each do |meth|
          obj = build_assignment_with(:development, meth)
          expect(obj).to_not be_valid
          expect(obj.errors.keys).to include(form.desc(meth).to_sym)
        end
      end
    end
  end

  describe "rates" do
    context "rag section" do
      context "with not allowed value" do
        subject do
          build :assessor_assignment,
                :trade,
                commercial_success_rate: "invalid"
        end
        it "is invalid" do
          expect(subject).to_not be_valid
          expect(subject.errors.keys).to include(:commercial_success_rate)
        end
      end
    end
    context "with allowed value" do
      subject do
        build :assessor_assignment,
              :trade,
              commercial_success_rate: "negative"
      end
      it "is valid" do
        expect(subject).to be_valid
      end
    end
  end

  describe "submitted_at immutability" do
    it "allows to set up submitted_at only once" do
      obj = build(:assessor_assignment)
      obj.submitted_at = DateTime.now
      obj.valid?
      expect(obj.errors).to_not include(:submitted_at)
      obj.save(validate: false)
      obj.submitted_at = DateTime.now - 1.day
      obj.valid?
      expect(obj.errors.keys).to include(:submitted_at)
    end
  end

  describe "#is_visible_for?" do
    let(:assessor1) { create(:assessor) }
    let(:assessor2) { create(:assessor) }
    let(:form_answer) { create(:form_answer) }
    let(:primary) { form_answer.assessor_assignments.primary }
    let(:secondary) { form_answer.assessor_assignments.secondary }
    before do
      primary.assessor = assessor1
      secondary.assessor = assessor2
      primary.save
      secondary.save
    end

    context "both submitted" do
      before do
        allow_any_instance_of(described_class).to receive(:submitted?).and_return(true)
      end

      it "is visible to both assessors" do
        expect(primary.is_visible_for?(assessor1)).to eq(true)
        expect(primary.is_visible_for?(assessor2)).to eq(true)
        expect(secondary.is_visible_for?(assessor1)).to eq(true)
        expect(secondary.is_visible_for?(assessor2)).to eq(true)
      end
    end

    context "none submitted" do
      before do
        allow_any_instance_of(described_class).to receive(:valid?).and_return(false)
      end

      it "is visible only for assigned assessor" do
        expect(primary.is_visible_for?(assessor1)).to eq(true)
        expect(secondary.is_visible_for?(assessor2)).to eq(true)

        expect(primary.is_visible_for?(assessor2)).to eq(false)
        expect(secondary.is_visible_for?(assessor1)).to eq(false)
      end
    end
  end
end

def build_assignment_with(award_type, meth)
  obj = build(:assessor_assignment, award_type)
  obj.public_send("#{form.desc(meth)}=", "123")
  obj
end
