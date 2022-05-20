class DateRangesController < ApplicationController
  protect_from_forgery except: :create_json_api
  before_action :authenticate_user!

  def calendar
    @date_ranges = DateRange.where(user: current_user)
    @date_range = DateRange.new

    respond_to do |format|
      format.html { render :calendar }
      format.json { render json: @date_ranges }
    end
  end

  # POST /date_ranges or /date_ranges.json
  def create
    @date_range = new_date_range

    respond_to do |format|
      if @date_range.save
        sync_with_peer(date_range_params) if sync_with_peer?
        broadcast_date_range

        format.html { redirect_to calendar_url, notice: "Date range was successfully created." }
        format.json { render json: @date_range.to_json }
      else
        format.html { render :calendar, status: :unprocessable_entity }
        format.json { render json: @date_range.errors, status: :unprocessable_entity }
      end
    end
  end

  def create_json_api
    @date_range = new_date_range

    respond_to do |format|
      if @date_range.save
        broadcast_date_range

        format.json { render json: @date_range.to_json }
      else
        format.json { render json: @date_range.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    def authenticate_user!
      authenticate_or_request_with_http_basic do |email, password|
        resource = User.find_by_email(email)
        if resource
          sign_in :user, resource if resource.valid_password?(password)
        else
          request_http_basic_authentication
        end
      end
    end

    def new_date_range
      Rails.logger.info(date_range_params)
      DateRange.new(
        user:       current_user,
        start_date: date_range_params['start_date'].to_date,
        end_date:   date_range_params['end_date'].to_date,
        created_by: date_range_params['created_by']
      )
    end

    def sync_with_peer(date_range)
      user = current_user
      url = "http://localhost:#{Rails.configuration.peer_app_port}"
      conn = Faraday.new(url) do |conn|
        conn.request :authorization, :basic, user.email, user.password
        conn.request :url_encoded
        conn.response :json
        conn.adapter :net_http
      end

      date_range[:date_range].merge!(created_by: app_name)

      conn.post('/api/date_ranges', date_range)
    end

    def broadcast_date_range
      channel = "DateRangeChannel_#{current_user.email}@#{app_name}"
      ActionCable.server.broadcast(
        channel,
        {
          data: [
            date_range_params[:start_date].to_date.to_s,
            date_range_params[:end_date].to_date.to_s
          ]
        }
      )
    end

    def sync_with_peer?
      Rails.configuration.sync_with_peer
    end

    def app_name
      @app_name ||= Rails.configuration.app_name
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_date_range
      @date_range = DateRange.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def date_range_params
      params.require(:date_range).permit(:user_id, :start_date, :end_date, :created_by)
    end
end
