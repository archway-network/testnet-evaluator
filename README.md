# Testnet Evaluator
This repo combines various tools required for Testenet evaluation, including:

1. [cosmologger](https://github.com/archway-network/cosmologger) which collects blocks and transactions as they are happening in a cosmos based network.
2. [valuter](https://github.com/archway-network/valuter) which is a testnet evaluator tool that is linked with `cosmologger` database and extracts the winners information.
3. [valuter-ui](https://github.com/archway-network/valuter-ui) which is a simple REACT.js based UI for `valuter`.


## Quick Start

```sh
git clone --recursive git@github.com:archway-network/testnet-evaluator.git
cd testnet-evaluator/
docker-compose up -d --build
```

## Development mode

In the `docker-compose.yml` file, uncomment the target for the containers and write `development` in order to activate the development mode.

```yml
target: development
```

## Notes
If you are running your cosmos node locally, make sure to have a proper address on `conf.toml` file that is accessible from withing the containers. Since `cosmologger` is running in a container and due to its network configuration, it cannot see your local node if the address is `localhost` or `127.0.0.1`. You have to either use an IP address in `conf.toml` and set that IP address in `docker-compose.yml` file under `RPC_ADDRESS` ENV var or run your node in a container which is accessible by the `cosmologger`.