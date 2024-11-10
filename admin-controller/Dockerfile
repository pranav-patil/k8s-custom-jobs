# Build the manager binary
FROM golang:1.22 AS builder
ARG TARGETOS
ARG TARGETARCH

WORKDIR /workspace
# Copy the Go Modules manifests
COPY go.mod go.mod
COPY go.sum go.sum
# cache deps before building and copying source so that we don't need to re-download as much
# and so that source changes don't invalidate our downloaded layer
RUN go mod download

# Copy the go source
COPY cmd/main.go cmd/main.go
COPY api/ api/
COPY internal/controller/ internal/controller/

# Build
# the GOARCH has not a default value to allow the binary be built according to the host where the command
# was called. For example, if we call make docker-build in a local env which has the Apple Silicon M1 SO
# the docker BUILDPLATFORM arg will be linux/arm64 when for Apple x86 it will be linux/amd64. Therefore,
# by leaving it empty we can ensure that the container and binary shipped on it will have the same platform.
RUN CGO_ENABLED=0 GOOS=${TARGETOS:-linux} GOARCH=${TARGETARCH} go build -a -o manager cmd/main.go

# Use distroless as minimal base image to package the manager binary
# Refer to https://github.com/GoogleContainerTools/distroless for more details
FROM gcr.io/distroless/static:nonroot
WORKDIR /
COPY --from=builder /workspace/manager /manager
USER 65532:65532

ENTRYPOINT ["/manager"]

# See https://github.com/projectatomic/ContainerApplicationGenericLabels
LABEL vcs-ref="[COMMIT]" \
    vcs-type="git" \
    build-date="[BUILDTIME]" \
    vendor="Emprovise Inc" \
    distribution-scope="private"

FROM builder as tester

RUN mkdir -p /build/test-results/
WORKDIR /build/test-results/

RUN --mount=type=cache,mode=0777,id=gocache,target=/root/.cache/go-build \
    --mount=type=cache,mode=0777,id=gomodcache,target=/go/pkg/mod \
    go install github.com/jstemmer/go-junit-report@latest && \
    go install github.com/securego/gosec/v2/cmd/gosec@latest && \
    go install honnef.co/go/tools/cmd/staticcheck@latest

# Unit tests with coverage report
RUN (go test -v --cover ../... 2>&1 && touch .tests-passed) | tee unit-test-output.txt
RUN go-junit-report < unit-test-output.txt > junit-report.xml

# Static analysis
# If either of these steps fail, remove the 'tests-passed' marker
RUN --mount=type=cache,mode=0777,id=gocache,target=/root/.cache/go-build \
    --mount=type=cache,mode=0777,id=gomodcache,target=/go/pkg/mod \
    /go/bin/gosec ../... 2>/dev/null || (rm -f .tests-passed && echo "Gosec scan failed") && \
    /go/bin/staticcheck ../... || (rm -f .tests-passed && echo "Staticcheck scan failed")
