class WallController < ApplicationController
  unloadable

  before_filter :get_projects, :get_settings

  def index
    @selected_user = Principal.find(params[:user]) unless params[:user].blank?
    @selected_project = @projects.where(:identifier => params[:project]).first unless params[:project].blank?
    @trackers = get_valid_trackers
    @issues, @users = get_issues_and_assignees(@trackers, @selected_project, @selected_user)
    @statuses = IssueStatus.where(:is_closed => false).order(:position)
  end

private

  def get_issues_and_assignees(trackers, project, user)
    issues = Issue.open.where(:project_id => @projects.pluck(:id), 
                              :tracker_id => trackers.pluck(:id))
    issues = issues.where(:project_id => project.id) if project
    assignees = issues.map { |issue| issue.assigned_to }
    assignees = assignees.flatten.uniq.compact.sort { |a, b| a.name <=> b.name }
    issues = issues.where(:assigned_to_id => user.id) if user
    [issues, assignees]
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
