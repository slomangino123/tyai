docker build -t go-api .
docker run -p 8080:8080 --name go-api -e CHATGPT_API_KEY=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 -d go-api