FactoryGirl.define do
  factory :assessor_assignment do
    form_answer

    trait :trade do
      form_answer { create(:form_answer, :trade) }
    end

    trait :development do
      form_answer { create(:form_answer, :development) }
    end

    trait :submitted do
      submitted_at DateTime.now - 1.minute
    end
  end

  factory :assessor_assignment_moderated, class: AssessorAssignment do
    form_answer
    position "moderated"
  end
end
