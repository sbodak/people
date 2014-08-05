class TeamsController < ApplicationController
  include Shared::RespondsController
  expose(:team, attributes: :team_params)
  expose(:teams) { Team.all }
  expose(:users) { User.all.decorate }
  expose(:roles) { Role.all }

  before_action :authenticate_admin!, only: [:update, :create, :destroy, :new, :edit]

  def index
    gon.rabl template: 'app/views/teams/teams', as: 'teams'
    gon.rabl template: 'app/views/dashboard/users', as: 'users'
    gon.rabl template: 'app/views/dashboard/roles', as: 'roles'
    respond_to do |format|
      format.html
      format.json { render json: teams }
    end
  end

  def create
    if team.save
      respond_to do |format|
        format.html { redirect_to teams_path }
        format.json { render json: {}, status: 201 }
      end
    else
      respond_on_failure team.errors
    end
  end

  def new
  end

  def edit
  end

  def update
    if team.save
      respond_to do |format|
        format.html { redirect_to teams_path }
        format.json { render json: team, status: 202 }
      end
    else
      respond_on_failure team.errors
    end
  end

  def show
    respond_to do |format|
      format.html { redirect_to team }
      format.json { render json: team, status: 200 }
    end
  end

  def destroy
    if team.destroy
      respond_on_success teams_path
    else
      respond_on_failure team.errors
    end
  end

  private

  def team_params
    params.require(:team).permit(:name, :team_leader_id, user_ids: [], users: [])
  end
end
