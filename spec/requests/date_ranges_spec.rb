require 'rails_helper'

RSpec.describe 'DateRanges', type: :request do
  let!(:headers) do
    {
      'ACCEPT' => 'application/json',
      'HTTP_AUTHORIZATION' => "#{basic_auth_creds}"
    }
  end

  describe "POST /date_ranges" do
    let!(:user) { Fabricate :user }
    let(:basic_auth_creds) do
      ActionController::HttpAuthentication::Basic.encode_credentials(
        user.email,user.password
      )
    end

    context 'with valid parameters' do
      it 'returns the correct json'do
        params = {
          date_range: {
            start_date: '2022-05-19',
            end_date:   '2022-05-22',
            created_by: 'alpha'
          }
        }

        post "/date_ranges", params: params, headers: headers

        expect(response).to have_http_status(:ok)

        response_json = JSON.parse(response.body)

        expect(DateRange.all.count).to eq(1)

        created_date_range = DateRange.where(user: user).first

        expect(created_date_range.start_date.to_s).to eq('2022-05-19')
        expect(created_date_range.end_date.to_s).to eq('2022-05-22')
        expect(created_date_range.created_by.to_s).to eq('alpha')
      end
    end
  end

  describe "POST /api/date_ranges" do
    let!(:user) { Fabricate :user }
    let(:basic_auth_creds) do
      ActionController::HttpAuthentication::Basic.encode_credentials(
        user.email,user.password
      )
    end

    context 'with valid parameters' do
      it 'returns the correct json'do
        params = {
          date_range: {
            start_date: '2022-05-19',
            end_date:   '2022-05-22',
            created_by: 'alpha'
          }
        }

        post "/api/date_ranges", params: params, headers: headers

        expect(response).to have_http_status(:ok)

        response_json = JSON.parse(response.body)

        expect(DateRange.all.count).to eq(1)

        created_date_range = DateRange.where(user: user).first

        expect(created_date_range.start_date.to_s).to eq('2022-05-19')
        expect(created_date_range.end_date.to_s).to eq('2022-05-22')
        expect(created_date_range.created_by.to_s).to eq('alpha')
      end
    end
  end
end
