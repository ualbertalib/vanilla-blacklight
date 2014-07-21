require 'spec_helper'

describe "catalog/_sort_and_per_page" do

  let :blacklight_config do
    Blacklight::Configuration.new
  end

  before do
    view.stub(blacklight_config: blacklight_config)
  end

  it "should render the pagination, sort, per page and view type controls" do
    stub_template "catalog/_paginate_compact.html.erb" => "paginate_compact"
    stub_template "catalog/_sort_widget.html.erb" => "sort_widget"
    stub_template "catalog/_per_page_widget.html.erb" => "per_page_widget"
    stub_template "catalog/_view_type_group.html.erb" => "view_type_group"
    render
    expect(rendered).to match /paginate_compact/
    expect(rendered).to match /sort_widget/
    expect(rendered).to match /per_page_widget/
    expect(rendered).to match /view_type_group/
  end

end