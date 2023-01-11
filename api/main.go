// https://github.com/a8m/golang-cheat-sheet
package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os"

	"github.com/gorilla/mux"
)

type CompletionInput struct {
	Model       string  `json:"model"`
	Prompt      string  `json:"prompt"`
	Temperature float32 `json:"temperature"`
	Max_Tokens  int     `json:"max_tokens"`
}

type InputDTO struct {
	UsersName string `json:"usersName"`
	Occasion  string `json:"occasion"`
	Gift      string `json:"gift"`
}

func post(w http.ResponseWriter, r *http.Request) {
	enableCors(&w)
	w.Header().Set("Content-Type", "application/json")

	decoder := json.NewDecoder((r.Body))
	var input InputDTO
	err := decoder.Decode(&input)

	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		w.Write([]byte("Unable to decode POST body."))
		return
	}

	request := newCompletionRequest(input)
	res, err := http.DefaultClient.Do(request)

	if err != nil {
		fmt.Printf("Error making request to chatGPT: %s\n", err)
		return
	}

	resBody, err := ioutil.ReadAll(res.Body)

	if err != nil {
		fmt.Printf("Error reading response from chatGPT: %s\n", err)
		return
	}

	w.WriteHeader(http.StatusOK)
	w.Write([]byte(resBody))
}

func newCompletionRequest(input InputDTO) *http.Request {
	// https://golang.cafe/blog/golang-json-marshal-example.html
	postBody, _ := json.Marshal(CompletionInput{
		Model: "text-davinci-003",
		// Prompt:      "Generate a thank you note to my grandparents for getting me a Kitchen Aid mixer for a get well gift. My grandmas name is Rose, my Grandpas name is Charles. My name is stephen. Emphasize the occasion",
		Prompt:      fmt.Sprintf("Generate a thank you from %s for receiving a %s for a %s gift.", input.UsersName, input.Gift, input.Occasion),
		Temperature: 0.6,
		Max_Tokens:  1500,
	})

	requestBody := bytes.NewBuffer(postBody)

	// https://developer20.com/add-header-to-every-request-in-go/
	req, _ := http.NewRequest(http.MethodPost, "https://api.openai.com/v1/completions", requestBody)
	addAuthorizationHeader(req)
	req.Header.Set("Content-Type", "application/json")
	return req
}

func addAuthorizationHeader(r *http.Request) {
	apiKey := os.Getenv("CHATGPT_API_KEY")
	(*r).Header.Add("Authorization", fmt.Sprintf("Bearer %s", apiKey))

}

func enableCors(w *http.ResponseWriter) {
	(*w).Header().Set("Access-Control-Allow-Origin", "*")
}

func notFound(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusNotFound)
	w.Write([]byte(`{"message": "not found"}`))
}

func optionsHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Access-Control-Allow-Origin", "*")
	w.Header().Set("Access-Control-Allow-Headers", "Content-Type")
	w.WriteHeader(http.StatusOK)
}

func main() {
	r := mux.NewRouter()
	r.HandleFunc("/", post).Methods(http.MethodPost)
	r.HandleFunc("/", optionsHandler).Methods(http.MethodOptions)
	r.HandleFunc("/", notFound)

	// headersOk := handlers.AllowedHeaders([]string{"X-Requested-With"})
	// originsOk := handlers.AllowedOrigins([]string{os.Getenv("ORIGIN_ALLOWED")})
	// methodsOk := handlers.AllowedMethods([]string{"GET", "HEAD", "POST", "PUT", "OPTIONS"})

	// log.Fatal(http.ListenAndServe(":8080", handlers.CORS(headersOk, originsOk, methodsOk)(r)))
	log.Fatal(http.ListenAndServe(":8080", r))
}
