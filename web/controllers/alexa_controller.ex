defmodule Alexa.AlexaController do
  use Alexa.Web, :controller

  require Logger

  def teamsnap(conn, params) do
    Logger.info("received request: #{inspect params}")
    response = %{
        "version" => "1.0",
        "response" => %{
            "outputSpeech" => %{
              "type" => "PlainText",
              "text" => "Hello World!",
            },
            "card": %{
              "type" => "Simple",
              "title" => "Team Snap by Cobenian",
              "content" => "Your team snap information will go here."
            },
            "shouldEndSession" => true
        },
        "sessionAttributes" => %{}
    }
    Logger.info("sending response: #{inspect response}")
    json conn, response
  end
end
