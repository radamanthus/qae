class QAEFormBuilder
  class ConfirmQuestionValidator < QuestionValidator
  end

  class ConfirmQuestionBuilder < QuestionBuilder
    def text text
      @q.text = text
    end
  end

  class ConfirmQuestion < Question
    attr_writer :text

    def text
      if @text.respond_to?(:call)
        @text.call
      else
        @text
      end
    end
  end
end
