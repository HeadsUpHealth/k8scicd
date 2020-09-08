FROM golang:alpine AS build-env
RUN mkdir /go/src/app 
RUN echo $HTTP_PROXY && echo $http_proxy && unset HTTP_PROXY && unset http_proxy && apk update
RUN apk add --no-cache git
ADD main.go /go/src/app/
WORKDIR /go/src/app
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -ldflags '-extldflags "-static"' -o app .

FROM scratch
WORKDIR /app
COPY --from=build-env /go/src/app/app .
ENTRYPOINT [ "./app" ]

