class StatisticsController < ApplicationController
  include LoadsStatistics

  def index
    load_statistics
  end
end
