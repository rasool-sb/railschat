class Message < ActiveRecord::Base
  has_one :attachment

  COMMENT_FORMAT = /^#|^＃/.freeze
  validates_exclusion_of :name, :in => %w(System)

  def permlinkable?
    self.public? && (not self.new_record?)
  end

  def system?
    name == "System"
  end

  def offreco?
    ! system? && ! permlinkable?
  end

  protected
  def before_save
    comment_out
  end

  def comment_out
    self.public = false if ( COMMENT_FORMAT === self.message )
    true
  end
end
