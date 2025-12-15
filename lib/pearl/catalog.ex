defmodule Pearl.Catalog do
  @moduledoc """
  Listas para preencher selects de formulários.
  """

  def universities do
    [
      # Universidades Públicas
      "Universidade de Lisboa",
      "Universidade do Porto",
      "Universidade de Coimbra",
      "Universidade Nova de Lisboa",
      "Universidade do Minho",
      "Universidade de Aveiro",
      "Universidade da Beira Interior",
      "Universidade de Évora",
      "Universidade do Algarve",
      "Universidade de Trás-os-Montes e Alto Douro",
      "Universidade da Madeira",
      "Universidade dos Açores",
      "Universidade Aberta",
      "ISCTE - Instituto Universitário de Lisboa",

      # Institutos Politécnicos
      "Instituto Politécnico de Lisboa",
      "Instituto Politécnico do Porto",
      "Instituto Politécnico de Coimbra",
      "Instituto Politécnico de Leiria",
      "Instituto Politécnico de Setúbal",
      "Instituto Politécnico de Viseu",
      "Instituto Politécnico de Santarém",
      "Instituto Politécnico de Viana do Castelo",
      "Instituto Politécnico de Castelo Branco",
      "Instituto Politécnico de Beja",
      "Instituto Politécnico de Bragança",
      "Instituto Politécnico da Guarda",
      "Instituto Politécnico de Portalegre",
      "Instituto Politécnico de Tomar",
      "Instituto Politécnico do Cávado e do Ave",

      # Privadas
      "Universidade Católica Portuguesa",
      "Universidade Lusófona",
      "Universidade Lusíada",
      "Universidade Fernando Pessoa",
      "Universidade Europeia",
      "Universidade Autónoma de Lisboa",
      "Universidade Portucalense",
      "Universidade Atlântica",

      # Outra
      "Outra / Externo"
    ]
  end

  def cities do
    # Lista simplificada dos principais concelhos/cidades para não ser gigante
    [
      "Lisboa",
      "Porto",
      "Vila Nova de Gaia",
      "Amadora",
      "Braga",
      "Funchal",
      "Coimbra",
      "Setúbal",
      "Almada",
      "Agualva-Cacém",
      "Queluz",
      "Rio Tinto",
      "Barreiro",
      "Aveiro",
      "Viseu",
      "Odivelas",
      "Leiria",
      "Guimarães",
      "Faro",
      "Matosinhos",
      "Loures",
      "Póvoa de Varzim",
      "Maia",
      "Évora",
      "Portimão",
      "Viana do Castelo",
      "Castelo Branco",
      "Covilhã",
      "Guarda",
      "Vila Real",
      "Ponta Delgada",
      "Santarém",
      "Figueira da Foz",
      "Caldas da Rainha",
      "Torres Vedras",
      "Vila Franca de Xira",
      "Valongo",
      "Gondomar",
      "Vila do Conde",
      "Barcelos",
      "Outra"
    ]
    |> Enum.sort()
  end
end
