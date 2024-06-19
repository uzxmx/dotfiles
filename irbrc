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

    begin
      require 'pry'
    rescue LoadError
      if Gem.loaded_specs['rails']
        _dirname = File.dirname(Gem.loaded_specs['rails'].full_gem_path)
        def _add_lib(name, dirname)
          filename = Dir.entries(dirname).find{ |e| Regexp.new("^#{name}-[0-9]+\.[0-9]+\.[0-9]+$").match(e) }
          if filename
            $LOAD_PATH << File.join(dirname, filename, 'lib')
          end
        end
        _add_lib('pry', _dirname)
        _add_lib('coderay', _dirname)
        _add_lib('method_source', _dirname)
        require 'pry'
      end
    end

    Pry.start
    exit
  rescue LoadError
  end
end
