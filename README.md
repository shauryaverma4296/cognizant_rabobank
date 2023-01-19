# Customer Statement Processor

## Provisioning

Install Docker in your local system. Please make sure Docker is running in locally.
Based on your OS [install](https://docs.docker.com/engine/install/) Docker.

All you need is Docker and docker-compose installed locally to run the application which is made in Elixir.
The volumes inside the docker containers are mapped with your local directory.

The application is listening to the files sitting in `./apps/files/*`.
The system-generated files have the keyword `final` to their base name (`./apps/files/abcfinal.csv)`

Implemented a service to listen for file changes in the given directory.
There is no need to restart the application after adding files to the listening directory i.e `./apps/files/*`

The above implementation is being achieved using GenServer which is one of the most powerful tools in Elixir.
Please refer to the [commit](https://github.com/shauryaverma4296/cognizant_rabobank/commit/ffb20b0ab941c9f81dc2390d830b93dbb35d7963) to check out the implementation.

The business logic is sitting inside `./apps/lib/app.ex` 
- The Genserver will call the function generate_report/1 to generate the report.
    - Later, down the road validate_file_data/1 function will invoke. Which do the following
        - Reads raw data from the file (.csv or .xml). Function get_raw_data/2
        - Creates generic data apply the business logic. Function get_generic_data/2 -> generic_data_csv/2 & generic_data_csv/2
        - Apply the business logic. Function validate_end_balance/1 & validate_unique_refernce/2
        - Return the new data set. Function get_error_data_set/1
        - Write the data set into the file. Function write_data_csv/3 & write_data_xml/3

```elixir


```

## Usage

Initialize the provisioning and run the application by executing the below command
```bash
docker-compose up --build
```

To run the application in the detach mode
```bash
docker-compose up --build -d
```
Check the container is up and running 
```bash
docker container ps
```
To check the logs for the container 
```bash
docker-compose logs <service_name>
```

Later to exec or go inside the docker container
```bash
docker exec -it <container_name> bash
```

To stop the container
```bash
docker-compose stop
```
