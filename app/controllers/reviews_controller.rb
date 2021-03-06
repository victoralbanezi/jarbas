class ReviewsController < ApplicationController
  before_action :find_review, only: [:update, :edit, :destroy]

  def new
  	@review = Review.new
  	@booking = Booking.find(params[:booking_id])
  end

  def create
  	@review = Review.new(review_params)
  	@review.user = current_user
  	@review.booking = Booking.find(params[:booking_id])
  	if @review.save
  		redirect_to @review.service
  	else
  		render :new
  	end
  end

  def edit
  end

  def update
  	if @review.update(review_params)
  		redirect_to @review.service
  	else
  		render :edit
  	end
  end

  def destroy
    service = @review.service
    @review.destroy
    redirect_to service
  end

  private

  def review_params
  	params.require(:review).permit(:content, :rating)
  end

  def find_review
  	@review = Review.find(params[:id])
  	@booking = @review.booking
  end

end
