class OrdersController < ApplicationController

  def create

  charge = Charge.find(params[:charge_id])
  @order = Order.create!(charge: charge, amount: charge.price, state: 'pending', user: current_user)

  session = Stripe::Checkout::Session.create(
    payment_method_types: ['card'],
    line_items: [{
      name: "Charges for #{current_user}",
      amount: charge.price_cents,
      currency: 'eur',
      quantity: 1
    }],
    success_url: order_url(@order),
    cancel_url: order_url(@order)
  )

  @order.update(checkout_session_id: session.id)
  redirect_to new_order_payment_path(@order)
  authorize @order
  end

  def show
    @order = current_user.orders.find(params[:id])
    authorize @order
  end

end
