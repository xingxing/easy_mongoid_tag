# -*- coding: utf-8 -*-

require 'rubygems'
require 'mongoid'

# prototype
Mongoid.load!("mongodb.yml", :development)

extend ActiveSupport::Concern

class Book

  include Mongoid::Document

  field :bname, as: :book_name, type: String

  field :author_ids, type: Array
  
  field :category_ids, type: Array

  class_attribute :tag_items

  self.tag_items ||= []
  self.tag_items << :author_ids

  self.tag_items ||= []
  self.tag_items << :category_ids

  index({ author_ids: 1 })
  index({ category_ids: 1 })


  def authors 
    AuthorTag.find(*self.author_ids)
  end

  def categories
    CategryTag.find(*self.category_ids)
  end

  # before_validation do |record|
  #   p category_ids
  #   record.category_ids = category_ids.map do |t|
  #     p t
  #     if c = CategryTag.where(name: t.gsub(/\w/, '')).first
  #       c.id
  #     else
  #       CategryTag.create(name: c).id
  #     end
  #   end
  # end

end


class AuthorTag
  include Mongoid::Document

  field :name, type: String

  index({ name: 1 }, { unique: true, name: "name_index" })

  # before_validation do |record|
  #   record.name = record.name.gsub(/\W/, '')
  # end

  
  def books
    Book.where(:authors => self.id)
  end

  class << self
    def search key_word
      self.any_of(name: /.*#{key_word}.*/)
    end
  end
end

class CategryTag
  include Mongoid::Document

  include Mongoid::Timestamps::Created

  field :name, type: String

  index({ name: 1 }, { unique: true, name: "name_index" })

  # before_validation do |record|
  #   record.name = record.name.gsub(/\w/, '')
  # end

  validates :name, presence: true

  def books
    Book.where(:authors => self.id)
  end

  class << self
    def search key_word
      self.any_of(name: /.*#{key_word}.*/)
    end
  end
end

b1 = Book.find_or_create_by( :bname => '红楼梦',
                             :category_ids => [CategryTag.find_or_create_by(name: '四大名著').id, CategryTag.find_or_create_by(name: '古典文学').id] )


p b1.authors
p b1.categories

Book.create_indexes
AuthorTag.create_indexes
CategryTag.create_indexes

p CategryTag.search('四').first
#p AuthorTag.last.books.map(&:bname)
#p AuthorTag.search('西').first
#p CategryTag.search('小说').first
