module WallHelper
  def filter_issues_by_status(status)
    @issues.where(:status_id => status.id).order(:project_id, "issues.id")    
  end
end
