class CreateConverters < ActiveRecord::Migration[5.1]
  def change
    create_table :converters do |t|
      t.string :initial_object
      t.string :commands
      t.string :initial_query
      t.string :generated_sql
      t.datetime :created_at
    end
  end
end
