Rails.application.routes.draw do
  # GQL playground http://localhost:3000/graphiql
  if Rails.env.development?
    mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "graphql#execute"
  end

  # GQL endpoint
  post "/graphql", to: "graphql#execute"

  # Home page
  root to: "statuses#index"
end
