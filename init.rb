Redmine::Plugin.register :agile_wall do
  name 'Agile Wall plugin'
  author 'Aioi Insurance Co., Pty Ltd'
  description 'Provides a visual agile wall'
  version '0.0.1'

  settings :default => {
    'excluded_trackers' => ''
  }, :partial => 'settings/edit'

  project_module :agile_wall do
    permission :agile_wall, { :wall =>  [:index] }, :public => true 
  end

  menu :project_menu, :wall, { :controller => 'wall', :action => 'index' }, 
      :caption => :tab_label, :after => :new_issue
end
