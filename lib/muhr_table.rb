require "muhr_table/version"

# this might be needed to make development work again
#require 'muhr_table/action_controller_methods'
#require 'muhr_table/action_view_methods'
  
module MuhrTable
  # require_reloader won't work if we initialize here.  This will make developing the muhr_table gem
  # unpleasant because constant bundle and server restart will be needed
  GEM_UNDER_DEVELOPMENT=false

   # This empty class makes so that Rails will search the lib/assets directory for assets such as the CSS file
   class Engine < Rails::Engine
   end

   class Railtie < Rails::Railtie
     if not GEM_UNDER_DEVELOPMENT
       initializer 'muhr_table.action_controller' do |app|
         ActiveSupport.on_load :action_controller do
           require 'muhr_table/action_controller_methods'
           include MuhrTable::ActionControllerMethods
         end
       end

       initializer 'muhr_table.action_view' do |app|
         ActiveSupport.on_load :action_view do
           require 'muhr_table/action_view_methods'
           include MuhrTable::ActionViewMethods
         end
       end
     end
   end
end

