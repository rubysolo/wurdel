# ====== build layer ==========================================================
# build the application
FROM blinker/alpine-elixir-phoenix:1.13.2-erlang-24.2-alpine-3.15 as build
ARG mix_env=prod

RUN apk add --update --no-cache build-base

WORKDIR /build
COPY . .

ENV MIX_ENV ${mix_env}

RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix deps.get --only ${MIX_ENV} --include-children

RUN mix compile
RUN mix assets.deploy

# finalize and release
RUN mix release

CMD ["mix", "start"]

# ====== service layer ========================================================
# production runtime
FROM alpine:3.15

RUN apk add --no-cache --update \
        bash \
        ca-certificates \
        libgcc \
        libstdc++ \
        ncurses-libs \
        openssl

WORKDIR /app

COPY --from=build /build/_build/prod/rel/wurdel .

CMD ["./bin/wurdel", "start"]
