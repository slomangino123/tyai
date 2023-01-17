docker build -t go-api .
docker run -p 8080:8080 --name go-api -e CHATGPT_API_KEY=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 -d go-api