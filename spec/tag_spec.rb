# -*- coding: utf-8 -*-
require 'spec_helper'

describe EasyMongoidTag do


  describe 'after included this module' do
    context 'when model class is not A Mongoid::Docutment' do
      it 'should raise a error' do
        expect { 
          class P
            include EasyMongoidTag
          end
        }.to raise_exception(RuntimeError,
                                   "EasyMongoidTag is mixined A non-mongoid_document")
        
      end
    end

    
    context "when model class is A Mongoid::Docutment" do
      before(:all) do
        class Book
          include Mongoid::Document
          include EasyMongoidTag

          easy_tag :authors
        end
      end

      it "should can response easy_tag" do
        Book.should respond_to(:easy_tag)
      end

      it "should has author_tags field" do
        Book.fields.keys.should include('author_ids')
      end

      it "author_ids's type should be Array" do
        Book.fields['author_ids'].type.should be Array
      end

      it "should stores at class attributes" do
        Book.tag_items.should include(:authors)
      end

      it "should set a index on tag field" do
        Book.should have_index_for(author_ids: 1)
      end

      describe "生成标签类" do
        context "When 标签类已经存在" do
          it "抛出异常" do
            expect do
              class ActorTag; end

              class Movie 
                include Mongoid::Document
                include EasyMongoidTag
                easy_tag :actors
              end
            end.to raise_error(RuntimeError, "Class ActorTag already existed!")

          end
        end

        context "When 标签类不存在" do
          it "should genrate tag class" do
            AuthorTag
          end

          it "标签类 应该是一个Mongoid::Document" do
            AuthorTag.included_modules.should include(Mongoid::Document)
          end
          
          it "标签类应该有 一个title field" do
            AuthorTag.fields.keys.should include('title')
          end

          it "title 的type 应该是String" do
            AuthorTag.fields['title'].type.should be String
          end

          it "应该包含一个 名为books的实例方法" do
            AuthorTag.new.should respond_to(:books)
          end
        end
      end
    end
  end
end
