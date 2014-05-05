class EventsController < ApplicationController

  
  before_filter :authenticate_user!
  authorize_actions_for Event, except: [:requests, :new_materials,
                    :new_permissions, :profile_picture, :cover_picture,
                    :rate_image, :add_image]

  # authorize_actions_for :load_event, only: [
  #   :new_materials,
  #   :new_permissions,
  #   :profile_picture,
  #   :cover_picture,
  #   :rate_image,
  #   :add_image
  # ]

	def new
		@event = Event.new
    @project_managers = User.all
	end

	def create
		@event = Event.new(params[:event])
    @event.creator = current_user

    if @event.save
        redirect_to events_path , notice: "Event Created succssfully"
    else
      redirect_to events_path, alert: @event.errors.full_messages.join("\n")
    end

	end

	def index
		@events = current_user.get_my_events.to_a
	end

  def show
    @event = Event.find(params[:id])
    @materials_requests=@event.get_materials_requests
    @permissions_requests=@event.get_permissions_requests
    @request = Request.new
  end

	def delete
		
	end

	def update
		@event = Event.find(params[:id])
    @event.update_attributes(params[:event])
    redirect_to @event
	end

  def requests
    @event=Event.find(params[:id])
    @materials_requests=@event.get_materials_requests
    @permissions_requests=@event.get_permissions_requests
    @request=Request.new
  end

  def new_materials
    @event = Event.find(params[:id])
    logger.error ">>>>>>>>>>>>>>>>> before"
    @request=Request.new(params[:request])
    @request.event = @event
    @request.request_type = "materials"
    if @request.save
      logger.error "<<<<<<<<<<<<<<<<<<< after"
      redirect_to(@event, notice: "Successfully created")
    else
      redirect_to :back, notice: "Error occured"
    end
  end

  def new_permissions
    @event = Event.find(params[:id])
    @request=Request.new(params[:request])
    @request.event = @event
    @request.request_type = "permissions"
    if @request.save 
      redirect_to(event_path(@event), notice: "Successfully created")
    else
      redirect_to :back, notice: "Error occured"
    end
   end 


  def profile_picture
    event = Event.find(params[:id])
    image = EventImage.find(params[:image_id])
    if(event.profile_pic!=image)
      EventImage.where(event: event).update_all(profile: false)
      image.update_attribute(:profile, true)
      redirect_to event, :notice => "Successfully made the Image the profile picture."
    else
      redirect_to event, :notice => "This Image is already the profile picture."
    end
  end

  def cover_picture
    event = Event.find(params[:id])
    image = EventImage.find(params[:image_id])
    if(event.cover_pic!=image)
      EventImage.where(event:event).update_all(cover: false)
      image.update_attribute(:cover, true)
      redirect_to event, :notice => "Successfully made the Image the Cover picture."
    else
      redirect_to event, :notice => "This Image is already the Cover picture."
    end
  end

  def add_image
    event = Event.find(params[:id])
    EventImage.create(:image => params[:event][:image], :event => event)
    redirect_to event, :notice => "Successfully Added Image."
  end

  def rate_image
    event = Event.find(params[:id])
    image = EventImage.find(params[:image_id])
    if (!image.voters.include?(current_user))
      image.raters = image.raters+1
      image.voters << current_user
      image.ratings << params[:rating].to_i
      sum = image.ratings.inject(0) {|sum, i|  sum + i }
      image.rating = sum / image.ratings.count
      image.save
    end
    redirect_to event, :notice => "Successfully Rated Image."
  end

  private

  def load_event
    @event = Event.find params[:id]
  end

end
