require 'spec_helper'

describe 'bookmarks/_refworks.html.erb' do
  it "should have a link" do
    view.stub(encrypt_user_id: 1)
    view.stub(current_or_guest_user: mock_model(User))
    assign(:document_list, [mock_model(Bookmark, document_id: 7, exports_as?: true), mock_model(Bookmark, document_id: 8, exports_as?: true)])
    render
    expect(rendered).to have_link "Export to Refworks"
  end
end
