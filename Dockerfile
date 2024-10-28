# Use the official Golang image as the base image for building
FROM golang:1.23.2-alpine as builder

# Set build arguments for platform and architecture
ARG TARGETOS=linux
ARG TARGETARCH=amd64

# Set the working directory inside the container
WORKDIR /app

# Copy Go module files and download dependencies
COPY go.mod go.sum ./
RUN go mod download

# Copy the rest of the source code
COPY . .

# Build the Go app with specified target OS and architecture
RUN GOOS=$TARGETOS GOARCH=$TARGETARCH go build -o /app/main .
# Use a minimal base image to run the Go app
FROM alpine:3.18

# Set the working directory inside the container
WORKDIR /app

# Copy the built Go binary from the builder stage
COPY --from=builder /app/main .

# Command to run the Go app
ENTRYPOINT ["./main"]
