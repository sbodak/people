class PositionsController < ApplicationController
  include ContextFreeRepos
  include Shared::RespondsController

  expose(:position, attributes: :position_params)

  expose_decorated(:users) do
    current_user.admin? ? users_repository.all_by_name : [current_user]
  end
  expose_decorated(:roles) { roles_repository.all_by_name }

  before_filter :authenticate_for_positions!

  def new
    position.user = User.find_by(id: params[:user]) || current_user
  end

  def create
    if SavePosition.new(position).call
      SendMailWithUserJob.perform_async(
        PositionMailer, :new_position, position, current_user.id
      )
      respond_on_success user_path(position.user)
    else
      respond_on_failure position.errors
    end
  end

  def update
    if position.save
      respond_on_success user_path(position.user)
    else
      respond_on_failure position.errors
    end
  end

  def destroy
    if position.destroy
      redirect_to request.referer, notice: I18n.t('positions.success', type: 'delete')
    else
      redirect_to request.referer, alert: I18n.t('positions.error', type: 'delete')
    end
  end

  def toggle_primary
    binding.pry
    # puts "shieeet"
    # binding.pry
    #
    # position = Position.find(params[:id])
    # # authorize position
    # position.toggle!(:primary)
    # if position.primary?
    #   position.user.update(primary_role: position.role)
    #   SendMailWithUserJob.perform_async(
    #     PositionMailer, :new_primary, position, current_user.id
    #   )
    # end
    # redirect_to user_path(position.user)
  end

  private

  def authenticate_for_positions!
    binding.pry
    authorize User, :position_access?
  end

  def position_params
    params.require(:position).permit(:starts_at, :user_id, :role_id, :primary)
  end
end
