class Gallery < ActiveRecord::Base
  has_many :pictures, :dependent => :destroy do
    def enable_size
      count :conditions => "status = 't'"
    end
  end

  validates_presence_of :name, :message => 'is needed for your gallery'
  validates_uniqueness_of :name, :message => 'is already use. Change it'

  before_create :define_permalink

  def define_permalink
    self.permalink = name.downcase.gsub(/[^a-z0-9]+/i, '-') if permalink.blank?
  end

  def to_param
    permalink
  end

end
