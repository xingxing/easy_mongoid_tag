# -*- coding: utf-8 -*-
require 'spec_helper'

describe EasyMongoidTag do
  describe '混入此模块' do
    context '当 混入非Mongoid::Document类' do
      it '应 抛出异常' do
        expect { 
          class P
            include EasyMongoidTag
          end
        }.to raise_exception(RuntimeError,
                             "EasyMongoidTag is mixined A non-mongoid_document")
        
      end
    end

    
    context "当 混入Mongoid::Docutment类" do
      before(:all) do
        class Book
          include Mongoid::Document
          include EasyMongoidTag

          easy_tag :authors
        end
      end
      
      describe "混入类" do
        it "应 含有类宏" do
          Book.should respond_to(:easy_tag)
        end

        it "应 有Array型标签字段" do
          Book.should have_field(:authors).of_type(Array)
        end

        it "应 在class属性tag_items中包含标签名称" do
          Book.tag_items.should include(:authors)
        end

        it "应 在标签字段上设置索引" do
          Book.should have_index_for(authors: 1)
        end

        it "应 有与tag同名的实例方法" do
          Book.new.should respond_to(:author_tags)
        end

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
          it "应 生成标签类" do
            AuthorTag
          end

          describe "标签类" do
            it "应 是一个Mongoid::Document" do
              AuthorTag.included_modules.should include(Mongoid::Document)
            end
          
            it "应 有 一个String型的title field " do
              AuthorTag.should have_field(:title).of_type(String)
            end

            it "应 在title字段上设置 唯一性索引" do
              AuthorTag.should have_index_for(title: 1).with_options(unique: true)
            end

            it "应 包含一个 反查模型的实例方法" do
              AuthorTag.new.should respond_to(:books)
            end

            it "应 包含一个 可用于模糊搜索的类方法" do
              AuthorTag.should respond_to(:search)
            end
          end
        end
      end
    end
  end
end
