class Photo < ActiveRecord::Base
	belongs_to :user


	has_attached_file :image, :styles => { :large => "600x600>", :medium => "400x400>", :small => "50x50>" }, :default_url => "/images/:style/missing.png"
  	validates_attachment_content_type :image, :content_type => /\Aimage\/.*\Z/
end

