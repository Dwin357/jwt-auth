module JwtAuth
	class PathEntryCollection
		class Error < Configuration::Error; end

		def initialize(collection_arg)
			validate collection_arg
			@collection = collection_arg.map{ |entry_arg| PathEntry.new(entry_arg) }
		end

		def include?(request)
			collection.any? { |entry| entry.match? request }
		end

		def empty?
			collection.empty?
		end

		private

		attr_reader :collection

		def validate(input)
			raise(Error, 'entry arguments must be iterable') unless input.respond_to?(:map)
		end
	end
end
