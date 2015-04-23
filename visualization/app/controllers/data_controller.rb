class DataController < ApplicationController
  def view
  	@features = Feature.order(:time)
  	send_data(@features.to_csv)
  end
end
