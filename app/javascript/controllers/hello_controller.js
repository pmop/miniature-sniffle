import { Controller } from "@hotwired/stimulus"
import consumer from "channels/consumer"

export default class extends Controller {
  connect() {
    this.data.startDate = '';
    this.data.endDate = '';

    consumer.subscriptions.create(
      { channel: "DateRangeChannel" , request_id: this.data.get('request') },
      {
        received(data) {
          console.log('received actioncable')
          console.log(data)
        }
      }
    );

    this.fetchDateRangesAndRender()
  }

  renderDatePicker() {
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
      .then(data => this.renderDatePicker())
  }

  setBlockedRanges(blockedRanges) {
    console.log('blockedRanges', blockedRanges)
    this.data.blockedDateRanges = blockedRanges;
  }

  createDateRangeBlock() {
    if((this.data.startDate.length > 0) && (this.data.endDate.length > 0)) {
      // do post request

    }
    else {
      console.log('undefined dates');
    }
  }
}
