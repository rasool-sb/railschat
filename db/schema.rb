# This file is autogenerated. Instead of editing this file, please use the
# migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.

ActiveRecord::Schema.define(:version => 3) do

  create_table "attachments", :force => true do |t|
    t.column "title",        :string
    t.column "body",         :text
    t.column "content_type", :string,  :default => "text"
    t.column "message_id",   :integer
  end

  create_table "messages", :force => true do |t|
    t.column "name",       :string
    t.column "message",    :string
    t.column "created_at", :datetime
    t.column "public",     :boolean,  :default => true, :null => false
  end

end