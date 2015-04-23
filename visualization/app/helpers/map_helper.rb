module MapHelper
	def current(range)
		if request.original_fullpath.start_with?("/?range=#{range}")
			"current"
		else
			"not-current"
		end
	end
end
