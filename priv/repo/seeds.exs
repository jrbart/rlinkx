# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Rlinkx.Repo.insert!(%Rlinkx.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias Rlinkx.Remote.Bookmark
alias Rlinkx.Repo

link1 = %Bookmark{
  name: "Elixir Docs",
  url_link: "https://hexdocs.pm/elixir/Kernel.html",
  description: "Official docs for Elixir.  This is the go-to page for almost any Elixir question."
}

link2 = %Bookmark{
  name: "Phoenix Docs",
  url_link: "https://hexdocs.pm/phoenix/Phoenix.html",
  description: "Official docs for Phoenix.  Go here to look up Phoenix stuff in general."
}

link3 = %Bookmark{
  name: "LiveView Docs",
  url_link: "https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html",
  description: "Official docs for LiveView.  There be drogons here!"
}

links = [link1, link2, link3]

for link <- links do
  bmark = Repo.insert!(link)

end
