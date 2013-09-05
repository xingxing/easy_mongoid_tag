class Book

  include Mongoid::Document

  include EasyMongoidTag

  easy_tags :authors, :categries

  field :bname, as: :book_name
  
end
