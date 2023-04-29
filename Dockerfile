####################################################################################################
## Builder
####################################################################################################
FROM rust:latest AS builder

USER root

RUN update-ca-certificates

WORKDIR /build

COPY ./ .

RUN cargo build --release

####################################################################################################
## Final image
####################################################################################################
FROM debian:buster-slim

ARG PROJECT_NAME="rust-docker-starter"

USER root

WORKDIR /work

COPY --from=builder "/build/target/release/${PROJECT_NAME}" ./binary
COPY ./config ./config
RUN chmod 555 ./binary && chmod 444 ./config -R

RUN addgroup \
    --force-badname \
    --gid 1000\
    "worker" \
    && \
    adduser \
    --disabled-password \
    --force-badname \
    --gecos ""\
    --no-create-home \
    --uid 1000 \
    --gid 1000 \
    "worker"

USER worker:worker

ENTRYPOINT ["./binary"]
