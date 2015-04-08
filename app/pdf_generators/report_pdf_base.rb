require "prawn/measurement_extensions"

class ReportPdfBase < Prawn::Document
  include SharedPdfHelpers::DrawElements

  attr_reader :mode,
              :form_answer,
              :options,
              :pdf_doc,
              :missing_data_name

  def initialize(mode, form_answer=nil, options={})
    super(page_size: "A4", page_layout: :landscape)

    @pdf_doc = self
    @mode = mode
    @form_answer = form_answer
    @options = options

    generate!
  end

  def generate!
    if mode == "singular"
      render_item(form_answer)
    else
      all_mode
    end
  end
end
