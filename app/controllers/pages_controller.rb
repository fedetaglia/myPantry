class PagesController < ApplicationController
skip_before_filter :authenticate_user!, only: [:index,:about,:contact]

  def index
    render layout: "landing_layout"
  end


end



