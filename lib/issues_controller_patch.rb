require_dependency 'issues_controller'

module IssuesControllerPatch
    def self.included(base) # :nodoc:
    base.send(:include, InstanceMethods)

    base.class_eval do
       unloadable
       alias_method_chain :show, :patch # modify some_method method by adding your_action action
       alias_method_chain :update, :patch
    end
  end

    module InstanceMethods

        
        def show_with_patch # modified some_method
          
          @estimates = EstimateEntryQuery.build_from_params(params, :project => @project, :name => '_').results_scope(:order => "#{EstimateEntry.table_name}.id ASC").on_issue(@issue)
          @estimates_report = Redmine::Helpers::TimeReport.new(@project, @issue, params[:criteria], params[:columns], @estimates)

          @journals = @issue.journals.includes(:user, :details).reorder("#{Journal.table_name}.id ASC").all
          @journals.each_with_index {|j,i| j.indice = i+1}
          @journals.reject!(&:private_notes?) unless User.current.allowed_to?(:view_private_notes, @issue.project)
          Journal.preload_journals_details_custom_fields(@journals)
          # TODO: use #select! when ruby1.8 support is dropped
          @journals.reject! {|journal| !journal.notes? && journal.visible_details.empty?}
          @journals.reverse! if User.current.wants_comments_in_reverse_order?

          @changesets = @issue.changesets.visible.preload(:repository, :user).to_a
          @changesets.reverse! if User.current.wants_comments_in_reverse_order?

          @relations = @issue.relations.select {|r| r.other_issue(@issue) && r.other_issue(@issue).visible? }
          @allowed_statuses = @issue.new_statuses_allowed_to(User.current)
          @edit_allowed = User.current.allowed_to?(:edit_issues, @project)
          @priorities = IssuePriority.active
          @time_entry = TimeEntry.new(:issue => @issue, :project => @issue.project)
          @relation = IssueRelation.new

          respond_to do |format|
            format.html {
              retrieve_previous_and_next_issue_ids
              render :template => 'issues/show'
            }
            format.api
            format.atom { render :template => 'journals/index', :layout => false, :content_type => 'application/atom+xml' }
            format.pdf  {
              pdf = issue_to_pdf(@issue, :journals => @journals)
              send_data(pdf, :type => 'application/pdf', :filename => "#{@project.identifier}-#{@issue.id}.pdf")
            }
          end
        end

        def update_with_patch
          return unless update_issue_from_params_private
          @issue.save_attachments(params[:attachments] || (params[:issue] && params[:issue][:uploads]))
          saved = false
          begin
            saved = save_issue_with_child_records_private
          rescue ActiveRecord::StaleObjectError
            @conflict = true
            if params[:last_journal_id]
              @conflict_journals = @issue.journals_after(params[:last_journal_id]).all
              @conflict_journals.reject!(&:private_notes?) unless User.current.allowed_to?(:view_private_notes, @issue.project)
            end
          end

          if saved
            render_attachment_warning_if_needed(@issue)
            flash[:notice] = l(:notice_successful_update) unless @issue.current_journal.new_record?

            respond_to do |format|
              format.html { redirect_back_or_default issue_path(@issue) }
              format.api  { render_api_ok }
            end
          else
            respond_to do |format|
              format.html { render :action => 'edit' }
              format.api  { render_validation_errors(@issue) }
            end
          end
        end

        def update_issue_from_params_private
          @edit_allowed = User.current.allowed_to?(:edit_issues, @project)
          @time_entry = TimeEntry.new(:issue => @issue, :project => @issue.project)
          @time_entry.attributes = params[:time_entry]

          @estimate_entry = EstimateEntry.new(:issue => @issue, :project => @issue.project)
          @estimate_entry.attributes = params[:estimate_entry]

          @issue.init_journal(User.current)

          issue_attributes = params[:issue]
          if issue_attributes && params[:conflict_resolution]
            case params[:conflict_resolution]
            when 'overwrite'
              issue_attributes = issue_attributes.dup
              issue_attributes.delete(:lock_version)
            when 'add_notes'
              issue_attributes = issue_attributes.slice(:notes)
            when 'cancel'
              redirect_to issue_path(@issue)
              return false
            end
          end
          @issue.safe_attributes = issue_attributes
          @priorities = IssuePriority.active
          @allowed_statuses = @issue.new_statuses_allowed_to(User.current)
          true
        end

        def save_issue_with_child_records_private
          Issue.transaction do
            if params[:time_entry] && (params[:time_entry][:hours].present? || params[:time_entry][:comments].present?) && User.current.allowed_to?(:log_time, @issue.project)
              time_entry = @time_entry || TimeEntry.new
              time_entry.project = @issue.project
              time_entry.issue = @issue
              time_entry.user = User.current
              time_entry.spent_on = User.current.today
              time_entry.attributes = params[:time_entry]
              @issue.time_entries << time_entry
            end

            call_hook(:controller_issues_edit_before_save, { :params => params, :issue => @issue, :time_entry => time_entry, :journal => @issue.current_journal})
            if @issue.save
              call_hook(:controller_issues_edit_after_save, { :params => params, :issue => @issue, :time_entry => time_entry, :journal => @issue.current_journal})
            else
              raise ActiveRecord::Rollback
            end
          end
        end
    end
end

