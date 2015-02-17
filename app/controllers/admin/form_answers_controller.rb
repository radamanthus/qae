class Admin::FormAnswersController < Admin::BaseController
  before_filter :load_resource, only: [:withdraw, :review]

  def index
  end

  def withdraw
    @form_answer.toggle!(:withdrawn)
    redirect_to action: :index
  end

  def review
    sign_in(@form_answer.user, bypass: true)
    session[:admin_in_read_only_mode] = true

    redirect_to edit_form_path(@form_answer, anchor: "company-information")
  end

  def show
  end

  helper_method :collection

  private

  def load_resource
    @form_answer = FormAnswer.find(params[:id])
  end

  def collection
    @form_answers ||= FormAnswer.order(id: :desc).page(params[:page]).decorate
  end
end
