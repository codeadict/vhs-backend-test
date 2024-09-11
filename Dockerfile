FROM elixir:1.12.3-alpine AS builder

RUN apk add --no-cache git openssh-client

WORKDIR /tmp/vhs

ADD mix.exs .
ADD mix.lock .

RUN mix local.hex --force && \
  mix local.rebar --force && \
  MIX_ENV=prod mix deps.get && \
  MIX_ENV=prod mix deps.compile

# Do not copy _build or it will break the container build
COPY config ./config
COPY lib ./lib
COPY rel ./rel

RUN MIX_ENV=prod mix release

FROM alpine:3.12

RUN apk update && \
  apk add --no-cache \
  git \
  bash \
  libgcc \
  libstdc++ \
  ca-certificates \
  ncurses-libs \
  openssl

RUN addgroup -S vhs && adduser -S vhs -G vhs

COPY --from=builder /tmp/vhs/_build/prod/rel/vhs ./

RUN chown -R vhs:vhs bin/vhs releases/
RUN chown -R vhs:vhs `ls | grep 'erts-'`/

USER vhs

EXPOSE 4000

ENTRYPOINT [ "bin/vhs" ]
CMD [ "start" ]
