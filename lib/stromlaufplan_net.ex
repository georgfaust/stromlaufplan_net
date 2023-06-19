defmodule StromlaufplanNet do
  @api_base_path "https://app.stromlaufplan.de/webapi"
  @api_key Application.compile_env(:stromlaufplan_net, :api_key) || raise "Missing API key"

  @headers [
    {"Content-Type", "application/json"},
    {"Authorization", "Bearer #{@api_key}}"}
  ]

  def create_project(name, address, _created_by, initial_project_data) do
    payload =
      %{
        address: address,
        copyFromId: nil,
        copyFromTemplate: nil,
        createdBy: nil,
        initialProjectData: initial_project_data,
        name: name,
        reviewedBy: nil
      }
      |> Jason.encode!()

    response = HTTPoison.post("#{@api_base_path}/projects", payload, @headers)

    case response do
      {:ok, %HTTPoison.Response{status_code: 201}} -> :ok
      {:ok, resp} -> {:error, resp}
      _ -> response
    end
  end

  def create_pdf(
        name,
        address,
        created_by,
        last_changed,
        reviewed_by,
        project_key,
        initial_project_data,
        paper_size \\ "A4"
      ) do
    payload =
      %{
        documentData: %{
          projectName: name,
          projectAddress: address,
          lastChanged: last_changed,
          createdBy: created_by,
          reviewedBy: reviewed_by,
          zeichnungsnummer: project_key
        },
        treeNodes: initial_project_data.treeNodes,
        treeNodeDatas: initial_project_data.treeNodeDatas,
        paperSize: paper_size
      }
      |> Jason.encode!()

    response =
      HTTPoison.post(
        "#{@api_base_path}/render/pdf",
        payload,
        @headers ++ [{"Accept", "application/pdf"}]
      )

    case response do
      {:ok, %HTTPoison.Response{status_code: 200, body: pdf}} -> {:ok, pdf}
      {:ok, resp} -> {:error, resp}
      _ -> response
    end
  end
end
