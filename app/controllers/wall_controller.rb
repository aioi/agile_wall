class WallController < ApplicationController
  unloadable

  before_filter :get_project, :get_settings

  def index
    @users = get_project_members
    @selected_user = User.find_by_login(params[:user]) unless params[:user].blank?
    @trackers = get_valid_trackers
    @issues = get_filtered_issues(@trackers, @selected_user)
    @statuses = IssueStatus.where(:is_closed => false).order(:position)
  end

private

  def get_filtered_issues(trackers, user)
    issues = Issue.open.where(:project_id => @project.self_and_descendants.pluck(:id), 
                     :tracker_id => trackers.pluck(:id))
    issues = issues.where(:assigned_to_id => user.id) if user
    issues
  end

  def get_project_members
    members = @project.self_and_descendants.flat_map { |project| project.users }
    members.uniq.sort { |a, b| a.name <=> b.name }
  end

  def get_project
    @project = Project.find(params[:id])
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
