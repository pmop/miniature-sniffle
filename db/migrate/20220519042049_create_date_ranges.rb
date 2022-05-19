class CreateDateRanges < ActiveRecord::Migration[7.0]
  def change
    create_table :date_ranges do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.date :start_date
      t.date :end_date
      t.string :created_by

      t.timestamps
    end
  end
end
