class Attachment < ActiveRecord::Base
  belongs_to :message
  
  RUBY_FORMAT = /^=rb/.freeze
#  RHTML_FORMAT = /^=rhtml/.freeze
#  RJS_FORMAT = /^=rjs/.freeze

  def cut_title
    self.title.sub(RUBY_FORMAT, '')
#    self.title.sub!(RHTML_FORMAT, '')
#    self.title.sub!(RJS_FORMAT, '')
  end

  protected
  def before_save
    set_content_type
  end

  def set_content_type
    case self.title
    when RUBY_FORMAT
      self.content_type =  'rb'
#    when RHTML_FORMAT
#      self.content_type = 'rhtml'
#    when RJB_FORMAT
#      self.content_type = 'rjs'
    else
      self.content_type = 'txt'
    end
  end
end
