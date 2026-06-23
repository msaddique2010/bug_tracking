class AddFieldsAndProjectUsers < ActiveRecord::Migration[8.1]
  def change
    # Add user_type to users
    add_column :users, :user_type, :string

    # Add description and developer_id to bugs
    add_column :bugs, :description, :text
    add_column :bugs, :developer_id, :integer
    add_index :bugs, :developer_id

    # Create project_users join table
    create_table :project_users do |t|
      t.references :project, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
