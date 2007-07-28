class CreateMessages < ActiveRecord::Migration
  
  options = {
      :options => " "
  }
  
  def self.up
    create_table "messages" do |t|
      t.column :name, :string
      t.column :message, :string
      t.column :created_at, :datetime
    end
  end

  def self.down
    drop_table :messages
  end
end
