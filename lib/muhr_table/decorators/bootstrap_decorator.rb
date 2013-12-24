class BootstrapDecorator
  def get_block
    Proc.new do |m|
      m.decorator_before_table do
        "<div class='wice-grid-container' id='grid'><div id='grid_title'></div>"
      end

      m.decorator_after_table do
        '</div>'
      end

      m.table class:'table-striped table-bordered table wice-grid' 
      m.title_row class:'wice-grid-title-row' 
      m.filter_row class:'wg-filter-row', id:'grid_filter_row'
      m.filter_row_input class:'test_this_here' do |column_type|
        if column_type==:datetime
          { 'data-button-image'.to_sym=>'/assets/icons/grid/calendar_view_month.png', 
            type:'hidden' }
        else
          { class:'form-control input-sm', size:'8', type:'text' }
        end        
      end
    end
  end
end
