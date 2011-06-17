#encoding: utf-8
require 'spec_helper'

describe FulfillmentsController do
  include Devise::TestHelpers

  let(:user) { Factory(:user) }

  let(:shop) { user.shop }

  let(:iphone4) { Factory :iphone4, shop: shop, product_type: '智能手机', vendor: '苹果' }

  let(:variant) { iphone4.variants.first }

  let(:order) do
    o = Factory.build(:order, shop: shop)
    o.line_items.build product_variant: variant, price: 10, quantity: 2
    o.save
    o
  end

  let(:line_item) { order.line_items.first }

  before :each do 
    sign_in(user)
  end

  it 'should set line_items' do
    expect do
      post :set, order_id: order.id, shipped: [ line_item.id ]
      line_item.reload.fulfilled.should be_true
      line_item.fulfillment.should_not be_nil
      order.reload.fulfillment_status.to_sym.should eql :fulfilled
    end.should change(OrderFulfillment, :count).by(1)
  end

end