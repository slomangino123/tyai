docker build -t go-api .
docker run -p 8080:8080 --name go-api -e CHATGPT_API_KEY=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 -d go-api