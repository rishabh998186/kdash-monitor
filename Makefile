.PHONY: all test run docker clean

all: test run

test:
	go test ./...

run:
	go run cmd/server/main.go

docker:
	docker build -t kdash-monitor .

clean:
	rm -f main
