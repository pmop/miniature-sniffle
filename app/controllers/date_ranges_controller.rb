class DateRangesController < ApplicationController
  protect_from_forgery except: %i[create_json_api create]
  before_action :authenticate_user!, except: :create_json_api

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
        broadcast_date_range(current_user.email)
        sync_with_peer(date_range_params) if sync_with_peer?

        format.html { redirect_to calendar_url, notice: "Date range was successfully created." }
        format.json { render json: @date_range.to_json }
      else
        format.html { render :calendar, status: :unprocessable_entity }
        format.json { render json: @date_range.errors, status: :unprocessable_entity }
      end
    end
  end

  def create_json_api
    @date_range = DateRange.new(
      user:       User.find_by_email(date_range_params[:user_email]),
      start_date: date_range_params[:start_date].to_date,
      end_date:   date_range_params[:end_date].to_date,
      created_by: date_range_params[:created_by]
    )

    respond_to do |format|
      if @date_range.save
        broadcast_date_range(date_range_params[:user_email])

        format.json { render json: @date_range.to_json }
      else
        format.json { render json: @date_range.errors, status: :unprocessable_entity }
      end
    end
  end

  private
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
      Rails.logger.info('sync with peer')
      Rails.logger.info(url)
      conn = Faraday.new(url) do |conn|
        conn.request :json
        conn.response :json
        conn.adapter :net_http
      end

      body = {
        'date_range' => date_range.to_h.merge(
          user_email: user.email,
          created_by: app_name
        )
      }

      r = conn.post('/api/date_ranges', body)

      Rails.logger.info(r.status)
    end

    def broadcast_date_range(email)
      channel = "DateRangeChannel_#{email}@#{app_name}"
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
      params.require(:date_range).permit(:user_email, :user_id, :start_date, :end_date, :created_by)
    end
end
