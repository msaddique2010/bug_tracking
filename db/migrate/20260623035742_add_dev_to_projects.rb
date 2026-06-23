class AddDevToProjects < ActiveRecord::Migration[8.1]
  def change
    add_column :projects, :dev_id, :integer
  end
end
