module EasyMongoidTag
  module Mongoid
    module Fields
      def field name, options
        if options[:type] == EasyMongoidTag::Tag
          p "ok i'am in"
          return
        else
          super
        end
      end
    end
  end
end
