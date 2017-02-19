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
            "shouldEndSession" => true
        }
    }
    Logger.info("sending response: #{inspect response}")
    json conn,response
  end
end
