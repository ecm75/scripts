class Parser
	@models = []
	Dir[File.join(__dir__, 'model', '*.rb')].each do |file|
		require file
		@models.push($model)
		include(Kernel.const_get($model))
	end

	def parse(node, config)
		data = {}
		model = node['model'].downcase

		if self.respond_to?(model)
            data = self.send(model, config)
		end

		return data
	end
end
