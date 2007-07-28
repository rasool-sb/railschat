class CreateAttachments < ActiveRecord::Migration
  def self.up
    create_table :attachments do |t|
      t.column :title, :string
      t.column :body, :text
      t.column :content_type, :string, :default => 'text'
      t.column :message_id, :integer
    end
  end

  def self.down
    drop_table :attachments
  end
end
