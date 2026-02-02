FROM golang:1.21-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=1 GOOS=linux go build -a -installsuffix cgo -o kdash-monitor ./cmd/server/main.go

FROM alpine:latest
RUN apk --no-cache add ca-certificates sqlite-libs
WORKDIR /app
COPY --from=builder /app/kdash-monitor .
COPY --from=builder /app/templates ./templates
COPY --from=builder /app/static ./static
COPY --from=builder /app/k8s-configs ./k8s-configs
RUN mkdir -p /app/data
EXPOSE 8080
ENV GIN_MODE=release
CMD ["./kdash-monitor"]
