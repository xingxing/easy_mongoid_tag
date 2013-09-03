# -*- coding: utf-8 -*-
module  EasyMongoidTag

  def self.included mod
    unless mod.included_modules.include?(Mongoid::Document)
      raise(RuntimeError, 'EasyMongoidTag is mixined A non-mongoid_document') 
    else
      mod.class_eval do 
        extend ClassMethods

        # 存储 tag 的名字
        class_attribute :tag_items
        self.tag_items = []

      end
    end
  end

  module ClassMethods

    # 生成 标签field
    # @param[Symbol]
    def easy_tag tag_name
      field_name = Helper.field_name(tag_name)

      field field_name, type: Array
      self.tag_items << tag_name
      index({ field_name => 1 })

      generate_tag_class(tag_name)

      # self.class_eval do
      #   define_method(Helper.tag_list_name(tag_name)) do
          
      #   end
      # end
    end

    def easy_tags *tag_names
    end

    # 生成标签类
    # 
    def generate_tag_class tag_name

      tag_class_name = Helper.tag_class_name(tag_name)
      field_name     = Helper.field_name(tag_name)

      if Helper.class_existed?(tag_class_name)
        raise(RuntimeError, "Class #{tag_class_name} already existed!")
      else
        # model 类的
        main_class_name = self.name
        Object.const_set(tag_class_name, Class.new do
                           include Mongoid::Document
                           field :title, type: String

                           define_method main_class_name.downcase.pluralize do
                             self.class.where(field => self.id)
                           end

                           class << self
                             
                           end
                         end)
      end
    end
  end


  module Helper

    include ActiveSupport::Concern

    class << self

      # tag_name 是复数数形式
      # filed_name = tag_name的单数形式 + "_ids"
      def field_name tag_name
        "#{tag_name.to_s.singularize}_ids".to_sym
      end

      # tags_list_name = 'list_' + tag_name
      def tag_list_name tag_name
        "list_#{tag_name}".to_sym
      end

      # 标签类的类名 
      # @return [String]
      def tag_class_name tag_name
        tag_name.to_s.classify + 'Tag'
      end

      # 
      def class_existed? class_name
        klass = Module.const_get(class_name)
        return klass.is_a?(Class)
      rescue NameError
        return false
      end
    end

  end
end
