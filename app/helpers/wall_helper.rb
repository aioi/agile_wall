module WallHelper
  def filter_issues_by_status(status)
    @issues.where(:status_id => status.id).order(:project_id, "issues.id")    
  end

  def field_select_filter(field, collection, option_value_field, option_label_field, selected_value)
    select_tag field, 
        options_from_collection_for_select(
            collection, option_value_field, option_label_field, selected_value), 
        :include_blank => true,
        :onchange => "$('#filter_form').submit();"    
  end
end
