require 'redmine'
require_relative 'lib/issues_controller_patch'
require_relative 'lib/issue_model_patch'
require_relative 'lib/issue_query_patch'

ActionDispatch::Callbacks.to_prepare do
  IssuesController.send :include, IssuesControllerPatch
end

ActionDispatch::Callbacks.to_prepare do
  Issue.send :include, IssueModelPatch
end

ActionDispatch::Callbacks.to_prepare do
  IssueQuery.send :include, IssueQueryPatch
end

Redmine::Plugin.register :redmine_estimates do
  name 'Estimates plugin'
  author 'Nick Mikhno'
  description 'This is Redmine plugin for multiple estimate entries for a single task'
  version '0.9'
  url 'http://evergreen.team'
  author_url 'http://evergreen.team'

  permission :view_estimates, {:estimates => [:new, :create, :index, :report]}, :public => true
  permission :edit_estimates, {:estimates => [:edit, :update, :destroy, :accept]}
  permission :accept_estimates, {:estimates => :accept}
end
