class DateRangeChannel < ApplicationCable::Channel
  def subscribed
    stream_from "DateRangeChannel_#{params[:request_id]}"
  end

  def unsubscribed
    stop_all_streams
  end
end
