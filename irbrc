# frozen_string_literal: true

if !ENV['DISABLE_PRY_RAILS'] && !ENV['DISABLE_PRY']
  begin
    # Use Pry everywhere
    require 'rubygems' unless defined?(Gem)
    require 'pry'
    Pry.start
    exit
  rescue LoadError
  end
end
