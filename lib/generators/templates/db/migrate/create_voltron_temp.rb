class CreateVoltronTemp < ActiveRecord::Migration
  def change
    create_table :voltron_temps do |t|
      t.string :uuid
      t.string :file
      t.string :column
      t.boolean :multiple

      t.timestamps null: false
    end

    add_index :voltron_temps, :uuid, unique: true
  end
end
