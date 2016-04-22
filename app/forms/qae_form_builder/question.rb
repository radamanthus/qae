class QAEFormBuilder
  class QuestionValidator
    # multifield questions that can not be simply validated
    SKIP_PRESENCE_VALIDATION_QUESTIONS = [
      "DateQuestion",
      "AddressQuestion",
      "InnovationFinancialYearDateQuestion",
      "ByYearsQuestion",
      "ByYearsLabelQuestion",
      "UserInfoQuestion",
      "AwardHolderQuestion",
      "SupportersQuestion",
      "AwardHolderQuestion",
      "SubsidiariesAssociatesPlantsQuestion",
      "ByTradeGoodsAndServicesLabelQuestion"
    ]

    attr_reader :question

    def initialize(question)
      @question = question
    end

    def errors
      result = {}

      return {} if skip_base_validation?

      if question.required?
        if !question.input_value.present?
          result[question.hash_key] = "Can't be blank."
        end
      end

      result
    end

    private

    def skip_base_validation?
      SKIP_PRESENCE_VALIDATION_QUESTIONS.any? do |klass|
        question.delegate_obj.class.name.demodulize == klass
      end
    end

    def limit_with_buffer(limit)
      if limit > 15
        (limit + limit * 0.1).to_i + 1
      else
        limit
      end
    end
  end

  class QuestionDecorator < QAEDecorator
    def input_name options = {}
      if options[:index]
        suffix = options.fetch(:suffix)
        "#{form_name}[#{delegate_obj.key}][#{options[:index]}][#{suffix}]"
      else
        "#{form_name}[#{hash_key(options)}]"
      end
    end

    def input_value options = {}
      result = if options[:index]
        suffix = options.fetch(:suffix)
        json = answers[delegate_obj.key] || {}
        json[options[:index]][suffix]
      else
        answers[hash_key(options)]
      end

      if options[:json]
        result || {}
      else
        result
      end
    end

    def required_sub_fields
      []
    end

    def array_answer
      false
    end

    def answers
      @decorator_options.fetch(:answers)
    end

    def form_name
      @decorator_options[:form_name] || 'form'
    end

    def hash_key options = {}
      options[:suffix] ? "#{delegate_obj.key}_#{options[:suffix]}" : delegate_obj.key
    end

    def fieldset_classes
      result = ["question-block",
       "js-conditional-answer"]
      result << delegate_obj.classes if delegate_obj.classes
      result << "question-required" if delegate_obj.required
      result << "js-conditional-drop-answer" if delegate_obj.drop_condition
      result << "js-conditional-drop-block-answer" if delegate_obj.drop_block_condition
      result
    end

    def fieldset_data_hash
      result = {answer: delegate_obj.parameterized_title}
      result['drop-question'] = delegate_obj.form[delegate_obj.drop_condition].parameterized_title if delegate_obj.drop_condition
      result
    end

    def has_drops?
      if delegate_obj.drop_condition_parent.present?
        step.questions.select do |q|
          q.drop_condition.present? &&
          q.drop_condition == key
        end.any? do |q|
          q.has_drops?
        end
      end
    end

    def validate
      errors = {}

      if visible?
        error = {}

        question_class = delegate_obj.class.name.demodulize
        validator_class = "QAEFormBuilder::#{question_class}Validator".constantize

        validator = validator_class.new(self)
        errors.merge!(validator.errors)

        errors.merge!(error)
      end

      errors
    end

    def required?
      delegate_obj.required
    end

    def visible?(fetched_answers=nil)
      dc = delegate_obj.drop_condition_parent
      delegate_obj.conditions.
        all?{|condition|
          question_value = condition.question_value

          parent_question_answer = if fetched_answers.present?
            # Used in Reports::AllEntries, as passing json of answers
            # allows to make it faster
            fetched_answers[condition.question_key]
          else
            step.form[condition.question_key].input_value
          end

          if question_value == :true
            parent_question_answer.present?
          else
            parent_question_answer == question_value.to_s
          end
        } &&
      (!dc || (dc.present? && has_drops?))
    end

    def required_visible?
      required? && visible?
    end

    def required_visible_filled?
      return false unless required_visible?
      required_sub_fields.blank? ? !input_value.blank? :
        required_sub_fields.all?{|s| !input_value(suffix: s.keys.first).blank?}
    end

    def escaped_title
      r_title = ''
      title = delegate_obj.title
      pdf_title = delegate_obj.pdf_title
      main_header = delegate_obj.main_header if delegate_obj.respond_to?(:main_header)

      r_title = title if title.present?
      r_title = pdf_title if r_title.blank? && pdf_title.present?
      r_title = main_header if r_title.blank? && main_header.present?

      prepared_text(r_title)
    end

    def escaped_context
      content = if delegate_obj.pdf_context.present?
        delegate_obj.pdf_context
      else
        delegate_obj.context
      end

      prepared_text(content) if content.present?
    end

    def escaped_help(h_text)
      prepared_text(h_text)
    end

    def prepared_text(content)
      Nokogiri::HTML.parse(content).text.strip
    end

    # Detects children conditions, grouped by option
    # We us it for detecting conditional hints for Form and in PDF
    def children_conditions(questions_with_references)
      questions_with_references.map do |q|
        q.conditions.select do |c|
          c.question_key == key
        end
      end.reject { |c| c.blank? }
         .flatten
         .reject { |q| q.question_value == :true }
         .group_by { |a| a.question_value }
    end

    def can_have_conditional_hints?
      delegate_obj.is_a?(QAEFormBuilder::OptionsQuestion) ||
      delegate_obj.is_a?(QAEFormBuilder::TradeCommercialSuccessQuestion)
    end

    def conditional_hint(child_condition, questions_with_references)
      option_name = child_condition[0].to_s
                                      .split("_")
                                      .join(" ")
                                      .capitalize

      dependencies = child_condition[1].map do |c|
        parent_q = questions_with_references.detect do |q|
          q.key == c.parent_question_key
        end

        res = parent_q.ref.present? ? parent_q.ref : parent_q.sub_ref
        res.delete(' ')
      end

      generate_hint(option_name, dependencies)
    end

    def generate_hint(option_name, dependencies)
      if delegate_obj.form.title == "Sustainable Development Award Application" && delegate_obj.ref.to_s == "A 8"
        # Hardcoded condition by client request:
        #
        # "Please change Sustainable Development note in question A8 'If Yes, please answer the questions A8.1 and B7'
        # to 'If Yes, please answer both parts of question A8.1 and B7' from the print out."
        #
        "If #{option_name}, please answer both parts of question A8.1 and B7"

      elsif delegate_obj.form.title == "International Trade Award Application" &&
            delegate_obj.ref.to_s == "A 1" &&
            option_name.to_s == "Organisation"
        # Hardcoded condition by client request:
        #
        # On International Trade, Question A1 please can you remove note 'if organisation,
        # please answer the questions C4' from the print out.
        #
        # Nothing
      else
        # Normal behavior
        "If #{option_name}, please answer the questions #{dependencies.to_sentence}"
      end
    end
  end

  class QuestionBuilder
    def initialize q
      @q = q
    end

    def pdf_title text
      @q.pdf_title = text
    end

    def context text
      @q.context = text
    end

    def pdf_context text
      @q.pdf_context = text
    end

    def classes text
      @q.classes = text
    end

    def ref id
      @q.ref = id
    end

    def sub_ref id
      @q.sub_ref = id
    end

    def required
      @q.required = true
    end

    def help title, text
      @q.help << QuestionHelp.new(title, text)
    end

    def hint title, text
      @q.hint << QuestionHelp.new(title, text)
    end

    def form_hint text
      @q.form_hint = text
    end

    def conditional key, value
      @q.conditions << QuestionCondition.new(@q.key, key, value)
    end

    def drop_conditional key
      @q.drop_condition = key.to_s.to_sym
    end

    def drop_block_conditional
      @q.drop_block_condition = true
    end

    def drop_condition_parent
      @q.drop_condition_parent = true
    end

    def header header
      @q.header = header
    end

    def header_context header_context
      @q.header_context = header_context
    end

    def type_of_good type_of_good
      @q.type_of_good = type_of_good
    end
  end

  QuestionCondition = Struct.new(:parent_question_key, :question_key, :question_value)

  QuestionHelp = Struct.new(:title, :text)

  class Question
    attr_accessor :step,
                  :key,
                  :title,
                  :pdf_title,
                  :context,
                  :pdf_context,
                  :opts,
                  :required,
                  :help,
                  :hint,
                  :form_hint,
                  :ref,
                  :sub_ref,
                  :conditions,
                  :header,
                  :header_context,
                  :classes,
                  :drop_condition,
                  :drop_condition_parent,
                  :drop_block_condition,
                  :type_of_good

    def initialize step, key, title, opts={}
      @step = step
      @key = key
      @title = title
      @opts = opts
      @required = false
      @help = []
      @hint = []
      @conditions = []
      self.after_create if self.respond_to?(:after_create)
    end

    def decorate options = {}
      kls_name = self.class.name.split('::').last
      kls = QAEFormBuilder.const_get "#{kls_name}Decorator" rescue nil
      (kls || QuestionDecorator).new self, options
    end


    def form
      step.form
    end

    def parameterized_title
      key.to_s + "-" + title.parameterize
    end
  end
end
