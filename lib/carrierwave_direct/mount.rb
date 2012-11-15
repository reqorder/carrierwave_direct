# encoding: utf-8

module CarrierWaveDirect

  module Mount
    def mount_uploader(column, uploader=nil, options={}, &block)
      super

      # Don't go further unless the class included CarrierWaveDirect::Uploader
      return unless uploader.ancestors.include?(CarrierWaveDirect::Uploader)

      uploader.class_eval <<-RUBY, __FILE__, __LINE__+1
        def #{column}; self; end
      RUBY

      self.instance_eval <<-RUBY, __FILE__, __LINE__+1
        attr_accessor :remote_#{column}_net_url
      RUBY

      mod = Module.new
      include mod
      mod.class_eval <<-RUBY, __FILE__, __LINE__+1

        def key
          @key
        end

        def key=(k)
          @key = k
        end

        def #{column}_key
          send(:#{column}).key
        end

        def #{column}_key=(k)
          send(:#{column}).key = k
          key = k
        end

        def has_#{column}_upload?
          send(:#{column}).has_key?
        end

        def has_remote_#{column}_net_url?
          send(:remote_#{column}_net_url).present?
        end
        
        def #{column}_url(*args)
          if respond_to?('processing_#{column}?') && processing_#{column}?
            # stub version name just of current uploader instance and return args.first
            eval("class << _mounter(:#{column}).uploader; def version_name; " + args.first.inspect + "; end; end")
            
            _mounter(:#{column}).uploader.default_url
          else
            _mounter(:#{column}).url(*args)
          end
        end
      RUBY
    end
  end
end

