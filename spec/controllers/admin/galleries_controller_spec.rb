require File.dirname(__FILE__) + '/../../spec_helper'
require 'admin/galleries_controller'

describe Admin::GalleriesController, 'without logged and no import' do
  controller_name 'admin/galleries'
  fixtures :galleries, :pictures, :thumbnails, :users
  integrate_views

  it "should not view index" do
    get 'index'
    response.should redirect_to(admin_login_url)
  end

  it 'should not view show' do
    get 'show', :id => galleries(:gallery1).permalink
    response.should redirect_to(admin_login_url)
  end
  
  it 'should not view new gallery' do
    get 'new'
    response.should redirect_to(admin_login_url)
  end
  
  it 'should not edit gallery' do
    get 'edit', :id => galleries(:gallery1).permalink
    response.should redirect_to(admin_login_url)
  end

  it 'should not update gallery' do
    put 'update', :id => galleries(:gallery1).permalink, :gallery => {:name => 'oui'}
    response.should redirect_to(admin_login_url)
  end

  it 'should not create gallery' do
    post 'create', :gallery => {:name => 'gallery3', :description => 'good gallery', :status => true}
    response.should redirect_to(admin_login_url)
  end

  it 'should not destroy gallery' do
    delete 'destroy', :id => galleries(:gallery1).permalink
    response.should redirect_to(admin_login_url)
  end

end

describe Admin::GalleriesController, 'with user logged and no import' do
  controller_name 'admin/galleries'
  fixtures :galleries, :pictures, :thumbnails, :users
  include AuthenticatedTestHelper

  before (:each) do
    Import.delete_all
    login_as :quentin
    @gallery = mock_model(Gallery)
  end

  it 'should see index' do
    get 'index'
    assert_response :success
    assert_template 'index'
  end

  it 'should see first gallery' do
    get 'show', :id => galleries(:gallery1).permalink
    assert_response :success
    assert_template 'show'
  end
  
  it 'should see 404 error if gallery with bad id' do
    get 'show', :id => 10
    response.response_code.should == 404
  end

  it 'should see new page of gallery in admin' do
    get 'new'
    assert_response :success
    assert_template 'new'
  end

  it 'should edit gallery in admin' do
    get :edit, :id => galleries(:gallery1).permalink
    assert_response :success
    assert_template 'edit'
  end

  it 'should see 404 if id gallery not found' do
    get :edit, :id => 10
    assert_response 404
  end

  it 'should update gallery in admin' do
    g = Gallery.find 1
    g.name.should_not == 'oui'
    put 'update', :id => galleries(:gallery1).permalink, :gallery => {:name => 'oui'}
    response.should redirect_to(admin_galleries_url)
    g = Gallery.find 1
    g.name.should == 'oui'
  end

  it 'should not update gallery in admin because no name' do
    g = Gallery.find 1
    g.name.should_not == ''
    put 'update', :id => galleries(:gallery1).permalink, :gallery => {:name => ''};
    assert_response :success
    assert_template 'edit'
    g = Gallery.find 1
    g.name.should_not == ''
  end

  it 'should create gallery' do
    post 'create', :gallery => {:name => 'gallery3', :description => 'good gallery', :status => true}
    response.should redirect_to(admin_galleries_url)
    g = Gallery.find_by_name 'gallery3'
    g.should_not be_nil
    g.description.should == 'good gallery'
    g.permalink.should == 'gallery3'
    g.should be_status
  end

  it 'should not create gallery because no name' do
    Gallery.count.should == 2
    post 'create', :gallery => {:name => '', :description => 'good gallery', :status => true}
    assert_response :success
    assert_template 'new'
    Gallery.count.should == 2
  end

  it 'should destroy gallery' do
    Gallery.count.should == 2
    delete :destroy, :id => galleries(:gallery1).permalink
    response.should redirect_to(admin_galleries_url)
    Gallery.count.should == 1
    assert_raise ActiveRecord::RecordNotFound do 
      Gallery.find(1)
    end
  end

  it 'should add gallery by mass_upload with a good directory' do
    directory = "#{RAILS_ROOT}/spec/fixtures/files"
    Gallery.should_receive(:create_by_name_of_directory).with(directory).and_return(@gallery)
    @gallery.should_receive(:save!).once.and_return(true)
    @gallery.should_receive(:insert_pictures).once.with(directory)
    post 'mass_upload', :directory => directory
    response.should redirect_to(admin_gallery_url(@gallery))
  end

  it 'should not add gallery by mass_upload with a bad directory' do
    directory = "/foo/bar"
    Gallery.should_receive(:create_by_name_of_directory).with(directory).and_return(@gallery)
    post 'mass_upload', :directory => directory
    response.should render_template('new')
  end

  it 'should not add gallery by mass_upload because name of gallery already exist' do
    directory = "/foo/bar"
    Gallery.should_receive(:create_by_name_of_directory).with(directory).and_return(@gallery)
    File.should_receive(:directory?).with(directory).and_return(true)
    @gallery.should_receive(:save!).and_raise(ActiveRecord::RecordInvalid.new(Gallery.new))
    @gallery.should_not_receive(:insert_pictures).with(directory)
    post 'mass_upload', :directory => directory
    response.should render_template('new')
  end

end
