class Account::CollaboratorsController < Account::BaseController
  
  before_action :require_to_be_not_current_user!, only: [:edit, :destroy]

  expose(:account) do
    current_user.account
  end
  expose(:collaborators) do
    account.collaborators_without(current_user)
  end
  expose(:collaborator) do
    collaborators.find(params[:id])
  end

  def index
    @active_step = 4
  end

  def new
    self.collaborator = User.new
  end

  def create
    self.collaborator = AddCollaborator.new(
      current_user, 
      account, 
      create_params).run
  end

  def destroy
    self.collaborator.account = nil
    self.collaborator.save
  end

  private

  def create_params
    params.require(:collaborator).permit(
      :email, 
      :role
    )
  end

  def require_to_be_not_current_user!
    if current_user.id == collaborator.id
      redirect_to root_path,
                  notice: "You can't update / remove your self in collaborators!"
    end
  end
end
