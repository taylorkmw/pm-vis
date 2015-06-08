class Feature < ActiveRecord::Base
	@@range
	@@valid_range = Set.new
	all.each do |feature|
		@@valid_range.add(feature[:time])
	end

	def self.set_range(time)
		@@range = time
	end

	def self.get_year
		@@range[0..3]
	end

	def self.get_year_month
		@@range[0..6]
	end

	def self.import(file)
		CSV.foreach(file.path, headers: true) do |row|
			Feature.create! row.to_hash
		end
	end

	def self.contains?(range)
		@@valid_range.each do |r|
			if r.start_with?(range)
				return true
			end
		end
		return false
	end

	def self.to_csv
		CSV.generate() do |row|
			row << ["concentration", "lat", "lon"]
			@sum = Hash.new(0)
			@n = Hash.new(0)
			all.each do |feature|
				if feature[:time].start_with?(@@range)
					@sum["#{feature[:lat].to_f.round(4)}, #{feature[:lon].to_f.round(4)}"] += feature[:concentration].to_f
					@n["#{feature[:lat].to_f.round(4)}, #{feature[:lon].to_f.round(4)}"] += 1
				end
			end

			@out = @sum.merge(@n) do |key, oldval, newval|
				oldval/newval
			end

			@out.each do |key, val|
				pos = key.split(",")
				row << [val.round(4), pos[0], pos[1]]
			end
		end

	end
end
