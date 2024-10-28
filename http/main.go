package main

import (
	"encoding/json"
	"flag"
	"log"
	"net/http"
)

type HelloResponse struct {
	Message string `json:"message"`
	Version string `json:"version"`
}

func SayHello(w http.ResponseWriter, r *http.Request) {
	log.Printf("Received request: Method=%s, URL=%s", r.Method, r.URL)

	resp := HelloResponse{
		Message: "Hello, World!",
		Version: version,
	}

	w.Header().Set("Content-Type", "application/json")
	if err := json.NewEncoder(w).Encode(resp); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
}

const version = "1.0.0"

var (
	addr string
)

func init() {
	flag.StringVar(&addr, "addr", ":8080", "Addr to run the server on")
	flag.Parse()
}

func main() {
	http.HandleFunc("/", SayHello)
	log.Printf("Server is running on addr %s\n", addr)
	if err := http.ListenAndServe(addr, nil); err != nil {
		log.Fatalf("Failed to serve: %v", err)
	}
}
