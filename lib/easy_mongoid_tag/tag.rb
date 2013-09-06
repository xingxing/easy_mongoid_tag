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

      tag_class = generate_tag_class(tag_name)

      self.instance_eval do
        define_method Helper.tags_method_name(tag_name) do
          tag_class.find(*self.send(field_name))
        end
      end

      before_validation do |doc|
        doc.send("#{field_name}=",
                 doc[tag_name].map do |title_or_object_id|
                   if title_or_object_id.is_a? Moped::BSON::ObjectId
                     title_or_object_id
                   else
                     title_or_object_id.strip!
                     tag = tag_class.where(title: title_or_object_id).first
                     if tag
                       tag.id
                     else
                       tag = tag_class.new(title: title_or_object_id)
                       tag.save ? tag.id : nil
                     end
                   end
                 end.select(&:present?)) if doc[tag_name] 
      end
    end

    def easy_tags *tag_names
      tag_names.each do |tag_name|
        easy_tag tag_name
      end
    end

    # 生成标签类
    # 
    def generate_tag_class tag_name

      tag_class_name = Helper.tag_class_name(tag_name)
      field_name     = Helper.field_name(tag_name)

      if Helper.class_existed?(tag_class_name)
        raise(RuntimeError, "Class #{tag_class_name} already existed!")
        return
      else
        # model 类的
        main_class_name = self.name
        Object.const_set(tag_class_name,
                         Class.new do
                           include Mongoid::Document
                           include Mongoid::Timestamps::Created

                           store_in collection: tag_class_name.tableize

                           field :title, type: String
                           index({ title: 1 }, { unique: true })

                           define_method main_class_name.downcase.pluralize do
                             Object.const_get(main_class_name).where(field_name => self.id)
                           end

                           class << self 
                             def search key_word
                               self.any_of(title: /.*#{key_word}.*/)
                             end
                           end

                           before_validation do |record|
                             record.title = record.title.strip
                           end
                           
                           after_destroy do |record|
                             record.send(main_class_name.downcase.pluralize).each do |model|
                               Object.const_get(main_class_name).skip_callback(:validation, :before)
                               model.send("#{field_name}=", model.send(field_name).reject{|t| t == record.id } )
                               model.save
                               Object.const_get(main_class_name).set_callback(:validation, :before)
                             end
                           end

                end)
      end
    end
  end


  module Helper

    include ActiveSupport::Concern

    class << self

      def field_name tag_name
        tag_name.to_sym
      end

      def tags_method_name tag_name
        "#{tag_name.to_s.singularize}_tags".to_sym
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

      # 是否已经存在 类
      # @param [ String ] 类名
      def class_existed? class_name
        klass = Module.const_get(class_name)
        return klass.is_a?(Class)
      rescue NameError
        return false
      end
    end

  end
end
