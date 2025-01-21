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

link = %Bookmark{
  name: "Elixir Docs",
  url_link: "https://hexdocs.pm/elixir/Kernel.html",
  description: "Start Here"
}

Repo.insert!(link)
