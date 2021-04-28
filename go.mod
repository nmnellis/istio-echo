module github.com/nmnellis/istio-echo

go 1.16

// Avoid pulling in incompatible libraries
replace github.com/docker/distribution => github.com/docker/distribution v0.0.0-20191216044856-a8371794149d

replace github.com/docker/docker => github.com/moby/moby v17.12.0-ce-rc1.0.20200618181300-9dc6525e6118+incompatible

require (
	contrib.go.opencensus.io/exporter/prometheus v0.3.0
	github.com/golang/protobuf v1.5.2
	github.com/gorilla/websocket v1.4.2
	github.com/hashicorp/go-multierror v1.1.1
	github.com/lucas-clemente/quic-go v0.20.1
	github.com/prometheus/client_golang v1.10.0
	github.com/spf13/cobra v1.1.3
	go.opencensus.io v0.23.0
	golang.org/x/net v0.0.0-20210427231257-85d9c07bbe3a
	golang.org/x/sync v0.0.0-20210220032951-036812b2e83c
	google.golang.org/grpc v1.37.0
	istio.io/istio v0.0.0-20210428100117-b969f62405cf
	istio.io/pkg v0.0.0-20210422202837-7a563315d7c5
)
