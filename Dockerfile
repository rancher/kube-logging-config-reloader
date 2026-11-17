FROM registry.rancher.com/rancher/appco-go:1.27.4 AS builder

WORKDIR /workspace

# Copy the Go Modules manifests
COPY go.mod go.mod
COPY go.sum go.sum
COPY pkg pkg

# cache deps before building and copying source so that we don't need to re-download as much
# and so that source changes don't invalidate our downloaded layer
RUN go mod download
RUN go mod tidy

# Copy the go source
COPY /cmd/configreloader/main.go main.go

# Build
RUN CGO_ENABLED=0 go build -a -o config-reloader main.go

FROM registry.suse.com/bci/bci-nano:15.7

WORKDIR /

COPY --from=builder /workspace/config-reloader .

ENTRYPOINT ["/config-reloader"]
