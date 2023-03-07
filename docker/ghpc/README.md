# ghpc docker image

## Usage

Create or copy `hpc-cluster-small.yaml` from the [hpc toolkit site](https://github.com/GoogleCloudPlatform/hpc-toolkit).

Create a GCP project `my-google-project`.

Then generate templates using the hpc toolkit:
```
docker run -v $PWD:/workspace --user $(id -u):$(id -g) markmims/ghpc create hpc-cluster-small.yaml --vars project_id=<my-google-project>
```
