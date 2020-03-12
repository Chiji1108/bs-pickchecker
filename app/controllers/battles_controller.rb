class BattlesController < ApplicationController
  def index
    @battles = Battle.all.page(params[:page])
  end
end
