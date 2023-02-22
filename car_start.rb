require "json"
require "rest-client"

userData = {
  username: "rocco11nicholls@gmail.com",
  password: "Zoro1080",
  vin:      "5NPE34AF6JH655842",
  pin:      "7625",
  car:      "BluZoro"
}

host = "api.telematics.hyundaiusa.com"
base_url = "https://#{host}/"
client_id = "815c046afaa4471aa578827ad546cc76"
client_secret = "GXZveJJAVTehh/OtakM3EQ=="
login_path = "#{base_url}/v2/ac/oauth/token"
vehicle_path = "#{base_url}/ac/v2/enrollment/details/#{userData[:username]}"
start_path = "#{base_url}/ac/v2/rcs/rsc/start"

auth_headers = {
  client_id: client_id,
  client_secret: client_secret
}

auth_res = RestClient.post(
  login_path,
  userData.slice(:username, :password),
  auth_headers,
)
raise "Auth Failed!" unless auth_res.code == 200

authVars = JSON.parse(auth_res.body, symbolize_names: true)
# [:access_token, :refresh_token, :expires_in, :username]
access_token = authVars[:access_token]

vehicle_res = RestClient.get(
  vehicle_path,
  {
    "access_token": access_token,
    "client_id": client_id,
    "Host": host,
    "User-Agent": "okhttp/3.12.0",
    "payloadGenerated": "20200226171938",
    "includeNonConnectedVehicles": "Y",
  }
)
raise "Get Vehicles Failed!" unless vehicle_res.code == 200

vehicle_json = JSON.parse(vehicle_res.body, symbolize_names: true)
# [:enrolledVehicleDetails, :addressDetails, :user]
vehicle = vehicle_json[:enrolledVehicleDetails].first
# [:packageDetails, :vehicleDetails, :roleDetails, :responseHeaderMap]
vehicle_details = vehicle[:vehicleDetails]
regid = vehicle_details[:regid]
brand = vehicle_details[:brandIndicator]
vin = vehicle_details[:vin]

heat_params = {
  Ims: 0,
  airCtrl: 0,
  # airTempvalue: 70,
  airTemp: {
    unit: 1,
    value: "70"
  },
  defrost: false,
  heating1: 0,
  igniOnDuration: 10,
  seatHeaterVentInfo: nil,
  username: authVars[:username],
  vin: vin,
}

start_headers = {
  "Content-Type":       "application/json",
  "access_token":       access_token,
  "client_id":          client_id,
  "Host":               host,
  "User-Agent":         "okhttp/3.12.0",
  "registrationId":     regid,
  "gen":                "2",
  "username":           authVars[:username],
  "vin":                vin,
  "APPCLOUD-VIN":       vin,
  "Language":           "0",
  "to":                 "ISS",
  "encryptFlag":        "false",
  "from":               "SPA",
  "brandIndicator":     brand,
  "bluelinkservicepin": userData[:pin],
  "offset":             "-4",
}

# RestClient.log = "stdout"
# RestClient.post(
#   "https://api.telematics.hyundaiusa.com//ac/v2/rcs/rsc/start",
#   {
#     "Ims": 0,
#     "airCtrl": 0,
#     "airTemp": {
#       "unit": 1,
#       "value": "70"
#     },
#     "defrost": false,
#     "heating1": 0,
#     "igniOnDuration": 10,
#     "seatHeaterVentInfo": nil,
#     "username": "rocco11nicholls@gmail.com",
#     "vin": "5NPE34AF6JH655842"
#   }.to_json,
#   {
#     "Content-Type": "application/json",
#     "access_token": access_token,
#     "client_id": "815c046afaa4471aa578827ad546cc76",
#     "Host": "api.telematics.hyundaiusa.com",
#     "User-Agent": "okhttp/3.12.0",
#     "registrationId": "H00002444540V5NPE34AF6JH655842",
#     "gen": "2",
#     "username": "rocco11nicholls@gmail.com",
#     "vin": "5NPE34AF6JH655842",
#     "APPCLOUD-VIN": "5NPE34AF6JH655842",
#     "Language": "0",
#     "to": "ISS",
#     "encryptFlag": "false",
#     "from": "SPA",
#     "brandIndicator": "H",
#     "bluelinkservicepin": "7625",
#     "offset": "-4"
#   }
# )
puts "RestClient.post(
  \"#{start_path}\",
  #{JSON.pretty_generate(heat_params)}.to_json,
  #{JSON.pretty_generate(start_headers)}
)"

# ====== Dead
start_res = RestClient.post(
  start_path,
  heat_params.to_json,
  start_headers
)
raise "Start Failed!" unless start_res.code == 200

puts start_json = JSON.parse(start_res.body, symbolize_names: true)
