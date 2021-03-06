require 'pathname'
require Pathname(__FILE__).dirname.parent.expand_path + 'lib/dm-simpledb'

DataMapper.setup(:default, {
  :adapter => 'simpledb',
  :access_key_id => 'access_key_id',
  :secret_access_key => 'secret_access_key',
  :domain => 'dm-simpledb_test'
})

Amazon::SDB::Base::BASE_PATH = 'http://127.0.0.1:8080/'

class Tree
  include DataMapper::Resource
  
  property :id,           String, :key => true
  property :name,         String
  property :awesomeness,  Float
end

DataMapper.auto_migrate!