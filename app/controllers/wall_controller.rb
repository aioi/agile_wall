class WallController < ApplicationController
  unloadable

  before_filter :get_projects, :get_settings

  def index
    @users = get_project_members
    @selected_user = User.where(:login => params[:user]).first unless params[:user].blank?
    @selected_project = @projects.where(:identifier => params[:project]).first unless params[:project].blank?
    @trackers = get_valid_trackers
    @issues = get_filtered_issues(@trackers, @selected_project, @selected_user)
    @statuses = IssueStatus.where(:is_closed => false).order(:position)
  end

private

  def get_filtered_issues(trackers, project, user)
    issues = Issue.open.where(:project_id => @projects.pluck(:id), 
                              :tracker_id => trackers.pluck(:id))
    issues = issues.where(:assigned_to_id => user.id) if user
    issues = issues.where(:project_id => project.id) if project
    issues
  end

  def get_project_members
    members = @projects.map { |project| project.users }
    members.flatten.uniq.sort { |a, b| a.name <=> b.name }
  end

  def get_projects
    @project = Project.find(params[:id])
    @projects = @project.self_and_descendants
  end

  def get_settings
    @settings = Setting.plugin_agile_wall
  end

  def get_valid_trackers
    if @settings["excluded_trackers"].blank?
      Tracker.scoped
    else
      t = Tracker.arel_table
      Tracker.where(t[:name].not_in(@settings["excluded_trackers"].split(',')))
    end
  end
end
