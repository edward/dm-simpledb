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
    @tree.should_not be_a_new_record
    @tree.should_not be_dirty
    
    results = @domain.query(:expr => "['name' = 'Acer rubrum']")
    results.first[:name].should == @tree.name
  end
  
  it "should create a record with a floating point value" do
    @tree.awesomeness = 8.7
    @tree.save
    @tree.reload
    @tree.awesomeness.should == 8.7
  end
  
  it 'should delete a record' do
    @tree.save
    @tree.destroy.should be_true
    @tree.should be_a_new_record
    @tree.should be_dirty
    
    results = @domain.query(:expr => "['name' = 'Acer rubrum']")
    results.should be_empty
  end
  
  it "should read_many records" do
  end
  
  it "should read_one record" do
    @tree.save
    @tree.should == Tree.get(@tree.id)
  end
  
  it "should update a record" do
    @tree.save
    
    @tree = Tree.get(@tree.id)
    @tree.name = "Pine"
    
    @tree.should_not be_a_new_record
    @tree.should be_dirty
    
    @tree.save
    @tree.should_not be_dirty
    
    tree = Tree.get(@tree.id)
    @tree.should == tree
  end
  
  it 'should respond to Resource#get' do
    attributes = Multimap.new {:id => "Maple"}
    @domain.put_attributes("some key", attributes)
    
    tree = Tree.get(attributes[:id])

    tree.should_not be_nil
    tree.should_not be_dirty
    tree.should_not be_a_new_record
    tree.id.should == id
  end
  
  describe "querying metadata" do
    before do
      @adapter = repository(:default).adapter
    end
    
    it "should destroy model storage" do
      @adapter.destroy_model_storage(repository(:default), Tree)
      @adapter.storage_exists?("trees").should == false
    end
    
    it "should create model storage" do
      Tree.auto_migrate!
      @adapter.storage_exists?("trees").should == true
    end
    
    it "should be able to check if storage exists" do
      @sdb.delete_domain!("trees")
      @adapter.storage_exists?("trees").should == false
      
      @sdb.create_domain("trees")
      @adapter.storage_exists?("trees").should == true
    end

    # TODO - add mass field removals?
    #   It wouldn't be such a big deal to just not access those extra 
    #   attributes that come down, and the SimpleDB writing process 
    #   dynamically adds attributes/fields on the fly.
    # 
    #   It *might* be a good idea to do a quick sanity check to ensure
    #   that we’re not adding too many fields, but that might excessive.
    # 
    # it "#upgrade_model_storage should work" do
    #   @adapter.destroy_model_storage(repository(:default), Tree)
    #   @adapter.storage_exists?("trees").should == false
    #   Tree.auto_migrate!
    #   @adapter.storage_exists?("trees").should == true
    #   
    #   @adapter.field_exists?("trees", "new_prop").should == false
    #   Tree.property :new_prop, Integer
    #   Tree.auto_upgrade!
    #   @adapter.field_exists?("trees", "new_prop").should == true
    # end
  end
end