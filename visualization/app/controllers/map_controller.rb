class MapController < ApplicationController
  def view
    Feature.set_range params[:range].to_s
  end

  def upload
  	dust_file = params[:dust]
  	gps_file = params[:gps]


    require 'csv'
    require 'time'

    date = nil
    time = nil
    CSV.foreach(dust_file.path) do |row|
      time = row[1] if $. == 7
      date = row[1] if $. == 8
      break if $. == 9
    end
    dust_dt = Time.strptime("#{date} #{time}", "%m/%d/%Y %I:%M:%S %p")

    dust = Hash.new()
    CSV.foreach(dust_file.path) do |row|
      next if $. < 21
      dust_dt += 1
      dust.store("#{dust_dt}", "#{row[1]}")
    end

    gps = Hash.new()
    CSV.foreach(gps_file.path) do |row|
      if row[0] == "$GPRMC"
        lat = row[3].to_f
        lat = lat.to_i / 100 + lat % 100 / 60
        lat *= -1 if row[4] == "S"
        lon = row[5].to_f
        lon = lon.to_i / 100 + lon % 100 / 60
        lon *= -1 if row[6] == "W"
        gps_dt = Time.strptime("#{row[9]} #{row[1]}", "%d%m%y %H%M%S") - 7 * 60 * 60
        gps.store("#{gps_dt}", "#{lat.round(6)},#{lon.round(6)}")
      end
    end
    dust.select! {|k, v| gps.key?(k)}
    gps.select! {|k, v| dust.key?(k)}

    out = dust.merge(gps) do |key, oldval, newval|
      "#{oldval},#{newval}"
    end

  	File.open(Rails.root.join("public", "uploads", "#{Time.new}.csv"), "wb") do |file|
      file.puts("time,concentration,lat,lon")
      out.each do |k, v|
        file.puts("#{k},#{v}")
      end
      Feature.import(file)
    end

    redirect_to root_path
  end
end
