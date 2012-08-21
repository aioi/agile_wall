class WallController < ApplicationController
  unloadable

  before_filter :get_settings

  def index
    @project = Project.find(params[:id])
    @projects = @project.self_and_descendants
    @statuses = IssueStatus.where(:is_closed => false).order(:position)
    @issues = Issue.open.where(
        :project_id => @projects.pluck(:id), 
        :tracker_id => get_valid_trackers.pluck(:id)
      )
  end

private

  def get_settings
    @settings = Setting.plugin_agile_wall
    @settings["excluded_trackers"] = @settings["excluded_trackers"].split(",")
  end

  def get_valid_trackers
    if @settings["excluded_trackers"].blank?
      Tracker.all
    else
      t = Tracker.arel_table
      Tracker.where(t[:name].not_in(@settings["excluded_trackers"]))
    end
  end
end
