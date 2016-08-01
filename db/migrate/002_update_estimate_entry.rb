class UpdateEstimateEntry < ActiveRecord::Migration
  def change
    add_column :estimate_entries, :is_accepted, :boolean
  end
end
