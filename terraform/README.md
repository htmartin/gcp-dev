

Each terraform "layer" here uses a common backend config.

There are two files involved:
- `terraform/backend.conf` has the bucket name
- `terraform/<layer>/backend.conf` has the path to the state for this layer

See each layer's `README.md` file for examples of how to init
each layer's backend for state.

