class CreateSubmissions < ActiveRecord::Migration[8.0]
  def change
    create_table :submissions do |t|
      t.string :applicant_name, null: false
      t.string :applicant_email, null: false
      t.string :entity_type, null: false
      t.string :years_active
      t.string :annual_revenue
      t.string :urgent_need
      t.string :county
      t.string :np_years_active
      t.string :serves_youth
      t.string :household_income
      t.string :veteran
      t.string :outcome, null: false
      t.string :status, null: false
      t.text :reason, null: false
      t.text :decision_path_json, null: false, default: '[]'
      t.timestamps
    end

    add_index :submissions, :entity_type
    add_index :submissions, :outcome
    add_index :submissions, :status
    add_index :submissions, :created_at
  end
end
