class AddPublicColumn < ActiveRecord::Migration
  def self.up
    add_column :messages, :public, :boolean, :default => true, :null => false
  end

  def self.down
    remove_column :messages, :public
  end
end
