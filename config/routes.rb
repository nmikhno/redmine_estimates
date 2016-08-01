# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
 get 'estimate_entries', :to => 'estimates#index'
 # get 'estimate_entries/new', :to => 'estimates#new'
 
 resources :estimate_entries, :controller => 'estimates', :except => :destroy do
    collection do
      get 'report'
      get 'bulk_edit'
      post 'bulk_update'
    end
  end
  match '/estimate_entries/:id', :to => 'estimates#destroy', :via => :delete, :id => /\d+/
  # TODO: delete /estimate_entries for bulk deletion
  match '/estimate_entries/destroy', :to => 'estimates#destroy', :via => :delete
  # match '/issues/:issue_id/estimate_entries', :to => 'estimates#create', :via => :post, :issue_id => /\d+/

	resources :issues do
		resources :estimate_entries, :controller => 'estimates' do
		  collection do
		    get 'report'
        # get 'new'
        post 'new'
        
		  end
		end
	end

  resources :projects do
    resources :estimate_entries, :controller => 'estimates' do
      get 'report', :on => :collection
    end
  end

