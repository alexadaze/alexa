defmodule Alexa.AlexaController do
  use Alexa.Web, :controller

  require Logger

  @api_url "https://api.teamsnap.com/v3"

  def teamsnap(conn, params) do
    Logger.info("received request: #{inspect params}")

    response =
    case get_in(params, ["context","System","user","accessToken"]) do
      nil ->
        %{
            "version" => "1.0",
            "response" => %{
                "outputSpeech" => %{
                  "type" => "PlainText",
                  "text" => "You must log in via the mobile app.",
                },
                "card" => %{
                  "type" => "LinkAccount",
                },
                "shouldEndSession" => true
            },
            "sessionAttributes" => %{}
        }
      access_token ->
        Logger.info("will use access token: #{inspect access_token}")
        client = OAuth2.Client.new(token: access_token)
        path = "/me"
        resp = OAuth2.Client.get!(client, @api_url <> path).body
        items = get_in(resp, ["collection", "items"])
        Logger.info("links are #{inspect items}")
        active_team_urls =
          items |> Enum.map(fn item ->
            item["links"] |> Enum.filter_map(fn link ->
              case link do
                %{"rel" => "active_teams"} -> true
                _ -> false
              end
            end,
            fn link ->
              link["href"]
            end
            )
          end) |> List.flatten
        Logger.info("active team urls: #{inspect active_team_urls}")
        teams =
          active_team_urls |> Enum.map(fn url ->
                  resp = OAuth2.Client.get!(client, url).body
                  Logger.info("response for #{inspect path} is #{inspect resp}")
                  resp["collection"]["items"]
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
        end) |> List.flatten
        Logger.info("teams are: #{inspect teams}")
        # Logger.info("response is #{inspect resp}")
        %{
            "version" => "1.0",
            "response" => %{
                "outputSpeech" => %{
                  "type" => "PlainText",
                  "text" => "Your teams are: #{Enum.join(teams, ", ")}",
                },
                "shouldEndSession" => true
            },
            "sessionAttributes" => %{}
        }
    end

    # access_token = params["context"]["System"]["user"]["accessToken"]
    # client = OAuth2.Client.new(token: access_token)
    # path = "/me"
    # # path = "/teams/active?user_id=2194"
    # resp = OAuth2.Client.get!(client, @api_url <> path).body
    # Logger.info("response from teamsnap: #{inspect resp}")
    # teams = resp["collection"]["items"]
    #         |> Enum.map(fn item ->
    #           item["data"] |> Enum.filter_map(fn map ->
    #             case map do
    #                 %{"name" => "name"} -> true
    #                 _ -> false
    #             end
    #           end,
    #           fn map ->
    #             map["value"]
    #           end
    #           )
    #         end) |> List.flatten
    # teams = resp["collection"]["items"]["data"]
    # Logger.info("teams are: #{inspect teams}")

    # response = %{
    #     "version" => "1.0",
    #     "response" => %{
    #         "outputSpeech" => %{
    #           "type" => "PlainText",
    #           "text" => "Your teams are: #{inspect Enum.join(teams, ",")}",
    #         },
    #         # "card" => %{
    #         #   "type" => "Simple",
    #         #   "title" => "Team Snap by Cobenian",
    #         #   "content" => "Your team snap information will go here."
    #         # },
    #         # "card" => %{
    #         #   "type" => "LinkAccount",
    #         # },
    #         "shouldEndSession" => true
    #     },
    #     "sessionAttributes" => %{}
    # }
    Logger.info("sending response: #{inspect response}")
    json conn, response
  end
end
