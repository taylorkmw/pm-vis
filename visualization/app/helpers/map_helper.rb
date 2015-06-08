module MapHelper
	def current(range)
		if request.original_fullpath.start_with?("/?range=#{range}")
			"current"
		elsif Feature.contains?(range)
			"available"
		else
			"not-current"
		end
	end
end
