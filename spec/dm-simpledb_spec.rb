require 'pathname'
require Pathname(__FILE__).dirname.expand_path + 'spec_helper'

describe DataMapper::Adapters::SimpleDBAdapter do
  before(:each) do
    @sdb = Amazon::SDB::Base.new('access_key_id', 'secret_access_key')
    @domain = @sdb.create_domain('dm-simpledb_test')
    
    @tree = Tree.new(:name => 'Acer rubrum')
  end
  
  after(:each) do
    @sdb.delete_domain!(@domain.name)
  end
  
  it 'should create a record' do
    @tree.save.should == true
    @tree.id.should_not be_nil
    
    results = @domain.query(:expr => "['name' = 'Acer rubrum']")
    results.first[:name].should == @tree.name
  end
  
  it "should create a record with a floating point value" do
  end
  
  it 'should delete a record' do
    @tree.save
    @tree.destroy.should == true
    
    results = @domain.query(:expr => "['name' = 'Acer rubrum']")
    results.should be_empty
  end
end