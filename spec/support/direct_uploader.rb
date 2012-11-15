# encoding: utf-8

require File.dirname(__FILE__) << "/carrier_wave_config"

class DirectUploader < CarrierWave::Uploader::Base
  include CarrierWaveDirect::Uploader
  
  def default_url
    "/assets/default-avatar-#{version_name}.png"
  end
end

