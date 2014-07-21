require 'spec_helper'

describe Blacklight::DocumentPresenter do
  include Capybara::RSpecMatchers
  let(:request_context) { double(:add_facet_params => '') }
  let(:document) { double }
  let(:config) { Blacklight::Configuration.new }

  subject { Blacklight::DocumentPresenter.new(document, request_context, config) }

  describe "render_index_field_value" do
    let(:config) do 
      Blacklight::Configuration.new.configure do |config|
        config.add_index_field 'qwer'
        config.add_index_field 'asdf', :helper_method => :render_asdf_index_field
        config.add_index_field 'link_to_search_true', :link_to_search => true
        config.add_index_field 'link_to_search_named', :link_to_search => :some_field
        config.add_index_field 'highlight', :highlight => true
        config.add_index_field 'solr_doc_accessor', :accessor => true
        config.add_index_field 'explicit_accessor', :accessor => :solr_doc_accessor
        config.add_index_field 'explicit_accessor_with_arg', :accessor => :solr_doc_accessor_with_arg
      end
    end
    it "should check for an explicit value" do
      document.should_not_receive(:get).with('asdf', :sep => nil)
      value = subject.render_index_field_value 'asdf', :value => 'asdf'
      expect(value).to eq 'asdf'
    end

    it "should check for a helper method to call" do
      document.should_receive(:get).with('asdf', :sep => nil)
      request_context.stub(:render_asdf_index_field).and_return('custom asdf value')
      value = subject.render_index_field_value 'asdf'
      expect(value).to eq 'custom asdf value'
    end

    it "should check for a link_to_search" do
      document.should_receive(:get).with('link_to_search_true', :sep => nil).and_return('x')
      request_context.should_receive(:add_facet_params).and_return(:f => { :link_to_search_true => ['x'] })
      request_context.should_receive(:search_action_path).with(:f => { :link_to_search_true => ['x'] }).and_return('/foo')
      request_context.should_receive(:link_to).with("x", '/foo').and_return('bar')
      value = subject.render_index_field_value 'link_to_search_true'
      expect(value).to eq 'bar'
    end

    it "should check for a link_to_search with a field name" do
      document.should_receive(:get).with('link_to_search_named', :sep => nil).and_return('x')
      request_context.should_receive(:add_facet_params).and_return(:f => { :some_field => ['x'] })
      request_context.should_receive(:search_action_path).with(:f => { :some_field => ['x'] }).and_return('/foo')
      request_context.should_receive(:link_to).with("x", '/foo').and_return('bar')
      value = subject.render_index_field_value 'link_to_search_named'
      expect(value).to eq 'bar'
    end

    it "should gracefully handle when no highlight field is available" do
      document.should_not_receive(:get)
      document.should_receive(:has_highlight_field?).and_return(false)
      value = subject.render_index_field_value 'highlight'
      expect(value).to be_blank
    end

    it "should check for a highlighted field" do
      document.should_not_receive(:get)
      document.should_receive(:has_highlight_field?).and_return(true)
      document.should_receive(:highlight_field).with('highlight').and_return(['<em>highlight</em>'.html_safe])
      value = subject.render_index_field_value 'highlight'
      expect(value).to eq '<em>highlight</em>'
    end

    it "should check the document field value" do
      document.should_receive(:get).with('qwer', :sep => nil).and_return('document qwer value')
      value = subject.render_index_field_value 'qwer'
      expect(value).to eq 'document qwer value'
    end

    it "should work with index fields that aren't explicitly defined" do
      document.should_receive(:get).with('mnbv', :sep => nil).and_return('document mnbv value')
      value = subject.render_index_field_value 'mnbv'
      expect(value).to eq 'document mnbv value'
    end

    it "should call an accessor on the solr document" do
      document.stub(:solr_doc_accessor => "123")
      value = subject.render_index_field_value 'solr_doc_accessor'
      expect(value).to eq "123"
    end

    it "should call an explicit accessor on the solr document" do
      document.stub(:solr_doc_accessor => "123")
      value = subject.render_index_field_value 'explicit_accessor'
      expect(value).to eq "123"
    end

    it "should call an implicit accessor on the solr document" do
      expect(document).to receive(:solr_doc_accessor_with_arg).with('explicit_accessor_with_arg').and_return("123")
      value = subject.render_index_field_value 'explicit_accessor_with_arg'
      expect(value).to eq "123"
    end
  end
  
  describe "render_document_show_field_value" do
    let(:config) do 
      Blacklight::Configuration.new.configure do |config|
        config.add_show_field 'qwer'
        config.add_show_field 'asdf', :helper_method => :render_asdf_document_show_field
        config.add_show_field 'link_to_search_true', :link_to_search => true
        config.add_show_field 'link_to_search_named', :link_to_search => :some_field
        config.add_show_field 'highlight', :highlight => true
        config.add_show_field 'solr_doc_accessor', :accessor => true
        config.add_show_field 'explicit_accessor', :accessor => :solr_doc_accessor
        config.add_show_field 'explicit_array_accessor', :accessor => [:solr_doc_accessor, :some_method]
        config.add_show_field 'explicit_accessor_with_arg', :accessor => :solr_doc_accessor_with_arg
      end
    end

    it "should check for an explicit value" do
      document.should_not_receive(:get).with('asdf', :sep => nil)
      request_context.should_not_receive(:render_asdf_document_show_field)
      value = subject.render_document_show_field_value 'asdf', :value => 'val1'
      expect(value).to eq 'val1'
    end

    it "should check for a helper method to call" do
      document.should_receive(:get).with('asdf', :sep => nil)
      request_context.stub(:render_asdf_document_show_field).and_return('custom asdf value')
      value = subject.render_document_show_field_value 'asdf'
      expect(value).to eq 'custom asdf value'
    end

    it "should check for a link_to_search" do
      document.should_receive(:get).with('link_to_search_true', :sep => nil).and_return('x')
      request_context.should_receive(:search_action_path).with('').and_return('/foo')
      request_context.should_receive(:link_to).with("x", '/foo').and_return('bar')
      value = subject.render_document_show_field_value 'link_to_search_true'
      expect(value).to eq 'bar'
    end

    it "should check for a link_to_search with a field name" do
      document.should_receive(:get).with('link_to_search_named', :sep => nil).and_return('x')
      request_context.should_receive(:search_action_path).with('').and_return('/foo')
      request_context.should_receive(:link_to).with("x", '/foo').and_return('bar')
      value = subject.render_document_show_field_value 'link_to_search_named'
      expect(value).to eq 'bar'
    end

    it "should gracefully handle when no highlight field is available" do
      document.should_not_receive(:get)
      document.should_receive(:has_highlight_field?).and_return(false)
      value = subject.render_document_show_field_value 'highlight'
      expect(value).to be_blank
    end

    it "should check for a highlighted field" do
      document.should_not_receive(:get)
      document.should_receive(:has_highlight_field?).and_return(true)
      document.should_receive(:highlight_field).with('highlight').and_return(['<em>highlight</em>'.html_safe])
      value = subject.render_document_show_field_value 'highlight'
      expect(value).to eq '<em>highlight</em>'
    end


    it "should check the document field value" do
      document.should_receive(:get).with('qwer', :sep => nil).and_return('document qwer value')
      value = subject.render_document_show_field_value 'qwer'
      expect(value).to eq 'document qwer value'
    end

    it "should work with show fields that aren't explicitly defined" do
      document.should_receive(:get).with('mnbv', :sep => nil).and_return('document mnbv value')
      value = subject.render_document_show_field_value 'mnbv'
      expect(value).to eq 'document mnbv value'
    end

    it "should call an accessor on the solr document" do
      document.stub(:solr_doc_accessor => "123")
      value = subject.render_document_show_field_value 'solr_doc_accessor'
      expect(value).to eq "123"
    end

    it "should call an explicit accessor on the solr document" do
      document.stub(:solr_doc_accessor => "123")
      value = subject.render_document_show_field_value 'explicit_accessor'
      expect(value).to eq "123"
    end

    it "should call an explicit array-style accessor on the solr document" do
      document.stub(:solr_doc_accessor => double(:some_method => "123"))
      value = subject.render_document_show_field_value 'explicit_array_accessor'
      expect(value).to eq "123"
    end

    it "should call an accessor on the solr document with the field as an argument" do
      expect(document).to receive(:solr_doc_accessor_with_arg).with('explicit_accessor_with_arg').and_return("123")
      value = subject.render_document_show_field_value 'explicit_accessor_with_arg'
      expect(value).to eq "123"
    end
  end
  describe "render_field_value" do
    it "should join and html-safe values" do
      expect(subject.render_field_value(['a', 'b'])).to eq "a, b"
    end

    it "should join values using the field_value_separator" do
      subject.stub(:field_value_separator).and_return(" -- ")
      expect(subject.render_field_value(['a', 'b'])).to eq "a -- b"
    end

    it "should use the separator from the Blacklight field configuration by default" do
      expect(subject.render_field_value(['c', 'd'], double(:separator => '; ', :itemprop => nil))).to eq "c; d"
    end

    it "should include schema.org itemprop attributes" do
      expect(subject.render_field_value('a', double(:separator => nil, :itemprop => 'some-prop'))).to have_selector("span[@itemprop='some-prop']", :text => "a") 
    end
  end
end
