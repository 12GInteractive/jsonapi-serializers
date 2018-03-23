module SerializerSpecHelpers
  def serialize_primary(object, options = {})
    # Note: intentional high-coupling to protected method for tests.
    serialization_method = if options[:is_collection]
      :serialize_primary_multi
    else
      :serialize_primary
    end
    JSONAPI::Serializer.send(serialization_method, object, options)
  end
end
