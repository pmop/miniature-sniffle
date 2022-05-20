import { Controller } from "@hotwired/stimulus"
import consumer from "channels/consumer"

export default class extends Controller {
  connect() {
    this.data.startDate = '';
    this.data.endDate = '';

    consumer.subscriptions.create(
      { channel: "DateRangeChannel" , request_id: this.data.get('request') },
      {
        connected:    this._cableConnected.bind(this),
        disconnected: this._cableDisconnected.bind(this),
        received:     this._cableReceived.bind(this),
      }
    );

    this.fetchDateRangesAndRender()
  }

  _renderDatePicker() {
    const picker = new Litepicker({
      element:                 document.getElementById('datepicker'),
      scrollToDate:            new Date(),
      singleMode:              false,
      inlineMode:              true,
      position:                'bottom',
      footer:                  true,
      disallowLockDaysInRange: true,
      lockDays:                this.data.blockedDateRanges,
      setup:                   (picker) => {
        picker.on('selected', (date1, date2) => {
          this.setDatesToSend();
        });
      }
    });

    this.picker = picker;
  }

  setDatesToSend() {
    this.data.startDate = this.picker.getStartDate().toJSDate().toDateString();
    this.data.endDate = this.picker.getEndDate().toJSDate().toDateString();
    console.log(
      this.picker.getStartDate().toJSDate(),
      this.picker.getEndDate().toJSDate()
    );
  }

  fetchDateRangesAndRender() {
    const toDateRange = (e) => [e.start_date, e.end_date]

    fetch('/calendar', { headers: { 'Accept': 'application/json' } } )
      .then(response => response.json())
      .then(data => this.setBlockedRanges(Array.from(data.map(toDateRange))))
      .then(data => this._renderDatePicker())
  }

  setBlockedRanges(blockedRanges) {
    console.log('blockedRanges', blockedRanges)
    this.data.blockedDateRanges = blockedRanges;
  }

  _cableConnected() {
  }

  _cableDisconnected() {
  }

  _cableReceived(data) {
    this.data.blockedDateRanges = [...this.data.blockedDateRanges, data.data];

    this.picker.setLockDays(this.data.blockedDateRanges);
    this.picker.clearSelection()
  }

  createDateRangeBlock() {
    if((this.data.startDate.length > 0) && (this.data.endDate.length > 0)) {
      const data = {
        date_range: {
          start_date: this.data.startDate,
          end_date:   this.data.endDate,
          created_by: this.data.get('appname')
        }
      };

      fetch('/date_ranges', {
          method: 'POST',
          headers: {
                'Content-Type': 'application/json',
                'Accept':       'application/json'
              },
          body: JSON.stringify(data),
      })
        .then(response => response.json())
        .then(data => {
            console.log('Success:', data);
        })
        .catch((error) => {
            console.error('Error:', error);
        });
    }
    else {
      console.log('undefined dates');
    }
  }
}
