class CreateFeatures < ActiveRecord::Migration
  def change
    create_table :features do |t|
      t.string :time
      t.string :concentration
      t.string :lat
      t.string :lon

      t.timestamps
    end
  end
end
