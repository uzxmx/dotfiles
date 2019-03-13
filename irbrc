# frozen_string_literal: true

begin
  # Use Pry everywhere
  require 'rubygems' unless defined?(Gem)
  require 'pry'
  Pry.start
  exit
rescue LoadError
end
