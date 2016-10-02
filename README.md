# Redmine Estimates Plugin

This is Redmine plugin for multiple estimates entries for a single task

## Installing a plugin

1. 
   * Copy your plugin directory into #{RAILS_ROOT}/plugins (Redmine 2.x) 
   or #{RAILS_ROOT}/vendor/plugins (Redmine 1.x). 
   * If you are downloading the plugin directly from GitHub, you can do so by changing into your plugin directory and issuing a command like 

    ```
    git clone https://github.com/nmikhno/redmine_estimates.git
    ```

2. The plugin requires a migration, run the following command in #{RAILS_ROOT} to upgrade your database (make a db backup before).

   For Redmine 2.x:
    
    ```
    bundle exec rake redmine:plugins:migrate RAILS_ENV=production
    ```
   
   ####NOTE: 
   
    - the pluging has been tested on Redmine 2.1.x
    - the plugin hasn't been tested on Redmine 3.x 

3. Restart Redmine

You should now be able to see the plugin list in Administration -> Plugins and configure the newly installed plugin.

Now you shold be able to add and manage issues estimates.


![issue_view](https://sc-cdn.scaleengine.net/i/9ab4f1fd2e693ea440eed4a9ab54124a.png "Issue view")

Check out some permission for user's roles.

![issue_view](https://sc-cdn.scaleengine.net/i/c97cfe6ea43807d2bf3fb560cc1e38ce.png "User permissions")
