require 'pry'
require './db_connection'

  class InitialMigration < ActiveRecord::Migration[5.0]

    def change

      create_table :departments do |t|
        t.string :name
      end

      create_table :employees do |t|
        t.string :name
        t.string :email
        t.string :phone
        t.integer :salary
        t.text :review
        t.boolean :satisfactory
        t.integer :department_id
      end

    end

  end
