class PagesController < ApplicationController
  # skip_before_action :authenticate_user!, only: [:home]

  def home
    @analysis = Analysis.new
  end

  def team
  end

  def cgu
  end

  def blog
  end
end
