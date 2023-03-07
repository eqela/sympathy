FROM node:16.15-alpine3.15 as build
WORKDIR /build
COPY . /build
RUN apk add git
RUN npm run build

FROM node:16.15-alpine3.15 as dist
WORKDIR /sympathy
COPY --from=build /build/dist /sympathy
ENV NODE_PATH "/sympathy"
