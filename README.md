# ts-express-grpc-prisma-template
Template for building a "service" using Typescript, Express, gRPC, and Prisma ORM. It also includes `jest` and `supertest` for testing.

# Development environment setup

To init the project and start the typescript transpiler in watch mode:
```
npm i
npm run watch
```
To start the Express Rest and gRPC servers, Run this in another terminal:
```
npm run start
```

# Database ORM
This uses Prisma as its ORM because why not? https://www.prisma.io/

To create migrations and migrate based of `schema.prisma` file run:
```
./node_modules/.bin/prisma migrate dev
```
> Make sure the `DATABASE_URL` is set to a postgres DB that is reachable.

# gRPC Protobufs
https://grpc.io/

This comes with everything you need to convert your protobufs to TS and JS files to be used in your source code:

## Usage

Create a directory in the top level for your protobufs and create a `.proto` file:
```
mkdir ./protobufs; touch ./protobufs/user.proto
```
Populate the new proto file:
```
#./protobufs/user.proto
service UserApi {
  rpc Create (CreateUserRequest) returns (CreateUserResponse) {}
}

message User {
  int64 id = 1;
  string email = 2;
  string password = 3;
}

message CreateUserRequest {
  User user=1;
}

message CreateUserResponse {
  User user=1;
}
```
Create the output directories:
```
mkdir ./grpcCodegen ./src/grpcGeneratedTypes
```
Use grpc_tools to convert protos to ts/js files for use with your project:
> You must have `grpc_tools_node_protoc_ts` installed globally on your system. https://www.npmjs.com/package/grpc_tools_node_protoc_ts. npm i -g `grpc_tools_node_protoc_ts`
```
grpc_tools_node_protoc \                                               
  --plugin=protoc-gen-ts_proto=../node_modules/.bin/protoc-gen-ts_proto \
  --ts_proto_out=../src/grpcGeneratedTypes \
  --ts_proto_opt=outputServices=generic-definitions,useExactTypes=false \
  --ts_proto_opt=esModuleInterop=true \
  --grpc_out=grpc_js:../grpcCodegen \
  --js_out=import_style=commonjs,binary:../grpcCodegen/ \
  user.proto
```

the `./grpcCodegen` and `./src/grpcGeneratedTypes` directories should now be populated with everything you need to write your RPCs using gRPC.

# Docker image build and run
The docker image is pretty straight forward, only weird thing was passing ENV vars from the host system to the Dockerfile for private NPM repo required the use of `ARG`. So the build command ends up being something like (for github):
```
export NPM_USER=githubUser\
        NPM_PW=github-personal-access-token \
        NPM_EMAIL='me@here.com' \
        NPM_REGISTRY='https://npm.pkg.github.com'; \

docker build \
  --build-arg NPM_USER=${NPM_USER} \
  --build-arg NPM_PW=${NPM_PW} \
  --build-arg NPM_EMAIL=${NPM_EMAIL} \
  --build-arg NPM_REGISTRY=${NPM_REGISTRY} \
  -t docker.pkg.github.com/githubUser/my-project-repo/my-project-repo:0.1 .
```