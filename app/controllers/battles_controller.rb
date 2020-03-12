class BattlesController < ApplicationController
  def index
    @battles = Battle.all.order(time: :desc).page(params[:page])
  end
end
