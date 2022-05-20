require 'rails_helper'

RSpec.describe 'Calendars', type: :request do
  let!(:headers) do
    {
      'ACCEPT' => 'application/json',
      'HTTP_AUTHORIZATION' => "#{basic_auth_creds}"
    }
  end

  describe "GET /calendars" do
    let(:basic_auth_creds) do
      ActionController::HttpAuthentication::Basic.encode_credentials(
        user.email,user.password
      )
    end

    let(:user)        { date_range1.user }
    let(:date_range1) do
      Fabricate :date_range, start_date: '2022-05-19',
                             end_date:   '2022-05-22'
    end
    let(:date_range2) do
      Fabricate :date_range, start_date: '2022-05-22',
                             end_date:   '2022-05-24',
                             user:       user
    end

    before do
      date_range1
      date_range2
    end

    context 'with valid parameters' do
      it 'returns the correct json'do
        get "/calendar", headers: headers

        expect(response).to have_http_status(:ok)

        response_json = JSON.parse(response.body)

        expect(response_json.count).to eq(2)
        expect(response_json[0]['user_id']).to eq user.id
        expect(response_json[1]['user_id']).to eq user.id

        expect(response_json[0]).to include(
          'start_date' => '2022-05-19',
          'end_date'   => '2022-05-22',
          'created_by' => 'alpha'
        )

        expect(response_json[1]).to include(
          'start_date' => '2022-05-22',
          'end_date'   => '2022-05-24',
          'created_by' => 'alpha'
        )
      end
    end
  end
end
