class CreateConverters < ActiveRecord::Migration[5.1]
  def change
    create_table :converters do |t|
      t.string :model_name
      t.string :commands
      t.string :initial_query
      t.string :generated_sql
      t.datetime :created_at
    end
  end
end
