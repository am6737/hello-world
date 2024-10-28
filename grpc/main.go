package main

import (
	"context"
	"flag"
	"log"
	"net"

	pb "github.com/am6737/hello-world/api"

	"google.golang.org/grpc"
)

// 实现 Greeter 服务
type server struct {
	pb.UnimplementedGreeterServer
}

func (s *server) SayHello(ctx context.Context, req *pb.HelloRequest) (*pb.HelloResponse, error) {
	message := "Hello, " + req.Name
	responseMessage := message + " | Version: " + version
	return &pb.HelloResponse{Message: responseMessage}, nil
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
	lis, err := net.Listen("tcp", addr)
	if err != nil {
		log.Fatalf("Failed to listen: %v", err)
	}

	s := grpc.NewServer()
	pb.RegisterGreeterServer(s, &server{})

	log.Println("Server is running on " + addr)
	if err := s.Serve(lis); err != nil {
		log.Fatalf("Failed to serve: %v", err)
	}
}
