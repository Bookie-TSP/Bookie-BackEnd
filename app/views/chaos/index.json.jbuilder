json.array!(@chaos) do |chao|
  json.extract! chao, :id
  json.url chao_url(chao, format: :json)
end
