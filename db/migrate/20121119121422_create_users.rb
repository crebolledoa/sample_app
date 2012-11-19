class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t| #this is called a 'block', remember
      t.string :name
      t.string :email

      t.timestamps #creates two magic columns: created_at and updated_at.
    end
  end
end
