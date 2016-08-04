require 'redmine'
require_relative 'lib/issues_controller_patch'
require_relative 'lib/issue_model_patch'


ActionDispatch::Callbacks.to_prepare do 
  IssuesController.send :include, IssuesControllerPatch 
end


ActionDispatch::Callbacks.to_prepare do 
  Issue.send :include, IssueModelPatch 
end

Redmine::Plugin.register :estimates do
  name 'Estimates plugin'
  author 'Nick Mikhno'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'http://http://evergreen.team'
  author_url 'http://evergreen.team'


  project_module :estimates do
    permission :view_estimates, {:estimates => [:new, :create, :index, :report]}, :public => true
    permission :edit_estimates, {:estimate_entries => [:edit, :update, :destroy, :accept]}
    permission :accept_estimates, {:estimates => :accept}
  end
end
