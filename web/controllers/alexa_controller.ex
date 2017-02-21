defmodule Alexa.AlexaController do
  use Alexa.Web, :controller

  require Logger

  @api_url "https://api.teamsnap.com/v3"

  def teamsnap(conn, params) do
    Logger.info("received request: #{inspect params}")

    access_token = params["context"]["System"]["user"]["accessToken"]
    client = OAuth2.Client.new(token: access_token)
    # path = "/me"
    path = "/teams/active?user_id=2194"
    resp = OAuth2.Client.get!(client, @api_url <> path).body
    # Logger.info("response from teamsnap: #{inspect resp}")
    teams = resp["collection"]["items"]
            |> Enum.map(fn item ->
              item["data"] |> Enum.filter_map(fn map ->
                case map do
                    %{"name" => "name"} -> true
                    _ -> false
                end
              end,
              fn map ->
                map["value"]
              end
              )
            end) |> List.flatten
    # teams = resp["collection"]["items"]["data"]
    Logger.info("teams are: #{inspect teams}")

    response = %{
        "version" => "1.0",
        "response" => %{
            "outputSpeech" => %{
              "type" => "PlainText",
              "text" => "Your teams are: #{inspect Enum.join(teams, ",")}",
            },
            # "card" => %{
            #   "type" => "Simple",
            #   "title" => "Team Snap by Cobenian",
            #   "content" => "Your team snap information will go here."
            # },
            # "card" => %{
            #   "type" => "LinkAccount",
            # },
            "shouldEndSession" => true
        },
        "sessionAttributes" => %{}
    }
    Logger.info("sending response: #{inspect response}")
    json conn, response
  end
end
