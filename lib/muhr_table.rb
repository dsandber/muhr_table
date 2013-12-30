require "muhr_table/version"

module MuhrTable
  # This empty class makes so that Rails will search the lib/assets directory for assets such as the CSS file
  class Engine < Rails::Engine
  end

  class Railtie < Rails::Railtie
    initializer 'muhr_table.action_controller' do |app|
      ActiveSupport.on_load :action_controller do
        require 'muhr_table/action_controller_methods'
        include MuhrTable::ActionControllerMethods
      end
    end
  end
end

