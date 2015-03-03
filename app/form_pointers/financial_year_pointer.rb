class FinancialYearPointer
  attr_reader :financial_pointer,
              :question,
              :key

  def initialize(ops = {})
    ops.each do |k, v|
      instance_variable_set("@#{k}", v)
    end

    @key = question.key
  end

  def data
    {
      key => fetch_data
    }
  end

  def fetch_data
    case question.delegate_obj
    when QAEFormBuilder::ByYearsLabelQuestion
      fetch_year_labels
    when QAEFormBuilder::ByYearsQuestion
      fetch_years
    end
  end

  def fetch_year_labels
    entries.push(latest_year_label)
  end

  def fetch_years
    active_fields.map do |field|
      value = entry(field)
      {
        value: value.present? ? value : FormFinancialPointer::IN_PROGRESS,
        name: "#{key}_#{field}"
      }
    end
  end

  def active_fields
    question.decorate(answers: financial_pointer.filled_answers).
             active_fields
  end

  def entries
    question.active_fields[0..-2].map do |field|
      FormFinancialPointer::YEAR_LABELS.map do |year_label|
        entry(field, year_label)
      end
    end
  end

  def entry(field, year_label = nil)
    entry = financial_pointer.filled_answers.detect do |k, _v|
      k == "#{key}_#{field}#{year_label}"
    end

    entry[1] if entry.present?
  end

  def latest_year_label
    [
      "0" + financial_pointer.filled_answers["financial_year_date_day"],
      financial_pointer.filled_answers["financial_year_date_month"],
      Date.today.year
    ]
  end
end