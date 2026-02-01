class CreateBugs < ActiveRecord::Migration[8.1]
  def change
    create_table :bugs do |t|
      t.references :project, null: false, foreign_key: true
      t.text :title
      t.date :deadline
      t.string :bug_type
      t.string :status

      t.timestamps
    end
  end
end
