# frozen_string_literal: true

if ENV['DOTFILES_DIR']
  path = "#{ENV['DOTFILES_DIR']}/lib/ruby/string.rb"
  if File.exist?(path)
    load path
  end
end

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
