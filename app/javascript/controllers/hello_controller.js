import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.fetchDateRangesAndRender()
  }

  renderDatePicker(blocked_date_ranges) {
    const toDateRange = (e) => [e.start_date, e.end_date]
    const blockedDateRanges = Array.from(blocked_date_ranges.map(toDateRange));
    console.log('blockedDateRanges', blockedDateRanges)

    const picker = new Litepicker({
      element:                 document.getElementById('datepicker'),
      scrollToDate:            new Date(),
      singleMode:              false,
      inlineMode:              true,
      position:                'bottom',
      footer:                  true,
      disallowLockDaysInRange: true,
      lockDays:                blockedDateRanges,
      setup:                   (picker) => {
        picker.on('selected', (date1, date2) => {
          this.setDatesToSend();

        });
      }
    });

    this.picker = picker;
  }

  setDatesToSend() {
    const startDate = this.picker.getStartDate().toJSDate().toDateString();
    const endDate = this.picker.getEndDate().toJSDate().toDateString();
    console.log(
      this.picker.getStartDate().toJSDate(),
      this.picker.getEndDate().toJSDate()
    );

    document.getElementById('startDate').setAttribute('value', startDate);
    document.getElementById('endDate').setAttribute('value', endDate);
  }

  fetchDateRangesAndRender() {
    fetch('/calendar', { headers: { 'Accept': 'application/json' } } )
      .then(response => response.json())
      .then(data => this.renderDatePicker(data) )
  }
}
