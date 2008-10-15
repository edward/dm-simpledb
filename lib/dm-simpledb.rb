require 'rubygems'
require 'dm-core'
require 'amazon_sdb'
require 'digest/sha2'

module DataMapper
  module Adapters
    class SimpleDBAdapter < AbstractAdapter
      
      def create(resources)
        created = 0
        resources.each do |resource|
          resource_type = resource_type_for(resource)
          
          # FIXME - I have to check for attribute types and use Multimap#numeric 
          # in order to not screw when dealing with Floats.
          # attributes_to_convert = resource.model.properties.select do |property|
          #   property.type == Float
          # end
          
          # FIXME - also need to find some way of dealing with the Serial Property
          # A Resource with an auto-incrementing id won’t auto-increment
          
          # TODO - Ensure there's only one key
          
          resource.id ||= key_for(resource)
          attributes = resource.attributes.merge(:_sdb_resource => resource.model)
          
          # FIXME - This isn't "serial" per se, but it is an automatically created identifier
          # TODO - create a DataMapper::Types::SimpleDB::Key or something to placate OCDers
          # if resource.model.properties[:id] &&
          #    resource.model.properties[:id].type == DataMapper::Types::Serial
          #    
          #    resource.attributes[:_sdb_key] = key
          # end
          
          domain.put_attributes(resource.id, Amazon::SDB::Multimap.new(attributes))
          created += 1
        end
        created
      end

      def read_many(query)
        raise NotImplementedError
      end

      def read_one(query)
        raise NotImplementedError
      end

      def update(attributes, query)
        raise NotImplementedError
      end

      def delete(query)
        deleted = 0
        
        # The value is assumed to be the sdb key:
        # [:eql, #<Property:Tree:id>, "cf17c91somethingreallylong"]
        operation, property, value = query.conditions.first
        
        if operation != :eql
          raise NotImplementedError.new('Only singular "give me an id and I\'ll delete that entry" deletes currently supported. DataMapper refers to these options as :eql')
        end
        
        domain.delete_attributes(value)
        deleted += 1
        
        deleted
      end
      
      private
      
      def sdb
        @sdb ||= Amazon::SDB::Base.new(@uri[:access_key_id], @uri[:secret_access_key])
      end
      
      def domain
        @domain ||= sdb.domain(@uri[:domain])
      end
      
      ## 
      # Returns a unique String based on a resource and a random salt
      # 
      # @param [DataMapper::Resource] resource to determine a hash key for
      # @return [String] a unique key
      def key_for(resource)
        key = rand.to_s + Time.now.to_s
        key += resource_type_for(resource)
        key += resource.attributes.to_s
        Digest::SHA512.hexdigest(key)
      end
      
      ## 
      # Returns a String to be used in STI (Single Domain Inheritance? SDI?).
      # 
      # @param [DataMapper::Resource] resource to find a type name for
      # @return [String] the resource type name
      def resource_type_for(resource)
        resource.model.storage_name(resource.repository.name)
      end
      
      # Would be awesome, but would only help once multi-domain queries are easy
      # or supported in other ways with this library.
      # def domain_for(resource)
      #   sdb.domain(resource.model.storage_name(resource.model.repository.name))
      # end
      
      module Migration
        #
        # Returns whether the storage_name exists.
        #
        # @param storage_name<String> a String defining the name of a storage,
        #   for example a table name.
        #
        # @return <Boolean> true if the storage exists
        def storage_exists?(storage_name)
          sdb.domains.detect {|d| d.name == storage_name }
        end
        
        # TODO: move to dm-more/dm-migrations
        def create_model_storage(repository, model)
          sdb.create_domain(@uri[:domain])
        end

        # TODO: move to dm-more/dm-migrations
        def destroy_model_storage(repository, model)
          sdb.delete_domain!(@uri[:domain])
        end
        
        module SQL
          def supports_serial?
            false
          end
        end
        
        include SQL
        
      end # module Migration
      
      include Migration
    end # class SimpleDBAdapter
    
    # Comply with DataMapper module naming scheme
    SimpledbAdapter = SimpleDBAdapter
  end # module # Adapters
end # module DataMapper