class CreateEstimateEntries < ActiveRecord::Migration
  def change
    create_table :estimate_entries do |t|
      t.column :project_id,  :integer,  :null => false
      t.column :user_id,     :integer,  :null => false
      t.column :issue_id,    :integer
      t.column :hours,       :float,    :null => false
      t.column :comments,    :string,   :limit => 255
      t.column :activity_id, :integer,  :null => false
      t.column :spent_on,    :date,     :null => false
      t.column :tyear,       :integer,  :null => false
      t.column :tmonth,      :integer,  :null => false
      t.column :tweek,       :integer,  :null => false
      t.column :created_on,  :datetime, :null => false
      t.column :updated_on, :datetime, :null => false
    end
    add_index :estimate_entries, [:project_id], :name =>  :estimate_entries_project_id
    add_index :estimate_entries, [:issue_id],   :name =>  :estimate_entries_issue_id
  end
end
