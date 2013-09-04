# -*- coding: utf-8 -*-
require 'spec_helper'

describe "功能" do
  before(:all) do
    Mongoid.load!("/Users/wade/RubyLab/easy_mongoid_tag/spec/mongodb.yml", :test)

    class Model
      include Mongoid::Document
      include EasyMongoidTag
      
      field :bname, as: :book_name, type: String
      easy_tags :tests
    end

    @book1 = Model.create(bname: '红楼梦', :tests => ['曹雪芹 ', ' 高 鹗 '])
    @book2 = Model.create(bname: '石头记', :tests => ['曹沾', '高 鹗'])
  end
  
  it "应 可以找到 所有的标签" do
    @book1.test_tags.map{|tag| tag.title }.should  include('曹雪芹', '高 鹗') 
    @book2.test_tags.map{|tag| tag.title }.should include('曹沾', '高 鹗')
  end

  it "应 可以通过标签得到 model" do
    TestTag.find_by(title: '曹雪芹').models.map(&:book_name).should include('红楼梦')
    TestTag.find_by(title: '曹沾').models.map(&:book_name).should include('石头记')
  end


  it "应 标签搜索" do
    TestTag.search('曹').map(&:title).should include('曹雪芹', '曹沾')
  end

end
