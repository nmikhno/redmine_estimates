class EstimateEntry < ActiveRecord::Base
  unloadable

  include Redmine::SafeAttributes
  # could have used polymorphic association
  # project association here allows easy loading of time entries at project level with one database trip
  belongs_to :project
  belongs_to :issue
  belongs_to :user
  belongs_to :activity, :class_name => 'TimeEntryActivity', :foreign_key => 'activity_id'

  attr_protected :project_id, :user_id, :tyear, :tmonth, :tweek

  acts_as_customizable

  default_scope {order('spent_on ASC')}

  validates_presence_of :user_id, :activity_id, :project_id, :hours, :spent_on
  validates_numericality_of :hours, :allow_nil => true, :message => :invalid
  validates_length_of :comments, :maximum => 255, :allow_nil => true
  validates :spent_on, :date => true
  before_validation :set_project_if_nil
  validate :validate_time_entry

  scope :visible, lambda {|*args|
    includes(:project).where(Project.allowed_to_condition(args.shift || User.current, :view_time_entries, *args))
  }
  scope :on_issue, lambda {|issue|
    includes(:issue).where("#{Issue.table_name}.root_id = #{issue.root_id} AND #{Issue.table_name}.lft >= #{issue.lft} AND #{Issue.table_name}.rgt <= #{issue.rgt}")
  }
  scope :on_project, lambda {|project, include_subprojects|
    includes(:project).where(project.project_condition(include_subprojects))
  }
  scope :spent_between, lambda {|from, to|
    if from && to
     where("#{EstimateEntry.table_name}.spent_on BETWEEN ? AND ?", from, to)
    elsif from
     where("#{EstimateEntry.table_name}.spent_on >= ?", from)
    elsif to
     where("#{EstimateEntry.table_name}.spent_on <= ?", to)
    else
     where(nil)
    end
  }

  safe_attributes 'hours', 'comments', 'issue_id', 'activity_id', 'spent_on', 'custom_field_values', 'custom_fields'

  def initialize(attributes=nil, *args)
    super
    if new_record? && self.activity.nil?
      if default_activity = TimeEntryActivity.default
        self.activity_id = default_activity.id
      end
      self.hours = nil if hours == 0
    end
   end

    def safe_attributes=(attrs, user=User.current)
    attrs = super
    if !new_record? && issue && issue.project_id != project_id
      if user.allowed_to?(:log_time, issue.project)
        self.project_id = issue.project_id
      end
    end
    attrs
  end

  def set_project_if_nil
    self.project = issue.project if issue && project.nil?
  end

  def validate_time_entry
    errors.add :hours, :invalid if hours && (hours < 0 || hours >= 1000)
    errors.add :project_id, :invalid if project.nil?
    errors.add :issue_id, :invalid if (issue_id && !issue) || (issue && project!=issue.project)
  end

  def hours=(h)
    write_attribute :hours, (h.is_a?(String) ? (h.to_hours || h) : h)
  end

  def hours
    h = read_attribute(:hours)
    if h.is_a?(Float)
      h.round(2)
    else
      h
    end
  end

  # tyear, tmonth, tweek assigned where setting spent_on attributes
  # these attributes make time aggregations easier
  def spent_on=(date)
    super
    if spent_on.is_a?(Time)
      self.spent_on = spent_on.to_date
    end
    self.tyear = spent_on ? spent_on.year : nil
    self.tmonth = spent_on ? spent_on.month : nil
    self.tweek = spent_on ? Date.civil(spent_on.year, spent_on.month, spent_on.day).cweek : nil
  end

  # Returns true if the time entry can be edited by usr, otherwise false
  def editable_by?(usr)
    (usr == user && usr.allowed_to?(:edit_own_time_entries, project)) || usr.allowed_to?(:edit_time_entries, project)
  end
end
