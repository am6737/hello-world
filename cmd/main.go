package main

import (
	"encoding/json"
	"flag"
	"log"
	"net/http"

	"git.tiduyun.com/liangmaoshen/hello-world/pkg/version"
)

var (
	addr         string
	printVersion bool
)

// @title Hello World API
// @version 1.0
// @description This is a simple Hello World API.
// @termsOfService http://example.com/terms/

// @contact.name API Support
// @contact.url http://www.example.com/support
// @contact.email support@example.com

// @license.name MIT
// @license.url https://opensource.org/licenses/MIT

// @host localhost:8080
// @BasePath /
func init() {
	flag.StringVar(&addr, "addr", ":8080", "Addr to run the server on")
	flag.BoolVar(&printVersion, "version", false, "Print version information")
	flag.Parse()
}

func main() {
	if printVersion {
		log.Println(version.FullVersion())
		return
	}

	http.HandleFunc("/", SayHello)
	server := &http.Server{
		Addr: addr,
	}
	log.Printf("Server is running on addr %s\n", addr)
	if err := server.ListenAndServe(); err != nil {
		log.Fatalf("Failed to serve: %v", err)
	}
}

// HelloResponse defines the structure of the response
type HelloResponse struct {
	Message string `json:"message"`
	Version string `json:"version"`
}

// SayHello handles the root endpoint
// @Summary Greet the user
// @Description Returns a greeting message along with the application version.
// @Tags Hello
// @Produce json
// @Success 200 {object} HelloResponse
// @Router / [get]
func SayHello(w http.ResponseWriter, r *http.Request) {
	log.Printf("Received request: Method=%s, URL=%s", r.Method, r.URL)

	resp := HelloResponse{
		Message: "Hello, World!",
		Version: version.FullVersion(),
	}

	w.Header().Set("Content-Type", "application/json")
	if err := json.NewEncoder(w).Encode(resp); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
}
