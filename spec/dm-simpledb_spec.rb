require 'pathname'
require Pathname(__FILE__).dirname.expand_path + 'spec_helper'

describe DataMapper::Adapters::SimpleDBAdapter do
  before(:each) do
    @tree = Tree.new(:name => 'Acer rubrum')
  end
  
  it 'should create a record' do
    @tree.save.should be_true
    @tree.id.should_not be_nil
    @tree.destroy
  end
end