require 'active_record'
require 'sqlite3'
require 'pry'

ActiveRecord::Base.establish_connection({
  adapter: 'sqlite3',
  database: 'hr.sqlite3'

  })

  class InitialMigration < ActiveRecord::Migration[5.0]

    def change
      
      create_table :employees do |t|
        t.string :name
        t.string :email
        t.string :phone
        t.integer :salary
        t.text :review
        t.boolean :satisfactory
        t.integer :department_id
      end

      create_table departments do |t|
        t.string :name
      end

    end

  end
