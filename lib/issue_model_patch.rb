require_dependency 'issue'

module IssueModelPatch
    def self.included(base) # :nodoc:
    base.send(:include, InstanceMethods)

	    base.class_eval do
	       unloadable
  		   has_many :estimate_entries, :dependent => :destroy, 
  		   :class_name => 'EstimateEntry'

	  	end
	end

	module InstanceMethods
		  def total_estimate_hours
		    @total_estimate_hours ||=
		      self_and_descendants.
		        joins("LEFT JOIN #{EstimateEntry.table_name} ON #{EstimateEntry.table_name}.issue_id = #{Issue.table_name}.id")
		        .sum("#{EstimateEntry.table_name}.hours").to_f || 0.0
		  end

		  def total_accepted_estimate_hours
		    @total_accepted_estimate_hours ||=
		      self_and_descendants.
		        joins("LEFT JOIN #{EstimateEntry.table_name} ON #{EstimateEntry.table_name}.issue_id = #{Issue.table_name}.id")
		        .where("#{EstimateEntry.table_name}.is_accepted = 1")
		        .sum("#{EstimateEntry.table_name}.hours").to_f || 0.0
		  end		  
	end
end